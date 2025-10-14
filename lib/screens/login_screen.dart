// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/custom_textfield.dart';
import '../widgets/custom_button.dart';
import '../routes/app_routes.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with TickerProviderStateMixin {
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

    _fadeIn = CurvedAnimation(
      parent: _glowCtrl,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _glowCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: AnimatedBuilder(
                  animation: _glowCtrl,
                  builder: (context, _) {
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // ✨ Glow di belakang ikon lokasi
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            FadeTransition(
                              opacity: _fadeIn,
                              child: Transform.scale(
                                scale: _glowCtrl.value,
                                child: Container(
                                  width: 150,
                                  height: 150,
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
                              size: 85,
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),
                        const Text(
                          "Masuk Akun",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 5),
                        const Text(
                          "Belum punya akun? Daftar",
                          style: TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                        const SizedBox(height: 25),

                        // 🧩 Input form
                        const CustomTextField(hint: 'Email', icon: Icons.email),
                        const SizedBox(height: 12),
                        const CustomTextField(
                          hint: 'Kata Sandi',
                          icon: Icons.lock,
                          obscure: true,
                        ),
                        const SizedBox(height: 25),

                        // 🔘 Tombol Masuk
                        CustomButton(
                          text: 'Masuk',
                          onPressed: () => Navigator.pushReplacementNamed(
                            context,
                            AppRoutes.welcome,
                          ),
                          width: size.width * 0.7,
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
