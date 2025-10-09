import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'register_screen.dart';
import '../routes/app_routes.dart';
import '../theme/app_theme.dart';
import '../widgets/custom_button.dart';

class LoginRegisScreen extends StatefulWidget {
  const LoginRegisScreen({super.key});

  @override
  State<LoginRegisScreen> createState() => _LoginRegisScreenState();
}

class _LoginRegisScreenState extends State<LoginRegisScreen>
    with TickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final AnimationController _glowCtrl;

  late final Animation<double> _fadeLogo;
  late final Animation<double> _fadeSub;
  late final Animation<double> _fadeButtons;
  late final Animation<Offset> _slideSub;

  @override
  void initState() {
    super.initState();

    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    _glowCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
      lowerBound: 0.8,
      upperBound: 1.15,
    )..repeat(reverse: true);

    _fadeLogo = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.0, 0.45, curve: Curves.easeOut),
    );

    _fadeSub = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.4, 0.7, curve: Curves.easeIn),
    );

    _fadeButtons = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.7, 1.0, curve: Curves.easeIn),
    );

    _slideSub = Tween<Offset>(
      begin: const Offset(0, 0.18),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.4, 0.75, curve: Curves.easeOutBack),
      ),
    );

    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _glowCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: AppTheme.backgroundGradient,
        ),
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: AnimatedBuilder(
                animation: _glowCtrl,
                builder: (context, _) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // ✨ Glow di belakang logo
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          FadeTransition(
                            opacity: _fadeLogo,
                            child: Transform.scale(
                              scale: _glowCtrl.value,
                              child: Container(
                                width: 150,
                                height: 150,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.lightBlueAccent
                                          .withOpacity(0.5),
                                      blurRadius: 80,
                                      spreadRadius: 35,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          // 🟦 Logo utama (sama seperti SplashScreen)
                          FadeTransition(
                            opacity: _fadeLogo,
                            child: const Icon(
                              Icons.location_on_outlined,
                              color: Colors.white,
                              size: 85,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // ✨ Teks utama
                      SlideTransition(
                        position: _slideSub,
                        child: FadeTransition(
                          opacity: _fadeSub,
                          child: const Text(
                            "Dimana Slot Parkir Kosong?",
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),

                      const SizedBox(height: 8),
                      FadeTransition(
                        opacity: _fadeSub,
                        child: const Text(
                          "Masuk atau daftarkan akunmu",
                          style: TextStyle(
                            color: Colors.white60,
                            fontSize: 13,
                          ),
                        ),
                      ),

                      SizedBox(height: size.height * 0.06),

                      // 🟩 Tombol login & register
                      FadeTransition(
                        opacity: _fadeButtons,
                        child: Column(
                          children: [
                            CustomButton(
                              text: 'Masuk',
                              onPressed: () => Navigator.of(context).push(
                                slideRoute(const LoginScreen(), fromRight: true),
                              ),
                              width: size.width * 0.72,
                              height: 48,
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              "atau",
                              style: TextStyle(color: Colors.white54),
                            ),
                            const SizedBox(height: 10),
                            CustomButton(
                              text: 'Daftar',
                              onPressed: () => Navigator.of(context).push(
                                slideRoute(const RegisterScreen(),
                                    fromRight: true),
                              ),
                              outlined: true,
                              width: size.width * 0.72,
                              height: 48,
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
