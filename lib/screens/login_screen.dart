// ignore_for_file: deprecated_member_use, use_build_context_synchronously
import 'dart:convert'; 
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_theme.dart';
import '../widgets/custom_textfield.dart';
import '../widgets/custom_button.dart';
import '../routes/app_routes.dart';
import '../routes/api_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with TickerProviderStateMixin {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  
  bool _isLoading = false;
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

  // ✅ LOGIN LOGIC - FIXED MOUNTED ERROR
  Future<void> _loginUser() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final response = await ApiService.login(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      // ⚠️ CRITICAL: Check mounted sebelum setState
      if (!mounted) return;

      setState(() => _isLoading = false);

      if (response.isSuccess) {
        // ✅ LOGIN BERHASIL
        final token = response.data?['access_token'];
        final user = response.data?['user'];

        if (token != null && user != null) {
          // Save to SharedPreferences
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('access_token', token);
          await prefs.setString('user_data', jsonEncode(user));
          await prefs.setBool('isLoggedIn', true);

          // ✅ Check mounted SEBELUM akses context
          if (!mounted) return;

          // Simpan navigator reference
          // final navigator = Navigator.of(context);
          
          // Show success message
          await ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response.message),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              margin: const EdgeInsets.all(16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              duration: const Duration(milliseconds: 1500),
            ),
          ).closed;

          // ✅ Navigate LANGSUNG tanpa delay
          Navigator.of(context).pushReplacementNamed(AppRoutes.welcome);
        } else {
          if (!mounted) return;
          _showSnackBar('Data login tidak lengkap', Colors.red);
        }
      } else if (response.statusCode == 403 && response.data?['code'] == 'UNVERIFIED') {
        // ⚠️ AKUN BELUM TERVERIFIKASI
        if (!mounted) return;
        
        final navigator = Navigator.of(context);
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.message),
            backgroundColor: Colors.orange,
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            duration: const Duration(milliseconds: 800),
          ),
        );

        // Navigate langsung
        navigator.pushNamed(
          AppRoutes.verifyOtp,
          arguments: {'email': _emailController.text.trim()},
        );
      } else {
        // ❌ ERROR
        if (!mounted) return;
        _showSnackBar(response.fullErrorMessage, Colors.red);
      }
    } catch (e) {
      // Handle any unexpected errors
      if (!mounted) return;
      setState(() => _isLoading = false);
      _showSnackBar('Terjadi kesalahan: $e', Colors.red);
      debugPrint('Login Error: $e');
    }
  }

  void _showSnackBar(String message, Color color) {
    if (!mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        duration: const Duration(seconds: 2),
      ),
    );
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
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // ✨ Logo & Glow
                      AnimatedBuilder(
                        animation: _glowCtrl,
                        builder: (context, _) {
                          return Stack(
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
                          );
                        },
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

                      // 📧 Email Input
                      CustomTextField(
                        controller: _emailController,
                        hint: 'Email',
                        icon: Icons.email,
                        keyboardType: TextInputType.emailAddress,
                        validator: (val) {
                          if (val == null || val.isEmpty) {
                            return 'Email tidak boleh kosong';
                          }
                          if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(val)) {
                            return 'Format email tidak valid';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),

                      // 🔒 Password Input
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

                      // 🔗 Forgot Password
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            Navigator.pushNamed(context, AppRoutes.forgotPassword);
                          },
                          child: const Text(
                            "Lupa kata sandi?",
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                              fontStyle: FontStyle.italic,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 10),

                      // 🔘 Login Button
                      _isLoading
                          ? const CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 3,
                            )
                          : CustomButton(
                              text: 'Masuk',
                              onPressed: _loginUser,
                              width: size.width * 0.7,
                            ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}