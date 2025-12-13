import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ecoguide/screens/home_screen.dart';
import 'package:ecoguide/screens/login_screen.dart';

/// Wrapper widget that routes to Home or Login based on authentication status
class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  late Stream<User?> _authStream;

  @override
  void initState() {
    super.initState();
    // Cache the stream to avoid creating new stream on each build
    _authStream = FirebaseAuth.instance.authStateChanges();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: _authStream,
      builder: (context, snapshot) {
        // Debug log
        debugPrint('AuthWrapper: connectionState=${snapshot.connectionState}, hasData=${snapshot.hasData}, user=${snapshot.data?.email}');
        
        // Show loading while checking auth state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Chargement...'),
                ],
              ),
            ),
          );
        }
        
        // Route based on authentication status
        if (snapshot.hasData && snapshot.data != null) {
          debugPrint('AuthWrapper: Navigating to HomeScreen');
          return const HomeScreen(key: ValueKey('home'));
        } else {
          debugPrint('AuthWrapper: Navigating to LoginScreen');
          return const LoginScreen(key: ValueKey('login'));
        }
      },
    );
  }
}
