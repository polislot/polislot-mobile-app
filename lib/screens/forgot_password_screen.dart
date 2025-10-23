import 'package:flutter/material.dart';
import '../routes/api_service.dart';
import '../routes/app_routes.dart';
import 'verify_reset_otp_screen.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // ✅ Kirim OTP (bersih & konsisten dengan LoginScreen)
  Future<void> _sendOtp() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    final response = await ApiService.sendResetOtp(
      email: _emailController.text.trim(),
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (response.isSuccess) {
      _showSuccessDialog(response.message);
    } else {
      _showSnackBar(response.fullErrorMessage, Colors.red);
    }
  }

  // 🟩 Dialog sukses kirim OTP
  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Berhasil'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Tutup dialog
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => VerifyResetOtpScreen(
                    email: _emailController.text.trim(),
                  ),
                ),
              );
            },
            child: const Text('Lanjut'),
          ),
        ],
      ),
    );
  }

  // 🔴 Snackbar error
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lupa Password'),
        backgroundColor: Colors.blueAccent,
        elevation: 0,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Atur Ulang Password Anda',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Masukkan alamat email Anda untuk menerima kode verifikasi (OTP).',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(height: 35),

                // 📨 Input Email
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    prefixIcon: const Icon(Icons.email_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey[50],
                  ),
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
                const SizedBox(height: 30),

                // 🟦 Tombol Kirim OTP
                ElevatedButton(
                  onPressed: _isLoading ? null : _sendOtp,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.blueAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Kirim Kode Verifikasi',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
