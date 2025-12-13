import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart';
import 'dart:async';
import 'package:ecoguide/services/email_service.dart';
import 'package:ecoguide/models/user_model.dart';
import 'package:ecoguide/services/firestore_service.dart';

class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirestoreService _firestoreService = FirestoreService();
  StreamSubscription<AppUser?>? _userSubscription;

  User? get currentUser => _auth.currentUser;
  bool get isLoggedIn => currentUser != null;
  AppUser? _appUser;
  AppUser? get appUser => _appUser;
  
  // Track if auth state has been determined
  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  AuthService() {
    _auth.authStateChanges().listen((User? user) {
      _userSubscription?.cancel();
      if (user != null) {
        _userSubscription = _firestoreService.getUserStream(user.uid).listen((userData) {
          _appUser = userData;
          _isInitialized = true;
          notifyListeners();
        });
      } else {
        _appUser = null;
        _isInitialized = true;
        notifyListeners();
      }
    });
  }

  @override
  void dispose() {
    _userSubscription?.cancel();
    super.dispose();
  }

  Future<void> loadUserData() async {
    if (currentUser != null) {
      _appUser = await _firestoreService.getUser(currentUser!.uid);
      notifyListeners();
    }
  }

  Future<UserCredential?> signInWithEmail(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      // Try to load user data, but don't fail if Firestore fails
      try {
        _appUser = await _firestoreService.getUser(credential.user!.uid);
      } catch (e) {
        // Create a basic AppUser from Firebase Auth data
        _appUser = AppUser(
          id: credential.user!.uid,
          email: credential.user!.email ?? email,
          displayName: credential.user!.displayName ?? email.split('@')[0],
        );
      }
      notifyListeners();
      return credential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'Erreur de connexion: ${e.toString()}';
    }
  }

  Future<UserCredential?> registerWithEmail(
      String email, String password, String displayName) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Create user document in Firestore
      final appUser = AppUser(
        id: credential.user!.uid,
        email: email,
        displayName: displayName,
      );
      
      try {
        await _firestoreService.createUser(appUser);
        
        // Generate App Code Key
        final codeKey = '${credential.user!.uid.substring(0, 4).toUpperCase()}-${DateTime.now().millisecondsSinceEpoch.toString().substring(9)}';
        
        // Send Welcome Email
        EmailService.sendWelcomeEmail(email, codeKey).then((success) {
          if (success) {
            print('Welcome email sent successfully to $email');
          } else {
            print('Failed to send welcome email');
          }
        });

      } catch (e) {
        // Firestore might fail due to permissions, but auth succeeded
        print('Warning: Could not create Firestore user or send email: $e');
      }
      
      _appUser = appUser;
      notifyListeners();

      return credential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'Erreur d\'inscription: ${e.toString()}';
    }
  }

  Future<UserCredential?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);

      // Check if user exists in Firestore, if not create
      final existingUser =
          await _firestoreService.getUser(userCredential.user!.uid);
      if (existingUser == null) {
        final appUser = AppUser(
          id: userCredential.user!.uid,
          email: userCredential.user!.email ?? '',
          displayName: userCredential.user!.displayName ?? 'User',
          photoUrl: userCredential.user!.photoURL,
        );
        await _firestoreService.createUser(appUser);
        _appUser = appUser;
      } else {
        _appUser = existingUser;
      }

      notifyListeners();
      return userCredential;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
    _appUser = null;
    notifyListeners();
  }

  Future<void> resetPassword(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'Aucun utilisateur trouvé avec cet email.';
      case 'wrong-password':
        return 'Mot de passe incorrect.';
      case 'email-already-in-use':
        return 'Cet email est déjà utilisé.';
      case 'weak-password':
        return 'Le mot de passe est trop faible.';
      case 'invalid-email':
        return 'L\'email n\'est pas valide.';
      default:
        return 'Une erreur s\'est produite. Veuillez réessayer.';
    }
  }
}
