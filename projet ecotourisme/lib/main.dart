import 'package:ecoguide/screens/auth_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:ecoguide/screens/home_screen.dart';
import 'package:ecoguide/services/auth_service.dart';
import 'package:ecoguide/providers/theme_provider.dart';
import 'package:ecoguide/utils/app_theme.dart';
import 'package:intl/date_symbol_data_local.dart';
// Import this file after running: flutterfire configure
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize date formatting for French locale
  await initializeDateFormatting('fr_FR', null);
  
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  runApp(const EcoGuideApp());
}

class EcoGuideApp extends StatelessWidget {
  const EcoGuideApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // ThemeProvider for dark/light mode management
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        // AuthService provider for state management
        ChangeNotifierProvider(create: (_) => AuthService()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'EcoGuide',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,
            // home: const HomeScreen(),
            // After Firebase is configured, replace with:
            home: const AuthWrapper(),
          );
        },
      ),
    );
  }
}
