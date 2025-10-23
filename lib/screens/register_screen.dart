// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/custom_textfield.dart';
import '../widgets/custom_button.dart';
import '../routes/app_routes.dart';
import '../routes/api_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with TickerProviderStateMixin {
  late final AnimationController _glowCtrl;
  late final Animation<double> _fadeIn;

  // 🎯 Controller untuk input form
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  bool _isLoading = false;

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
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  // 🧩 Fungsi Registrasi — menggunakan ApiService (lebih bersih)
  Future<void> _registerUser() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirm = _confirmController.text;

    if (name.isEmpty || email.isEmpty || password.isEmpty || confirm.isEmpty) {
      _showSnackBar('Semua kolom harus diisi!', Colors.red);
      return;
    }

    if (password != confirm) {
      _showSnackBar('Konfirmasi kata sandi tidak cocok.', Colors.red);
      return;
    }

    setState(() => _isLoading = true);

    final response = await ApiService.register(
      name: name,
      email: email,
      password: password,
      confirmPassword: confirm,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (response.isSuccess) {
      _showSnackBar(response.message, Colors.green);

      // ✅ Arahkan ke halaman verifikasi OTP
      Navigator.pushNamed(
        context,
        AppRoutes.verifyOtp,
        arguments: {'email': email},
      );
    } else {
      _showSnackBar(response.fullErrorMessage, Colors.red);
    }
  }

  // 🔔 Snackbar umum
  void _showSnackBar(String message, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(30, 30, 30, 40),
              child: AnimatedBuilder(
                animation: _glowCtrl,
                builder: (context, _) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // ✨ Logo dengan efek glow
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

                      // 🧾 Input Fields
                      CustomTextField(
                        hint: 'Nama Lengkap',
                        icon: Icons.person,
                        controller: _nameController,
                      ),
                      const SizedBox(height: 12),
                      CustomTextField(
                        hint: 'Email',
                        icon: Icons.email,
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 12),
                      CustomTextField(
                        hint: 'Kata Sandi',
                        icon: Icons.lock,
                        obscure: true,
                        controller: _passwordController,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 4, bottom: 8, left: 15),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Min. 8 karakter, mengandung huruf besar/kecil, angka, dan simbol.',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                      ),
                      CustomTextField(
                        hint: 'Konfirmasi Kata Sandi',
                        icon: Icons.lock,
                        obscure: true,
                        controller: _confirmController,
                      ),
                      const SizedBox(height: 25),

                      // 🔘 Tombol Daftar
                      _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : CustomButton(
                              text: 'Daftar',
                              onPressed: _registerUser,
                              width: size.width * 0.7,
                            ),

                      const SizedBox(height: 15),
                      TextButton(
                        onPressed: () {
                          if (!mounted) return;
                          Navigator.pushNamed(context, AppRoutes.login);
                        },
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
    );
  }
}
