import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../routes/app_routes.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with TickerProviderStateMixin {
  late final AnimationController _glowCtrl;
  late final Animation<double> _fadeIn;

  @override
  void initState() {
    super.initState();
    _glowCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
      lowerBound: 0.8,
      upperBound: 1.15,
    )..repeat(reverse: true);

    _fadeIn = CurvedAnimation(parent: _glowCtrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _glowCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient),
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(26),
              child: AnimatedBuilder(
                animation: _glowCtrl,
                builder: (context, _) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // 🌟 Ikon dengan efek glow (sama kayak Splash, Login, Register)
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          FadeTransition(
                            opacity: _fadeIn,
                            child: Transform.scale(
                              scale: _glowCtrl.value,
                              child: Container(
                                width: 170,
                                height: 170,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.lightBlueAccent.withOpacity(0.45),
                                      blurRadius: 85,
                                      spreadRadius: 35,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const Icon(
                            Icons.location_on_outlined,
                            color: Colors.white,
                            size: 95,
                          ),
                        ],
                      ),

                      const SizedBox(height: 30),
                      const Text(
                        "Selamat Datang di PoliSlot!",
                        style: TextStyle(
                          fontSize: 22,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        "Cari slot parkirmu di Politeknik Negeri Batam — cepat, praktis, dan nyaman.",
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 15,
                          height: 1.4,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 40),

                      // 🔘 Tombol "Selanjutnya"
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pushReplacementNamed(context, AppRoutes.main);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: AppTheme.primaryLight,
                          minimumSize: const Size.fromHeight(50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: const Text(
                          "Selanjutnya",
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
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
