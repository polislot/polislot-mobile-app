import 'package:flutter/material.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import '../routes/api_service.dart';
import 'reset_password_screen.dart';

class VerifyResetOtpScreen extends StatefulWidget {
  final String email;
  const VerifyResetOtpScreen({super.key, required this.email});

  @override
  State<VerifyResetOtpScreen> createState() => _VerifyResetOtpScreenState();
}

class _VerifyResetOtpScreenState extends State<VerifyResetOtpScreen> {
  final _otpTextController = TextEditingController();
  final _otpFormKey = GlobalKey<FormState>();

  bool _isLoading = false;
  bool _isResending = false;

  static const Color _primaryColor = Color(0xFF1976D2);
  static const Color _deepBlue = Color(0xFF0D47A1);

  @override
  void dispose() {
    _otpTextController.dispose();
    super.dispose();
  }

  void _showSnackBar(String message, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  // ✅ Verifikasi Reset OTP - CLEAN
  Future<void> _verifyResetOtp() async {
    if (_otpFormKey.currentState?.validate() == false) {
      _showSnackBar('Kode OTP harus 6 digit.', Colors.orange);
      return;
    }

    setState(() => _isLoading = true);

    final response = await ApiService.verifyResetOtp(
      email: widget.email,
      otp: _otpTextController.text.trim(),
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (response.isSuccess) {
      _showSnackBar(response.message, Colors.green);

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => ResetPasswordScreen(email: widget.email),
          transitionsBuilder: (_, animation, __, child) {
            const begin = Offset(1.0, 0.0);
            const end = Offset.zero;
            const curve = Curves.easeInOut;
            final tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
            return SlideTransition(position: animation.drive(tween), child: child);
          },
        ),
      );
    } else {
      _showSnackBar(response.fullErrorMessage, Colors.red);
    }
  }

  // ✅ Resend Reset OTP - CLEAN
  Future<void> _resendResetOtp() async {
    setState(() => _isResending = true);

    final response = await ApiService.resendResetOtp(email: widget.email);

    if (!mounted) return;
    setState(() => _isResending = false);

    if (response.isSuccess) {
      _showSnackBar(response.message, Colors.green);
    } else {
      _showSnackBar(response.fullErrorMessage, Colors.red);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: _deepBlue),
        title: const Text(
          'Atur Ulang Password',
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
              'Masukkan Kode Verifikasi',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: _deepBlue,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Kode verifikasi (OTP) telah dikirim ke:',
              style: TextStyle(fontSize: 16, color: Colors.grey[700]),
            ),
            const SizedBox(height: 4),
            Text(
              widget.email,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: _primaryColor,
              ),
            ),
            const SizedBox(height: 40),

            // 📌 PIN Code Field
            Form(
              key: _otpFormKey,
              child: PinCodeTextField(
                appContext: context,
                length: 6,
                animationType: AnimationType.fade,
                validator: (v) {
                  if (v == null || v.length < 6) {
                    return "Kode OTP tidak lengkap";
                  }
                  return null;
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
                onCompleted: (v) async {
                  if (_otpFormKey.currentState?.validate() == true) {
                    await Future.delayed(const Duration(milliseconds: 150));
                    _verifyResetOtp();
                  }
                },
                onChanged: (_) {},
              ),
            ),
            const SizedBox(height: 30),

            // 🔘 Tombol Verifikasi
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _verifyResetOtp,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _deepBlue,
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
                        'Verifikasi Kode',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 20),

            // 🔄 Tombol Kirim Ulang OTP
            Center(
              child: TextButton(
                onPressed: _isResending || _isLoading ? null : _resendResetOtp,
                child: _isResending
                    ? const SizedBox(
                        height: 16,
                        width: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.0,
                          color: _primaryColor,
                        ),
                      )
                    : const Text(
                        'Kirim Ulang Kode',
                        style: TextStyle(
                          color: _primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 8),

            // 💡 Teks Bantuan
            Center(
              child: Text(
                "Belum menerima kode? Periksa folder spam email Anda.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[600], fontSize: 13),
              ),
            ),
          ],
        ),
      ),
    );
  }
}