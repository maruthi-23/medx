import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:medx/HomeScreen.dart';
import 'package:medx/auth/ui/login_screen.dart';
import 'package:medx/firebase_options.dart';
import 'package:medx/onboarding/onboarding_screen.dart';
import 'package:medx/onboarding/onboarding_service.dart';
import 'package:medx/services/notification_service.dart';
import 'package:medx/services/permission_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await NotificationService.init();
  await PermissionService.requestNotificationPermission();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MedX',
      theme: _buildTheme(),
      home: const AppRoot(),
    );
  }

  ThemeData _buildTheme() {
    final base = ThemeData(
      useMaterial3: true,
      colorSchemeSeed: const Color(0xFF2563EB),
      brightness: Brightness.light,
    );

    return base.copyWith(
      textTheme: GoogleFonts.poppinsTextTheme(base.textTheme),
      scaffoldBackgroundColor: const Color(0xffF4F6FA),
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 1.5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
}

class AppRoot extends StatefulWidget {
  const AppRoot({super.key});

  @override
  State<AppRoot> createState() => _AppRootState();
}

class _AppRootState extends State<AppRoot> {
  bool? isFirstTime;
  User? user;

  @override
  void initState() {
    super.initState();
    _initApp();
  }

  Future<void> _initApp() async {
    // Check onboarding
    final firstTime = await OnboardingService.isFirstTime();
    setState(() {
      isFirstTime = firstTime;
    });

    // Listen to auth changes
    FirebaseAuth.instance.authStateChanges().listen((currentUser) {
      setState(() {
        user = currentUser;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    // Show splash while checking onboarding
    if (isFirstTime == null) {
      return const SplashScreen();
    }

    // Show onboarding if first time
    if (isFirstTime == true) {
      return const OnboardingScreen();
    }

    // Show HomeScreen if logged in
    if (user != null) {
      return const HomeScreen();
    }

    // Otherwise, show login
    return const LoginScreen();
  }
}

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}