// ignore_for_file: deprecated_member_use

import 'dart:async';
import 'package:flutter/material.dart';
import '../routes/app_routes.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _mainController;
  late AnimationController _shimmerController;
  late AnimationController _glowPulseController;

  late Animation<double> _fadeLogo;
  late Animation<double> _scaleLogo;
  late Animation<double> _fadeText;
  late Animation<double> _fadeSubtitle;
  late Animation<Offset> _slideText;

  @override
  void initState() {
    super.initState();

    _mainController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );

    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _glowPulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
      lowerBound: 0.8,
      upperBound: 1.15,
    )..repeat(reverse: true);

    _fadeLogo = CurvedAnimation(
      parent: _mainController,
      curve: const Interval(0.0, 0.35, curve: Curves.easeOut),
    );

    _scaleLogo = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.0, 0.45, curve: Curves.elasticOut),
      ),
    );

    _fadeText = CurvedAnimation(
      parent: _mainController,
      curve: const Interval(0.45, 0.75, curve: Curves.easeIn),
    );

    _slideText = Tween<Offset>(
      begin: const Offset(0, 0.4),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.45, 0.75, curve: Curves.easeOutBack),
      ),
    );

    _fadeSubtitle = CurvedAnimation(
      parent: _mainController,
      curve: const Interval(0.75, 1.0, curve: Curves.easeIn),
    );

    _mainController.addListener(() {
      if (_mainController.value > 0.45 && !_shimmerController.isAnimating) {
        _shimmerController.repeat();
      }
    });

    _mainController.forward();

    _startApp();
  }

  Future<void> _startApp() async {
    await Future.delayed(const Duration(seconds: 4));

    // final prefs = await SharedPreferences.getInstance();
    // final bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    // final bool isVerified = prefs.getBool('isVerified') ?? false;
    // final String? email = prefs.getString('email');

    if (!mounted) return;

    // --- LOGIKA LAMA (DINONAKTIFKAN SEMENTARA) ---
    /*
    if (!isLoggedIn) {
      // Belum login → ke halaman login/register
      Navigator.pushReplacementNamed(context, AppRoutes.loginRegis);
    } else {
      // Sudah login → cek apakah dari hasil register belum verifikasi?
      if (!isVerified && email != null) {
        // Registrasi baru tapi belum OTP
        Navigator.pushReplacementNamed(
          context,
          AppRoutes.verifyOtp,
          arguments: {'email': email},
        );
      } else {
        // Sudah login & verified → ke Home
        Navigator.pushReplacementNamed(context, AppRoutes.home);
      }
    }
    */
    // ---------------------------------------------

    // ✅ LOGIKA BARU: SELALU arahkan ke halaman login/register
    Navigator.pushReplacementNamed(context, AppRoutes.loginRegis);
  }

  @override
  void dispose() {
    _mainController.dispose();
    _shimmerController.dispose();
    _glowPulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      extendBody: true,
      backgroundColor: Colors.transparent,
      body: AnimatedBuilder(
        animation: _glowPulseController,
        builder: (context, _) {
          return Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF0D47A1),
                  Color.lerp(
                    const Color(0xFF1976D2),
                    const Color(0xFF42A5F5),
                    _glowPulseController.value - 0.8,
                  )!,
                  const Color(0xFF64B5F6),
                ],
              ),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned(
                  top: MediaQuery.of(context).size.height * 0.38,
                  child: AnimatedBuilder(
                    animation: _fadeLogo,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _glowPulseController.value,
                        child: Container(
                          width: 160,
                          height: 160,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.lightBlueAccent.withOpacity(
                                  (0.5 * _fadeLogo.value).clamp(0, 1),
                                ),
                                blurRadius: 90,
                                spreadRadius: 40,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FadeTransition(
                      opacity: _fadeLogo,
                      child: ScaleTransition(
                        scale: _scaleLogo,
                        child: const Icon(
                          Icons.location_on_outlined,
                          color: Colors.white,
                          size: 85,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SlideTransition(
                      position: _slideText,
                      child: FadeTransition(
                        opacity: _fadeText,
                        child: AnimatedBuilder(
                          animation: _shimmerController,
                          builder: (context, child) {
                            return ShaderMask(
                              shaderCallback: (bounds) {
                                return LinearGradient(
                                  colors: const [
                                    Colors.white,
                                    Colors.cyanAccent,
                                    Colors.white,
                                  ],
                                  stops: [
                                    (_shimmerController.value - 0.3)
                                        .clamp(0.0, 1.0),
                                    (_shimmerController.value).clamp(0.0, 1.0),
                                    (_shimmerController.value + 0.3)
                                        .clamp(0.0, 1.0),
                                  ],
                                ).createShader(bounds);
                              },
                              blendMode: BlendMode.srcATop,
                              child: const Text(
                                "PoliSlot",
                                style: TextStyle(
                                  fontSize: 38,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  letterSpacing: 1.4,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    FadeTransition(
                      opacity: _fadeSubtitle,
                      child: const Text(
                        "Cari Slot Parkirmu di Politeknik Negeri Batam",
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 15,
                          height: 1.4,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}