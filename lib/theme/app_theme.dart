import 'package:flutter/material.dart';

class AppTheme {
  // Warna utama (biru deep -> mid -> light)
  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF0D47A1), // deep royal blue
      Color(0xFF1976D2), // mid blue
      Color(0xFF42A5F5), // light blue
    ],
    stops: [0.0, 0.55, 1.0],
  );

  static const Color primaryLight = Color(0xFF42A5F5);
  static const Color primaryDark = Color(0xFF0D47A1);
}
