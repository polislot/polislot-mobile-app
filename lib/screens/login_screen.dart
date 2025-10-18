// ignore_for_file: deprecated_member_use

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_theme.dart';
import '../widgets/custom_textfield.dart';
import '../widgets/custom_button.dart';
import '../routes/app_routes.dart';
import '../routes/api_service.dart'; // 🌟 PATH TELAH DIPERBAIKI SESUAI LOKASI BARU

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with TickerProviderStateMixin {
  // 🔑 Form Key
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // 📝 Controllers
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // 🔄 State
  bool _isLoading = false;

  // ✨ Animation setup
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
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // ⚙️ LOGIKA API LOGIN
  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _loginUser() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (!mounted) return;
    setState(() => _isLoading = true);

    final email = _emailController.text.trim();
    final password = _passwordController.text;

    try {
      final responseMap = await ApiService.login(
        email: email,
        password: password,
      );

      if (!mounted) return;
      setState(() => _isLoading = false);

      final statusCode = responseMap['statusCode'] as int;
      final responseBody = responseMap['body'] as Map<String, dynamic>;

      if (statusCode == 200 && responseBody['status'] == 'success') {
        // ✅ LOGIN SUKSES
        final token = responseBody['data']['access_token'] as String;
        final userData = responseBody['data']['user'] as Map<String, dynamic>;

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('access_token', token);
        await prefs.setString('user_data', jsonEncode(userData));
        await prefs.setBool('isLoggedIn', true);

        _showSnackBar(responseBody['message'] ?? 'Login berhasil! Selamat datang.');
        
        // Navigasi ke halaman utama
        if (!mounted) return;
        Navigator.of(context).pushReplacementNamed(AppRoutes.welcome);

      } else if (statusCode == 403 && responseBody['code'] == 'UNVERIFIED') {
        // ⚠️ AKUN BELUM TERVERIFIKASI
        _showSnackBar(responseBody['message'] ?? 'Akun belum diverifikasi.');
        
        // Arahkan ke halaman verifikasi OTP dengan membawa email
        if (!mounted) return;
        Navigator.pushNamed(
          context,
          AppRoutes.verifyOtp,
          arguments: {'email': email},
        );
        
      } else {
        // ❌ LOGIN GAGAL (Kode salah, dikunci, atau error lainnya)
        final errorMessage = responseBody['message'] ?? 'Login gagal. Periksa kredensial Anda.';
        _showSnackBar(errorMessage);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      _showSnackBar('Gagal terhubung ke server. Periksa koneksi.');
      debugPrint('Login Error: $e');
    }
  }

  // ----------------------------------------------------------------------
  
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
                    return Form(
                      key: _formKey,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // ✨ Logo & Glow
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
                          GestureDetector(
                            onTap: () => Navigator.pushNamed(context, AppRoutes.register),
                            child: const Text(
                              "Belum punya akun? Daftar",
                              style: TextStyle(
                                color: Colors.white70, 
                                fontSize: 14,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                          const SizedBox(height: 25),

                          // 🧩 Input form Email
                          CustomTextField(
                            controller: _emailController, 
                            hint: 'Email',
                            icon: Icons.email,
                            keyboardType: TextInputType.emailAddress, 
                            validator: (val) { 
                              if (val == null || val.isEmpty) {
                                return 'Email tidak boleh kosong';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 12),
                          // 🧩 Input form Kata Sandi
                          CustomTextField(
                            controller: _passwordController, 
                            hint: 'Kata Sandi',
                            icon: Icons.lock,
                            obscure: true,
                            validator: (val) { 
                              if (val == null || val.isEmpty) {
                                return 'Kata Sandi tidak boleh kosong';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 25),

                          // 🔘 Tombol Masuk
                          _isLoading
                              ? const CircularProgressIndicator(color: Colors.white)
                              : CustomButton(
                                  text: 'Masuk',
                                  onPressed: _loginUser, 
                                  width: size.width * 0.7,
                                ),
                        ],
                      ),
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
