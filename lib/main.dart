import 'package:flutter/material.dart';
import 'routes/app_routes.dart'; // ✅ Import semua definisi rute

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

      // 🔹 Tema Aplikasi
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
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(12)),
            ),
            elevation: 2,
          ),
        ),
      ),

      // ✅ Rute Awal
      initialRoute: AppRoutes.splash,

      // ✅ Rute statis & dinamis
      routes: AppRoutes.routes, // untuk screen tanpa parameter
      onGenerateRoute: AppRoutes.onGenerateRoute, // untuk screen dengan parameter

      // (opsional) Jika route tidak ditemukan
      onUnknownRoute: (settings) => MaterialPageRoute(
        builder: (_) => const Scaffold(
          body: Center(
            child: Text(
              'Halaman tidak ditemukan 😢',
              style: TextStyle(fontSize: 18, color: Colors.red),
            ),
          ),
        ),
      ),
    );
  }
}
