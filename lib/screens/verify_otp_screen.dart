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
  final _otpController = TextEditingController();
  final _otpFormKey = GlobalKey<FormState>();

  bool _isLoading = false;
  bool _isResending = false;
  late String _email;

  static const String _baseUrl = 'http://10.0.2.2:8000/api';
  static const Color _primaryColor = Color(0xFF1976D2);
  static const Color _deepBlue = Color(0xFF0D47A1);

  @override
  void initState() {
    super.initState();
    _email = widget.email ?? '';
    if (_email.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _getRouteArguments());
    }
  }

  void _getRouteArguments() {
    final args = ModalRoute.of(context)?.settings.arguments as Map?;
    final emailArg = args?['email'] ?? '';
    if (emailArg.isNotEmpty) {
      setState(() => _email = emailArg);
    } else {
      Navigator.pop(context);
    }
  }

  void _showSnack(String msg, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? Colors.red[700] : Colors.green[700],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  // =====================================================
  // 🧩 Helper untuk handle API response konsisten
  // =====================================================
  Future<Map<String, dynamic>> _handleApiResponse(http.Response response) async {
    try {
      final data = jsonDecode(response.body);
      return {
        'success': response.statusCode == 200,
        'message': data['message'] ?? 'Terjadi kesalahan.',
        'data': data['data'],
        'errors': data['errors']
      };
    } catch (_) {
      return {
        'success': false,
        'message': 'Respons server tidak valid (${response.statusCode})',
        'data': null,
        'errors': null
      };
    }
  }

  // =====================================================
  // ✅ Verifikasi OTP
  // =====================================================
  Future<void> _verifyOtp() async {
  if (!_otpFormKey.currentState!.validate()) {
    _showSnack('Kode OTP harus 6 digit.', isError: true);
    return;
  }

  setState(() => _isLoading = true);
  try {
    final response = await http.post(
      Uri.parse('$_baseUrl/verify-register-otp'),
      headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
      body: jsonEncode({'email': _email, 'otp': _otpController.text.trim()}),
    );

    final result = await _handleApiResponse(response);

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (result['success'] && result['data'] != null) {
      // ✅ Simpan token dan data user
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('access_token', result['data']['access_token']);
      await prefs.setString('user_data', jsonEncode(result['data']['user']));
      await prefs.setBool('isLoggedIn', true);

      if (!mounted) return;

      // 🟢 Tampilkan snackbar sukses (langsung seperti di LoginScreen)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? 'Verifikasi berhasil!'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          duration: const Duration(milliseconds: 1500),
        ),
      );

      // ✅ Langsung navigasi tanpa delay (SnackBar akan muncul sebentar)
      Navigator.of(context).pushReplacementNamed(AppRoutes.welcome);
    } else {
      if (!mounted) return;
      final errors = result['errors'];
      String msg = result['message'];
      if (errors is Map && errors.isNotEmpty) {
        msg = errors.values.first[0];
      }
      _showSnack(msg, isError: true);
    }
  } catch (e) {
    if (!mounted) return;
    setState(() => _isLoading = false);
    _showSnack('Tidak dapat terhubung ke server. Pastikan koneksi aktif.', isError: true);
    debugPrint('❌ Verify OTP Error: $e');
  }
}
  // =====================================================
  // 🔁 Kirim Ulang OTP
  // =====================================================
  Future<void> _resendOtp() async {
    setState(() => _isResending = true);
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/resend-register-otp'),
        headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
        body: jsonEncode({'email': _email}),
      );

      final result = await _handleApiResponse(response);
      
      if (!mounted) return; // ✅ Cek mounted
      setState(() => _isResending = false);

      // Success atau error, tampilkan dengan warna sesuai
      _showSnack(
        result['message'] ?? 'OTP baru telah dikirim.',
        isError: !result['success']
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isResending = false);
      _showSnack('Gagal mengirim ulang OTP. Periksa koneksi Anda.', isError: true);
      debugPrint('❌ Resend OTP Error: $e');
    }
  }

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_email.isEmpty) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: _primaryColor)),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: _deepBlue),
        title: const Text('Verifikasi Akun',
            style: TextStyle(color: _deepBlue, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Masukkan Kode OTP',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: _deepBlue)),
            const SizedBox(height: 8),
            Text(
              'Kami telah mengirim kode verifikasi ke email:',
              style: TextStyle(fontSize: 16, color: Colors.grey[700]),
            ),
            const SizedBox(height: 4),
            Text(_email, style: const TextStyle(fontWeight: FontWeight.bold, color: _primaryColor)),
            const SizedBox(height: 40),

            // 📮 Pin Code Field
            Form(
              key: _otpFormKey,
              child: PinCodeTextField(
                appContext: context,
                length: 6,
                controller: _otpController,
                animationType: AnimationType.fade,
                validator: (v) => v!.length == 6 ? null : "OTP tidak lengkap",
                pinTheme: PinTheme(
                  shape: PinCodeFieldShape.box,
                  borderRadius: BorderRadius.circular(10),
                  fieldHeight: 50,
                  fieldWidth: 40,
                  activeColor: _primaryColor,
                  inactiveColor: Colors.grey[300],
                  selectedColor: _primaryColor,
                  activeFillColor: Colors.white,
                  selectedFillColor: Colors.white,
                  inactiveFillColor: Colors.grey[100],
                ),
                enableActiveFill: true,
                cursorColor: _deepBlue,
                keyboardType: TextInputType.number,
                animationDuration: const Duration(milliseconds: 300),
                onCompleted: (_) => _verifyOtp(),
                onChanged: (_) {},
              ),
            ),
            const SizedBox(height: 30),

            // 🔘 Tombol Verifikasi
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _verifyOtp,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _deepBlue,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  elevation: 5,
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3))
                    : const Text('Verifikasi Akun',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ),
            const SizedBox(height: 20),

            // 🔁 Kirim Ulang OTP
            Center(
              child: TextButton(
                onPressed: _isResending || _isLoading ? null : _resendOtp,
                child: _isResending
                    ? const SizedBox(
                        height: 16,
                        width: 16,
                        child: CircularProgressIndicator(strokeWidth: 2.0, color: _primaryColor))
                    : const Text('Kirim Ulang Kode',
                        style: TextStyle(color: _primaryColor, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}