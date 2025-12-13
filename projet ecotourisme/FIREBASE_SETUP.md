# Firebase Configuration Guide - EcoGuide

## Quick Start Guide

Follow these steps to configure Firebase for your EcoGuide app.

---

## Prerequisites

✅ Flutter installed and configured  
✅ Firebase account created  
✅ Node.js installed (for Firebase CLI)

---

## Step-by-Step Instructions

### 1. Install Firebase CLI and FlutterFire CLI

Open your terminal and run:

```bash
# Install Firebase CLI (if not already installed)
npm install -g firebase-tools

# Login to Firebase
firebase login

# Install FlutterFire CLI
dart pub global activate flutterfire_cli
```

### 2. Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Add project"
3. Project name: **ecoguide-app** (or your preferred name)
4. Enable Google Analytics (optional)
5. Create project

### 3. Enable Firebase Services

#### Enable Authentication

1. In Firebase Console → **Authentication**
2. Click "Get started"
3. Enable sign-in methods:
   - ✅ Email/Password
   - ✅ Google

#### Create Firestore Database

1. In Firebase Console → **Firestore Database**
2. Click "Create database"
3. Start mode: **Test mode** (for development)
4. Location: **europe-west** (or your preferred region)

### 4. Configure Flutter App

Navigate to your project directory and run:

```bash
cd "c:\Users\Mouhannedd\Downloads\projet ecotourisme"
flutterfire configure
```

**During configuration**:
- Select your Firebase project (ecoguide-app)
- Select platforms: Android, iOS (minimum)
- Accept to update configuration files

This command will:
- Create `lib/firebase_options.dart`
- Download `google-services.json` (Android)
- Download `GoogleService-Info.plist` (iOS)

### 5. Update Android Configuration

Edit `android/app/build.gradle`:

Add at the **bottom** of the file:
```gradle
apply plugin: 'com.google.gms.google-services'
```

Edit `android/build.gradle`:

Add to `buildscript` > `dependencies`:
```gradle
classpath 'com.google.gms:google-services:4.4.0'
```

### 6. Enable Firebase in Code

In `lib/main.dart`, uncomment these lines:

```dart
import 'firebase_options.dart';

// In main() function:
await Firebase.initializeApp(
  options: DefaultFirebaseOptions.currentPlatform,
);
```

And change home to use AuthWrapper:
```dart
home: const AuthWrapper(),
```

### 7. Get SHA-1 for Google Sign-In (Android)

Run this command to get your SHA-1:

```bash
cd android
./gradlew signingReport
```

Or on Windows:
```bash
cd android
gradlew signingReport
```

Copy the SHA-1 fingerprint and add it in Firebase Console:
- Project Settings → Your apps → Android app
- Add SHA-1 certificate fingerprint
- Download new `google-services.json`

### 8. Initialize Data

After Firebase is configured, you can populate Firestore with initial data.

Create a temporary button in your app to run:

```dart
import 'package:ecoguide/services/data_initialization_service.dart';

// In a button onPressed:
final initService = DataInitializationService();
await initService.initializeAllData();
```

Or add it to main.dart temporarily:

```dart
void main() async {
  // ... existing code
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Initialize data (run once)
  // final initService = DataInitializationService();
  // await initService.initializeIfNeeded();
  
  runApp(const EcoGuideApp());
}
```

### 9. Update Firestore Security Rules

In Firebase Console → Firestore Database → Rules:

Replace with production-ready rules from the integration plan, or use these for development:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Allow read for all, write for authenticated users
    match /{document=**} {
      allow read: if true;
      allow write: if request.auth != null;
    }
  }
}
```

> ⚠️ **WARNING**: These are permissive rules for development. Use proper security rules in production.

### 10. Test Your Integration

Run your app:

```bash
flutter run
```

Test:
- ✅ User registration
- ✅ Email/password login
- ✅ Google sign-in
- ✅ Data loading from Firestore
- ✅ Creating bookings

---

## Troubleshooting

### "No Firebase App '[DEFAULT]' has been created"

**Solution**: Make sure `Firebase.initializeApp()` is called before `runApp()` in `main.dart`.

### "google-services.json not found"

**Solution**: 
1. Check if file exists in `android/app/`
2. Re-run `flutterfire configure`
3. Clean and rebuild: `flutter clean && flutter pub get`

### Google Sign-In not working

**Solution**:
1. Add SHA-1 to Firebase Console
2. Download new `google-services.json`
3. Place in `android/app/`
4. Run `flutter clean && flutter run`

### Firestore permission denied

**Solution**: Check Firestore Rules in Firebase Console and ensure they allow the operations you're trying to perform.

---

## Files Modified

After configuration, these files will be created/modified:

**Created**:
- ✅ `lib/firebase_options.dart`
- ✅ `android/app/google-services.json`
- ✅ `ios/Runner/GoogleService-Info.plist`

**Modified**:
- ✅ `lib/main.dart`
- ✅ `android/app/build.gradle`
- ✅ `android/build.gradle`

---

## Next Steps

1. [ ] Run `flutterfire configure`
2. [ ] Update `main.dart` to enable Firebase
3. [ ] Test authentication
4. [ ] Initialize Firestore data
5. [ ] Update security rules
6. [ ] Test all features

---

## Useful Commands

```bash
# Reconfigure Firebase
flutterfire configure

# Clean build
flutter clean
flutter pub get

# Run app
flutter run

# Build for release
flutter build apk      # Android
flutter build ios      # iOS
```

---

*Configuration guide for EcoGuide Firebase Integration - December 2025*
