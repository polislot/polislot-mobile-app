import 'package:flutter/material.dart';
import '../routes/api_service.dart';
import '../routes/app_routes.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String email;
  const ResetPasswordScreen({super.key, required this.email});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _isLoading = false;
  bool _showPassword = false;
  bool _showConfirm = false;

  static const Color _deepBlue = Color(0xFF0D47A1);

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
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
      ),
    );
  }

  // ✅ Reset Password - CLEAN
  Future<void> _resetPassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final response = await ApiService.resetPassword(
      email: widget.email,
      password: _passwordController.text,
      confirmPassword: _confirmPasswordController.text,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (response.isSuccess) {
      _showSnackBar(response.message, Colors.green);

      await Future.delayed(const Duration(seconds: 1));
      
      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.login,
        (route) => false,
      );
    } else {
      _showSnackBar(response.fullErrorMessage, Colors.red);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Atur Ulang Password'),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: _deepBlue),
        titleTextStyle: const TextStyle(
          color: _deepBlue,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        centerTitle: true,
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
                  'Password Baru',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                Text(
                  'Masukkan kata sandi baru untuk akun ${widget.email}',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 30),

                // 🔒 Password Baru
                TextFormField(
                  controller: _passwordController,
                  obscureText: !_showPassword,
                  decoration: InputDecoration(
                    labelText: 'Password Baru',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _showPassword
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: () =>
                          setState(() => _showPassword = !_showPassword),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: _deepBlue, width: 2),
                    ),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) {
                      return 'Password tidak boleh kosong';
                    }
                    if (v.length < 8) {
                      return 'Password minimal 8 karakter';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // 🔒 Konfirmasi Password
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: !_showConfirm,
                  decoration: InputDecoration(
                    labelText: 'Konfirmasi Password',
                    prefixIcon: const Icon(Icons.lock_reset),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _showConfirm
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: () =>
                          setState(() => _showConfirm = !_showConfirm),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: _deepBlue, width: 2),
                    ),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) {
                      return 'Konfirmasi password tidak boleh kosong';
                    }
                    if (v != _passwordController.text) {
                      return 'Password tidak cocok';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 30),

                // 🔘 Tombol Reset Password
                ElevatedButton(
                  onPressed: _isLoading ? null : _resetPassword,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _deepBlue,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 3,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Reset Password',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
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