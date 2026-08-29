import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'providers/app_state.dart';
import 'screens/splash_screen.dart';
import 'utils/app_colors.dart';

import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'utils/globals.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }
  } catch (e) {
    debugPrint("Firebase initialization error: $e");
  }
  
  // Removed persistence override to allow default caching
  // This prevents [cloud_firestore/unavailable] errors on flaky networks
  // Set status bar to transparent / dark overlay
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));

  runApp(
    ChangeNotifierProvider(
      create: (_) => AppState(),
      child: const FixoraApp(),
    ),
  );
}

class FixoraApp extends StatelessWidget {
  const FixoraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        final primary = AppColors.getRoleColor(appState.currentRole);
        return MaterialApp(
          navigatorKey: navigatorKey,
          title: 'Fixora',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            brightness: Brightness.dark,
            primaryColor: primary,
            scaffoldBackgroundColor: const Color(0xFF121212),
            cardTheme: const CardThemeData(
              color: Color(0xFF1E1E1E),
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                backgroundColor: primary,
                foregroundColor: Colors.white,
              ),
            ),
            colorScheme: ColorScheme.dark(
              primary: primary,
              secondary: primary,
              surface: const Color(0xFF1E1E1E),
              error: Colors.redAccent,
            ),
            appBarTheme: const AppBarTheme(
              elevation: 0,
              backgroundColor: Colors.transparent,
              iconTheme: IconThemeData(color: Colors.white70),
            ),
          ),
          home: const SplashScreen(),
        );
      },
    );
  }
}
