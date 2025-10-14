import 'package:flutter/material.dart';
import '../screens/splash_screen.dart';
import '../screens/login_regis_screen.dart';
import '../screens/login_screen.dart';
import '../screens/register_screen.dart';
import '../screens/welcome_screen.dart';
import '../screens/main_screen.dart';
import '../screens/home_screen.dart';
import '../screens/mission_screen.dart';
import '../screens/reward_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/parkir_screen.dart';
import '../screens/info_screen.dart';

class AppRoutes {
  static const splash = '/';
  static const loginRegis = '/loginRegis';
  static const login = '/login';
  static const register = '/register';
  static const welcome = '/welcome';
  static const main = '/main';
  static const home = '/home';
  static const mission = '/mission';
  static const reward = '/reward';
  static const profile = '/profile';
  static const parkir = '/parkir';
  static const info = '/info';

  static Map<String, WidgetBuilder> routes = {
    splash: (context) => const SplashScreen(),
    loginRegis: (context) => const LoginRegisScreen(),
    login: (context) => const LoginScreen(),
    register: (context) => const RegisterScreen(),
    welcome: (context) => const WelcomeScreen(),
    main: (context) => const MainScreen(),
    home: (context) => const HomeScreen(),
    mission: (context) => const MissionScreen(),
    reward: (context) => const RewardScreen(),
    profile: (context) => const ProfileScreen(),
    parkir: (context) => const ParkirFullScreen(),
    info: (context) => const InfoScreen(),
  };
}

/// 🔹 Helper untuk transisi slide animasi antar halaman
Route slideRoute(Widget page, {bool fromRight = true}) {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final begin = Offset(fromRight ? 1.0 : -1.0, 0.0);
      final end = Offset.zero;
      final tween = Tween(begin: begin, end: end)
          .chain(CurveTween(curve: Curves.easeOut));
      return SlideTransition(position: animation.drive(tween), child: child);
    },
  );
}
