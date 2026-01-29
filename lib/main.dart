import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';
import 'providers/providers.dart';
import 'screens/screens.dart';
import 'utils/theme.dart';

/// Main entry point of the Insurance Claim Management System.
/// 
/// This application provides a complete solution for managing
/// hospital insurance claims, including:
/// - Creating and editing claims
/// - Managing bills
/// - Tracking claim status workflow
/// - Financial calculations
/// - Cloud data storage with Firebase Firestore
/// - Analytics and insights dashboard
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  runApp(const InsuranceClaimApp());
}

/// Root widget of the application.
/// 
/// Sets up:
/// - Firebase integration
/// - Provider state management
/// - Material 3 theming with dark mode support
/// - Main navigation
class InsuranceClaimApp extends StatelessWidget {
  const InsuranceClaimApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Theme provider for dark mode toggle
        ChangeNotifierProvider(
          create: (_) => ThemeProvider(),
        ),
        // Claims state management provider with Firestore
        ChangeNotifierProvider(
          create: (_) => ClaimsProvider(),
        ),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
            // App information
            title: 'Insurance Claim Management',
            debugShowCheckedModeBanner: false,
            
            // Theme configuration with dark mode support
            theme: createAppTheme(),
            darkTheme: createDarkTheme(),
            themeMode: themeProvider.themeMode,
            
            // Home screen - directly show dashboard
            home: const DashboardScreen(),
          );
        },
      ),
    );
  }
}


