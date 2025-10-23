import 'package:flutter/material.dart';
import 'routes/app_routes.dart';


// import semua screen yang digunakan
import 'screens/splash_screen.dart';
import 'screens/login_regis_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/welcome_screen.dart';
import 'screens/main_screen.dart';
import 'screens/home_screen.dart';
import 'screens/mission_screen.dart';
import 'screens/reward_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/parkir_screen.dart';
import 'screens/info_screen.dart';
import 'screens/verify_otp_screen.dart';

void main() {
  runApp(const PoliSlotApp());
}

class PoliSlotApp extends StatelessWidget {
  const PoliSlotApp({super.key});

  @override
  Widget build(BuildContext context) {
    const Color _primaryColor = Color(0xFF1976D2);
    const Color _secondaryColor = Color(0xFF2196F3);

    return MaterialApp(
      title: 'PoliSlot',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Roboto',
        scaffoldBackgroundColor: Colors.white,
        colorScheme: ColorScheme.fromSeed(
          seedColor: _primaryColor,
          primary: _primaryColor,
          secondary: _secondaryColor,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: _primaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            fontFamily: 'Roboto',
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Colors.white,
          ),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: _primaryColor,
          foregroundColor: Colors.white,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: _primaryColor,
            foregroundColor: Colors.white,
            textStyle: const TextStyle(
              fontFamily: 'Roboto',
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(12)),
            ),
            elevation: 2,
          ),
        ),
      ),

      // ✅ halaman pertama yang muncul
      initialRoute: AppRoutes.splash,

      // ✅ daftar route sesuai AppRoutes
      routes: {
        AppRoutes.splash: (_) => const SplashScreen(),
        AppRoutes.loginRegis: (_) => const LoginRegisScreen(),
        AppRoutes.login: (_) => const LoginScreen(),
        AppRoutes.register: (_) => const RegisterScreen(),
        AppRoutes.welcome: (_) => const WelcomeScreen(),
        AppRoutes.main: (_) => const MainScreen(),
        AppRoutes.home: (_) => const HomeScreen(),
        AppRoutes.mission: (_) => const MissionScreen(),
        AppRoutes.reward: (_) => const RewardScreen(),
        AppRoutes.profile: (_) => const ProfileScreen(),
        AppRoutes.parkir: (_) => const AreaParkirScreen(),
        AppRoutes.info: (_) => const InfoScreen(),
        AppRoutes.verifyOtp: (_) => const VerifyOtpScreen(),
      },
    );
  }
}