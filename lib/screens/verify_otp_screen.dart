import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pin_code_fields/pin_code_fields.dart'; 
import '../routes/app_routes.dart';

class VerifyOtpScreen extends StatefulWidget {
  final String? email;
  const VerifyOtpScreen({super.key, this.email}); 

  @override
  State<VerifyOtpScreen> createState() => _VerifyOtpScreenState();
}

class _VerifyOtpScreenState extends State<VerifyOtpScreen> {
  // Gunakan TextEditingController untuk PinCodeFields
  final _otpTextController = TextEditingController();
  final _otpFormKey = GlobalKey<FormState>(); // Key untuk validasi form
  
  bool _isLoading = false;
  bool _isResending = false;
  
  static const Color _primaryColor = Color(0xFF1976D2); // Mid Blue
  static const Color _deepBlue = Color(0xFF0D47A1);    // Deep Royal Blue

  static const String _baseUrl = 'http://10.0.2.2:8000/api'; 

  late String _currentEmail;

  @override
  void initState() {
    super.initState();
    _currentEmail = widget.email ?? ''; 
    
    if (_currentEmail.isEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
            _getRouteArguments();
        });
    }
  }
  
  void _getRouteArguments() {
    final args = ModalRoute.of(context)?.settings.arguments as Map?;
    final emailFromArgs = args?['email'] as String? ?? '';
    
    if (emailFromArgs.isNotEmpty) {
        setState(() {
            _currentEmail = emailFromArgs;
        });
    } else if (_currentEmail.isEmpty) {
        Future.microtask(() => Navigator.pop(context));
    }
  }

  @override
  void dispose() {
    _otpTextController.dispose();
    super.dispose();
  }

  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

// ----------------------------------------------------------------------
// 🟢 FUNGSI VERIFIKASI OTP
// ----------------------------------------------------------------------
  Future<void> _verifyOtp() async {
    // Validasi form PinCodeFields secara eksplisit
    if (_otpFormKey.currentState?.validate() == false) {
      _showSnackBar('Kode OTP harus 6 digit.');
      return;
    }
    
    final email = _currentEmail;
    final otp = _otpTextController.text.trim(); // Ambil nilai dari controller

    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/verify-register-otp'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json'
        },
        body: jsonEncode({'email': email, 'otp': otp}),
      );

      if (!mounted) return; 
      setState(() => _isLoading = false); 

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final prefs = await SharedPreferences.getInstance();
        
        await prefs.setString('access_token', data['data']['access_token']);
        await prefs.setString('user_data', jsonEncode(data['data']['user'])); 
        await prefs.setBool('isLoggedIn', true);

        _showSnackBar(data['message'] ?? 'Verifikasi berhasil! Selamat datang.');
        
        if (!mounted) return;
        Navigator.of(context).pushNamedAndRemoveUntil(
          AppRoutes.welcome, 
          (route) => false,
        );

      } else {
        String errorMessage = 'Kode OTP salah atau telah kedaluwarsa.';
        try {
          final errorData = jsonDecode(response.body);
          if (errorData.containsKey('message')) {
            errorMessage = errorData['message'];
          } else if (errorData.containsKey('errors') && errorData['errors'].values.isNotEmpty) {
             errorMessage = errorData['errors'].values.first[0];
          }
        } on FormatException {
          errorMessage = 'Kesalahan Server: Status ${response.statusCode}';
        }
        
        _showSnackBar(errorMessage);
      }

    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      _showSnackBar('Gagal terhubung ke server. Periksa koneksi Anda.');
      debugPrint('Error: $e');
    }
  }

// ----------------------------------------------------------------------
// 🟠 FUNGSI KIRIM ULANG OTP
// ----------------------------------------------------------------------
  Future<void> _resendOtp() async {
    final email = _currentEmail;

    if (!mounted) return;
    setState(() => _isResending = true);

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/resend-register-otp'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json'
        },
        body: jsonEncode({'email': email}),
      );

      if (!mounted) return;
      setState(() => _isResending = false);

      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200) {
        _showSnackBar(data['message'] ?? 'Kode OTP baru telah dikirim!');
      } else {
        _showSnackBar(data['message'] ?? 'Gagal mengirim ulang OTP. Coba lagi.');
      }

    } catch (e) {
      if (!mounted) return;
      setState(() => _isResending = false);
      _showSnackBar('Gagal mengirim ulang: Periksa koneksi.');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_currentEmail.isEmpty) {
        return const Scaffold(
            appBar: null,
            body: Center(child: CircularProgressIndicator(color: _primaryColor)),
        );
    }
    
    final emailDisplay = _currentEmail;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        // Desain App Bar Minimalis
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: _deepBlue),
        title: const Text(
          'Verifikasi Akun', 
          style: TextStyle(color: _deepBlue, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Masukkan Kode OTP',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: _deepBlue),
            ),
            const SizedBox(height: 8),
            Text(
              'Kami telah mengirimkan kode verifikasi (OTP) ke alamat email:',
              style: TextStyle(fontSize: 16, color: Colors.grey[700]),
            ),
            const SizedBox(height: 4),
            Text(
              emailDisplay,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: _primaryColor,
              ),
            ),
            const SizedBox(height: 40),

            // Pin Code Fields (Tampilan Modern)
            Form(
              key: _otpFormKey,
              child: PinCodeTextField(
                appContext: context,
                length: 6,
                obscureText: false,
                animationType: AnimationType.fade,
                validator: (v) {
                  if (v!.length < 6) {
                    return "Kode OTP tidak lengkap";
                  } else {
                    return null;
                  }
                },
                pinTheme: PinTheme(
                  shape: PinCodeFieldShape.box,
                  borderRadius: BorderRadius.circular(10),
                  fieldHeight: 50,
                  fieldWidth: 40,
                  activeFillColor: Colors.white,
                  inactiveFillColor: Colors.grey[100],
                  selectedFillColor: Colors.white,
                  activeColor: _primaryColor,
                  inactiveColor: Colors.grey[300],
                  selectedColor: _primaryColor,
                ),
                cursorColor: _deepBlue,
                animationDuration: const Duration(milliseconds: 300),
                enableActiveFill: true,
                controller: _otpTextController,
                keyboardType: TextInputType.number,
                onCompleted: (v) {
                  if (_otpFormKey.currentState?.validate() == true) {
                    _verifyOtp(); // Otomatis verifikasi setelah 6 digit terisi
                  }
                },
                onChanged: (value) {},
              ),
            ),
            const SizedBox(height: 30),

            // Tombol Verifikasi
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _verifyOtp,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _deepBlue, // Warna lebih gelap untuk aksi kuat
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 5,
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 3,
                        ),
                      )
                    : const Text(
                        'Verifikasi Akun',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 20),
            
            // Tombol Kirim Ulang OTP
            Center(
              child: TextButton(
                onPressed: _isResending || _isLoading ? null : _resendOtp,
                child: _isResending
                    ? const SizedBox(
                        height: 16,
                        width: 16,
                        child: CircularProgressIndicator(strokeWidth: 2.0, color: _primaryColor),
                      )
                    : Text(
                        'Kirim Ulang Kode', 
                        style: TextStyle(
                          color: _primaryColor, 
                          fontWeight: FontWeight.w600
                        )
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}