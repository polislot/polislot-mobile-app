import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/custom_textfield.dart';
import '../widgets/custom_button.dart';
import '../routes/app_routes.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
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
                        // 🌟 Glow Icon (same style as Splash & Login)
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
                                        color: Colors.lightBlueAccent
                                            .withOpacity(0.45),
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
                          "Daftarkan Akun Baru",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 25),

                        // 🧩 Input Fields
                        const CustomTextField(
                          hint: 'Nama Lengkap',
                          icon: Icons.person,
                        ),
                        const SizedBox(height: 12),
                        const CustomTextField(
                          hint: 'Email',
                          icon: Icons.email,
                        ),
                        const SizedBox(height: 12),
                        const CustomTextField(
                          hint: 'Kata Sandi',
                          icon: Icons.lock,
                          obscure: true,
                        ),
                        const SizedBox(height: 12),
                        const CustomTextField(
                          hint: 'Konfirmasi Kata Sandi',
                          icon: Icons.lock,
                          obscure: true,
                        ),
                        const SizedBox(height: 25),

                        // 🔘 Tombol Daftar
                        CustomButton(
                          text: 'Daftar',
                          onPressed: () => Navigator.pushReplacementNamed(
                            context,
                            AppRoutes.welcome,
                          ),
                          width: size.width * 0.7,
                        ),
                        const SizedBox(height: 15),

                        // 🔁 Navigasi ke Login
                        TextButton(
                          onPressed: () =>
                              Navigator.pushNamed(context, AppRoutes.login),
                          child: const Text(
                            "Sudah punya akun? Masuk",
                            style: TextStyle(color: Colors.white),
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
      ),
    );
  }
}
