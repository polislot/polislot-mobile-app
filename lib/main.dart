import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'routes/app_routes.dart';
import 'theme/app_theme.dart';

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
import 'screens/camera_screen.dart';
import 'screens/verify_otp_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 🔧 Atur orientasi & status bar biar clean
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent, // transparan
      statusBarIconBrightness: Brightness.light,
    ),
  );

  runApp(const PoliSlotApp());
}

class PoliSlotApp extends StatelessWidget {
  const PoliSlotApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PoliSlot',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Poppins',
        colorSchemeSeed: AppTheme.primaryLight,
      ),

      // ✅ Halaman pertama
      initialRoute: AppRoutes.splash,

      // ✅ Semua route di app
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
        AppRoutes.parkir: (_) => const ParkirFullScreen(),
        AppRoutes.info: (_) => const InfoScreen(),
        AppRoutes.verifyOtp: (context) => VerifyOtpScreen(),
        '/camera': (_) => const CameraScreen(),
      },
    );
  }
}
