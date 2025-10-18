// ignore_for_file: deprecated_member_use

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

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

  // 🎯 Controller untuk input form
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  bool _isLoading = false; // untuk loading state

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

  // Helper function untuk mengambil pesan error validasi baris pertama saja
  String _formatValidationErrors(Map<String, dynamic> errors) {
    String message = "Validasi Gagal: ";
    
    // Iterasi melalui semua field (misal: 'password', 'email')
    errors.forEach((field, fieldErrors) {
      if (fieldErrors is List && fieldErrors.isNotEmpty) {
        // Ambil pesan error pertama dari array field tersebut
        message += fieldErrors.first.toString();
        // Cukup ambil pesan error dari field pertama yang gagal
        return; 
      }
    });
    // Hapus 'Validasi Gagal: ' jika tidak ada pesan error yang ditemukan
    if (message == "Validasi Gagal: ") {
      return "Validasi gagal. Mohon periksa kembali input Anda.";
    }
    return message;
  }


  // 🌐 Fungsi kirim data ke backend Laravel
  Future<void> _registerUser() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirm = _confirmController.text;

    // Cek field kosong lokal
    if (name.isEmpty || email.isEmpty || password.isEmpty || confirm.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Semua kolom harus diisi!')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // ✅ GUNAKAN IP KHUSUS EMULATOR
      const apiUrl = 'http://10.0.2.2:8000/api/register';

      print('📤 Mengirim request ke $apiUrl');

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json', // Tambahkan ini untuk respons JSON
        },
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
          'password_confirmation': confirm,
        }),
      );

      if (!mounted) return;
      setState(() => _isLoading = false);

      print('📥 Status Code: ${response.statusCode}');
      print('📦 Response: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        // SUKSES
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Registrasi berhasil! Cek email Anda untuk OTP.'),
          ),
        );

        Navigator.pushNamed(
          context,
          AppRoutes.verifyOtp,
          arguments: {'email': email},
        );
      } else if (response.statusCode == 422) {
        // --- Tangani Error Validasi 422 Secara Detail ---
        final data = jsonDecode(response.body);
        
        // Cek apakah ada kunci 'errors' dari Laravel
        if (data.containsKey('errors')) {
          final errorMessage = _formatValidationErrors(data['errors']);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(errorMessage)),
          );
        } else {
          // Fallback jika 422 tapi formatnya tidak standar
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(data['message'] ?? 'Validasi gagal.')),
          );
        }
      } 
      else {
        // Error server umum (500, 400, dll.)
        final data = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'] ?? 'Terjadi kesalahan pada server.')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menghubungi server: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      // ✅ PERBAIKAN 1: Mengatur ke true untuk penanganan keyboard otomatis
      resizeToAvoidBottomInset: true, 
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: Padding(
                // ✅ PERBAIKAN 2: Memberi padding 40 di bawah agar tombol navigasi tidak tersembunyi
                padding: const EdgeInsets.fromLTRB(30, 30, 30, 40), 
                child: AnimatedBuilder(
                  animation: _glowCtrl,
                  builder: (context, _) {
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // 🌟 Glow Icon
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
                        ),
                        const SizedBox(height: 12),
                        CustomTextField(
                          hint: 'Kata Sandi',
                          icon: Icons.lock,
                          obscure: true,
                          controller: _passwordController,
                        ),
                        
                        // 📢 Teks Persyaratan Password Baru
                        Padding(
                          padding: const EdgeInsets.only(top: 4, bottom: 8, left: 15),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Min. 8 karakter, mengandung huruf besar/kecil, angka, dan simbol.',
                              style: TextStyle(
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
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : CustomButton(
                                text: 'Daftar',
                                onPressed: _registerUser,
                                width: size.width * 0.7,
                              ),
                        const SizedBox(height: 15),

                        // 🔁 Navigasi ke Login
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
      ),
    );
  }
}
