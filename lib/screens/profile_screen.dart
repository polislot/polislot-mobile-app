// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../routes/api_service.dart';
import '../routes/app_routes.dart';
import '../models/user_reward_model.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with TickerProviderStateMixin {
  int _sectionIndex = 0;
  File? _selectedImage;
  String? _avatarUrl;
  bool _isLoggingOut = false;
  bool _isLoadingProfile = false;
  bool _isUpdatingProfile = false;
  bool _isSubmittingFeedback = false; // ✅ Tambah loading state untuk feedback

  bool _obscureCurrentPass = true;
  bool _obscureNewPass = true;
  bool _obscureConfirmPass = true;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _currentPassController = TextEditingController();
  final TextEditingController _newPassController = TextEditingController();
  final TextEditingController _confirmPassController = TextEditingController();
  final TextEditingController _judulCtrl = TextEditingController();
  final TextEditingController _deskripsiCtrl = TextEditingController();

  String? _selectedKategori;
  String? _selectedJenis;

  // ✅ Update kategori list sesuai kebutuhan
  final List<String> kategoriList = [
    'Masukan dari pengguna parkir',
    'Masukan dari penyedia layanan'
  ];
  
  // ✅ Update jenis list sesuai kebutuhan
  final List<String> jenisList = [
    'Kendala Teknis',
    'Perilaku',
    'Pengalaman Pengguna',
    'Saran Perbaikan',
    'Dan lainnya'
  ];

  late final AnimationController _menuAnimCtrl;
  late final List<Animation<double>> _fadeAnims;
  late final List<Animation<Offset>> _slideAnims;

  @override
  void initState() {
    super.initState();
    _menuAnimCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 3000));

    _fadeAnims = List.generate(4, (i) {
      final start = i * 0.15;
      final end = start + 0.5;
      return CurvedAnimation(
        parent: _menuAnimCtrl,
        curve: Interval(start, end, curve: Curves.easeOut),
      );
    });

    _slideAnims = List.generate(4, (i) {
      final start = i * 0.15;
      final end = start + 0.5;
      return Tween<Offset>(
        begin: const Offset(0, 0.2),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: _menuAnimCtrl,
        curve: Interval(start, end, curve: Curves.easeOutCubic),
      ));
    });

    _menuAnimCtrl.forward();
    _loadProfile();
  }

  @override
  void dispose() {
    _menuAnimCtrl.dispose();
    _emailController.dispose();
    _nameController.dispose();
    _currentPassController.dispose();
    _newPassController.dispose();
    _confirmPassController.dispose();
    _judulCtrl.dispose();
    _deskripsiCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    setState(() => _isLoadingProfile = true);

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token') ?? '';

    final response = await ApiService.getProfile(token);

    if (!mounted) return;
    setState(() => _isLoadingProfile = false);

    if (response.isSuccess) {
      final data = response.data;
      setState(() {
        _nameController.text = data['name'] ?? '';
        _emailController.text = data['email'] ?? '';
        _avatarUrl = data['avatar'];
      });
    } else {
      if (response.statusCode == 401) {
        _showSnackBar('Sesi berakhir. Silakan masuk kembali', Colors.orange);
        await prefs.clear();
        if (!mounted) return;
        Navigator.of(context).pushNamedAndRemoveUntil(
          AppRoutes.login,
          (route) => false,
        );
      } else {
        _showSnackBar(response.message, Colors.red);
      }
    }
  }

  Future<void> _updateProfile() async {
    if (_nameController.text.trim().isEmpty) {
      _showSnackBar('Nama tidak boleh kosong', Colors.orange);
      return;
    }

    if (_newPassController.text.isNotEmpty) {
      if (_currentPassController.text.isEmpty) {
        _showSnackBar('Kata sandi lama harus diisi', Colors.orange);
        return;
      }
      if (_newPassController.text != _confirmPassController.text) {
        _showSnackBar('Konfirmasi kata sandi tidak cocok', Colors.orange);
        return;
      }
    }

    setState(() => _isUpdatingProfile = true);

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token') ?? '';

    final response = await ApiService.updateProfile(
      accessToken: token,
      name: _nameController.text.trim(),
      avatarFile: _selectedImage,
      currentPassword: _currentPassController.text.isNotEmpty
          ? _currentPassController.text
          : null,
      newPassword: _newPassController.text.isNotEmpty
          ? _newPassController.text
          : null,
      confirmPassword: _confirmPassController.text.isNotEmpty
          ? _confirmPassController.text
          : null,
    );

    if (!mounted) return;
    setState(() => _isUpdatingProfile = false);

    if (response.isSuccess) {
      _showSnackBar(response.message, Colors.green);

      _currentPassController.clear();
      _newPassController.clear();
      _confirmPassController.clear();
      _selectedImage = null;
      _obscureCurrentPass = true;
      _obscureNewPass = true;
      _obscureConfirmPass = true;

      await _loadProfile();
      _changeSection(0);
    } else {
      _showSnackBar(response.message, Colors.red);
    }
  }

  // ✅ FUNGSI SUBMIT FEEDBACK DINAMIS
  Future<void> _submitFeedback() async {
    // Validasi
    if (_selectedKategori == null) {
      _showSnackBar('Pilih kategori terlebih dahulu', Colors.orange);
      return;
    }
    if (_selectedJenis == null) {
      _showSnackBar('Pilih jenis masukan terlebih dahulu', Colors.orange);
      return;
    }
    if (_judulCtrl.text.trim().isEmpty) {
      _showSnackBar('Judul masukan tidak boleh kosong', Colors.orange);
      return;
    }

    setState(() => _isSubmittingFeedback = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token') ?? '';

      final response = await ApiService.submitFeedback(
        accessToken: token,
        category: _selectedKategori!,
        feedbackType: _selectedJenis!,
        title: _judulCtrl.text.trim(),
        description: _deskripsiCtrl.text.trim().isNotEmpty 
            ? _deskripsiCtrl.text.trim() 
            : null,
      );

      if (!mounted) return;
      setState(() => _isSubmittingFeedback = false);

      if (response.isSuccess) {
        _showSnackBar(
          response.data?.message ?? 'Masukan berhasil dikirim. Terima kasih!',
          Colors.green,
        );
        
        // Reset form
        setState(() {
          _selectedKategori = null;
          _selectedJenis = null;
          _judulCtrl.clear();
          _deskripsiCtrl.clear();
        });
        
        // Kembali ke menu utama
        _changeSection(0);
      } else {
        _showSnackBar(response.fullErrorMessage, Colors.red);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSubmittingFeedback = false);
      _showSnackBar('Terjadi kesalahan: $e', Colors.red);
    }
  }

  Future<void> _handleLogout() async {
    setState(() => _isLoggingOut = true);

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token') ?? '';

    final response = await ApiService.logout(token);

    if (!mounted) return;
    setState(() => _isLoggingOut = false);

    if (response.isSuccess) {
      await prefs.remove('access_token');
      await prefs.remove('user_data');
      await prefs.setBool('isLoggedIn', false);

      _showSnackBar(response.message, Colors.green);

      if (!mounted) return;
      Navigator.of(context).pushNamedAndRemoveUntil(
        AppRoutes.login,
        (route) => false,
      );
    } else {
      if (response.statusCode == 401) {
        await prefs.clear();
        _showSnackBar("Sesi telah berakhir. Silakan masuk kembali", Colors.orange);

        if (!mounted) return;
        Navigator.of(context).pushNamedAndRemoveUntil(
          AppRoutes.login,
          (route) => false,
        );
      } else {
        _showSnackBar(response.message, Colors.red);
      }
    }
  }

  void _showSnackBar(String message, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: const Color(0xFFF3F6FB),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.logout_rounded, color: Color(0xFF1565C0), size: 50),
              const SizedBox(height: 10),
              const Text(
                "Konfirmasi Logout",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1565C0),
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                "Apakah Anda yakin ingin keluar dari akun Anda?",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.black87),
              ),
              const SizedBox(height: 24),
              _isLoggingOut
                  ? const Padding(
                      padding: EdgeInsets.symmetric(vertical: 10),
                      child: CircularProgressIndicator(
                        color: Color(0xFF1565C0),
                        strokeWidth: 3,
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFF1565C0), width: 1.5),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            minimumSize: const Size(110, 44),
                          ),
                          child: const Text(
                            "Batal",
                            style: TextStyle(color: Color(0xFF1565C0), fontWeight: FontWeight.bold),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () async {
                            Navigator.pop(context);
                            await _handleLogout();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1565C0),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            minimumSize: const Size(110, 44),
                          ),
                          child: const Text("Ya, Keluar"),
                        ),
                      ],
                    ),
            ],
          ),
        ),
      ),
    );
  }

  void _changeSection(int idx) => setState(() => _sectionIndex = idx);

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) setState(() => _selectedImage = File(picked.path));
  }

  @override
  Widget build(BuildContext context) {
    Widget body;
    switch (_sectionIndex) {
      case 1:
        body = _buildEditProfile();
        break;
      case 2:
        body = _buildFeedbackForm();
        break;
      default:
        body = _buildMainProfile();
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF3F6FB),
      appBar: AppBar(
        flexibleSpace: _sectionIndex != 0
            ? Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF1565C0), Color(0xFF2196F3)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                ),
              )
            : null,
        backgroundColor: _sectionIndex == 0 ? Colors.white : null,
        elevation: 2,
        centerTitle: true,
        automaticallyImplyLeading: _sectionIndex != 0,
        leading: _sectionIndex != 0
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
                onPressed: () => _changeSection(0),
              )
            : null,
        title: Text(
          _sectionIndex == 0
              ? 'Profil'
              : _sectionIndex == 1
                  ? 'Ubah Profil'
                  : 'Masukan Pengguna',
          style: TextStyle(
            color: _sectionIndex == 0 ? Colors.black : Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: body,
    );
  }

  Widget _buildMainProfile() {
    if (_isLoadingProfile) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF1565C0), strokeWidth: 3),
      );
    }

    final menuItems = [
      ("Ubah Profil", Icons.edit, Colors.blue, () => _changeSection(1)),
      ("Riwayat Penukaran", Icons.card_giftcard, Colors.green, () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ProfileRewardScreen()),
        );
      }),
      ("Masukan Pengguna", Icons.feedback_outlined, Colors.orange, () => _changeSection(2)),
      ("Keluar Akun", Icons.logout, Colors.redAccent, _showLogoutDialog),
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1565C0), Color(0xFF2196F3)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [
                BoxShadow(color: Color(0x22000000), blurRadius: 8, offset: Offset(0, 4))
              ],
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 36,
                  backgroundColor: Colors.white.withOpacity(0.3),
                  backgroundImage: _avatarUrl != null ? NetworkImage(_avatarUrl!) : null,
                  child: _avatarUrl == null
                      ? const Icon(Icons.person, size: 40, color: Colors.white)
                      : null,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _nameController.text.isNotEmpty ? _nameController.text : "Loading...",
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _emailController.text.isNotEmpty ? _emailController.text : "Loading...",
                        style: const TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          ...List.generate(menuItems.length, (i) {
            final m = menuItems[i];
            return FadeTransition(
              opacity: _fadeAnims[i],
              child: SlideTransition(
                position: _slideAnims[i],
                child: _menuButton(m.$1, m.$2, m.$4, m.$3),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _menuButton(String text, IconData icon, VoidCallback onTap, Color color) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: const [
            BoxShadow(color: Color(0x11000000), blurRadius: 8, offset: Offset(0, 3))
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(text,
                  style: const TextStyle(fontSize: 16, color: Colors.black87, fontWeight: FontWeight.w500)),
            ),
            const Icon(Icons.arrow_forward_ios, color: Colors.black45, size: 18),
          ],
        ),
      ),
    );
  }

  Widget _buildEditProfile() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const SizedBox(height: 10),
        Center(
          child: Stack(
            alignment: Alignment.bottomRight,
            children: [
              CircleAvatar(
                radius: 60,
                backgroundColor: const Color(0xFFEAF3FF),
                backgroundImage: _selectedImage != null
                    ? FileImage(_selectedImage!)
                    : (_avatarUrl != null ? NetworkImage(_avatarUrl!) : null),
                child: _selectedImage == null && _avatarUrl == null
                    ? const Icon(Icons.person, size: 60, color: Color(0xFF1565C0))
                    : null,
              ),
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF1565C0), Color(0xFF2196F3)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                ),
              )
            ],
          ),
        ),
        const SizedBox(height: 20),
        _inputField("Email (tidak dapat diubah)", _emailController, enabled: false),
        _inputField("Nama Lengkap", _nameController),
        const SizedBox(height: 10),
        const Text(
          "Ganti Kata Sandi (Opsional)",
          style: TextStyle(color: Color(0xFF1565C0), fontWeight: FontWeight.bold, fontSize: 15),
        ),
        const SizedBox(height: 10),
        _inputField("Kata Sandi Lama", _currentPassController,
            obscure: _obscureCurrentPass,
            suffixIcon: IconButton(
              icon: Icon(
                _obscureCurrentPass ? Icons.visibility_off : Icons.visibility,
                color: const Color(0xFF1565C0),
              ),
              onPressed: () => setState(() => _obscureCurrentPass = !_obscureCurrentPass),
            )),
        _inputField("Kata Sandi Baru", _newPassController,
            obscure: _obscureNewPass,
            suffixIcon: IconButton(
              icon: Icon(
                _obscureNewPass ? Icons.visibility_off : Icons.visibility,
                color: const Color(0xFF1565C0),
              ),
              onPressed: () => setState(() => _obscureNewPass = !_obscureNewPass),
            )),
        Padding(
          padding: const EdgeInsets.only(top: 4, bottom: 8, left: 15),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Min. 8 karakter, mengandung huruf besar/kecil, angka, dan simbol.',
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
          ),
        ),
        _inputField("Konfirmasi Kata Sandi Baru", _confirmPassController,
            obscure: _obscureConfirmPass,
            suffixIcon: IconButton(
              icon: Icon(
                _obscureConfirmPass ? Icons.visibility_off : Icons.visibility,
                color: const Color(0xFF1565C0),
              ),
              onPressed: () => setState(() => _obscureConfirmPass = !_obscureConfirmPass),
            )),
        const SizedBox(height: 24),
        _isUpdatingProfile
            ? const Center(child: CircularProgressIndicator(color: Color(0xFF1565C0), strokeWidth: 3))
            : ElevatedButton(
                onPressed: _updateProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1565C0),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text("Simpan Perubahan", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
        const SizedBox(height: 12),
        OutlinedButton(
          onPressed: () => _changeSection(0),
          style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Color(0xFF1565C0), width: 1.5),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(vertical: 14)),
          child: const Text("Batal",
              style: TextStyle(fontSize: 16, color: Color(0xFF1565C0), fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }

  Widget _inputField(String label, TextEditingController controller,
      {bool obscure = false, bool enabled = true, Widget? suffixIcon}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Color(0xFF1565C0), fontWeight: FontWeight.w500)),
          const SizedBox(height: 6),
          Container(
            decoration: BoxDecoration(
              color: enabled ? Colors.white : Colors.grey.shade200,
              borderRadius: BorderRadius.circular(12),
              boxShadow: const [
                BoxShadow(color: Color(0x11000000), blurRadius: 6, offset: Offset(0, 3))
              ],
            ),
            child: TextField(
              controller: controller,
              obscureText: obscure,
              enabled: enabled,
              decoration: InputDecoration(
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                suffixIcon: suffixIcon,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ✅ FORM FEEDBACK DENGAN INTEGRASI API
  Widget _buildFeedbackForm() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text(
          "Masukan Pengguna",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1565C0),
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          "Sampaikan masukan, saran, atau keluhan Anda kepada kami",
          style: TextStyle(color: Colors.black54, fontSize: 13),
        ),
        const SizedBox(height: 20),
        
        // Dropdown Kategori
        _dropdownField(
          "Kategori",
          kategoriList,
          _selectedKategori,
          (val) => setState(() => _selectedKategori = val),
        ),
        
        // Dropdown Jenis
        _dropdownField(
          "Jenis Masukan",
          jenisList,
          _selectedJenis,
          (val) => setState(() => _selectedJenis = val),
        ),
        
        // Input Judul
        _inputField("Judul Masukan", _judulCtrl),
        
        // Input Deskripsi dengan maxLines
        Container(
          margin: const EdgeInsets.only(bottom: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Deskripsi Detail (Opsional)",
                style: TextStyle(
                  color: Color(0xFF1565C0),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 6),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x11000000),
                      blurRadius: 6,
                      offset: Offset(0, 3),
                    )
                  ],
                ),
                child: TextField(
                  controller: _deskripsiCtrl,
                  maxLines: 5,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    hintText: 'Jelaskan masukan Anda secara detail...',
                    hintStyle: TextStyle(color: Colors.black38),
                  ),
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 20),
        
        // Tombol Kirim dengan Loading State
        _isSubmittingFeedback
            ? const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFF1565C0),
                  strokeWidth: 3,
                ),
              )
            : ElevatedButton(
                onPressed: _submitFeedback,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1565C0),
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  "Kirim Masukan",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
        
        const SizedBox(height: 10),
        
        // Tombol Batal
        OutlinedButton(
          onPressed: () => _changeSection(0),
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: Color(0xFF1565C0), width: 1.5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            minimumSize: const Size.fromHeight(50),
          ),
          child: const Text(
            "Kembali",
            style: TextStyle(
              color: Color(0xFF1565C0),
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      ],
    );
  }

  Widget _dropdownField(String label, List<String> list, String? value, Function(String?) onChanged) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Color(0xFF1565C0), fontWeight: FontWeight.w500)),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: const [
                BoxShadow(color: Color(0x11000000), blurRadius: 6, offset: Offset(0, 3))
              ],
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: value,
                isExpanded: true,
                hint: const Text("Pilih"),
                onChanged: onChanged,
                items: list.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ================= RIWAYAT PENUKARAN (DINAMIS) =================
class ProfileRewardScreen extends StatefulWidget {
  const ProfileRewardScreen({super.key});

  @override
  State<ProfileRewardScreen> createState() => _ProfileRewardScreenState();
}

class _ProfileRewardScreenState extends State<ProfileRewardScreen> {
  List<UserReward> myRewards = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadMyRewards();
  }

  Future<void> _loadMyRewards() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final token = await ApiService.getToken();
      if (token == null) {
        setState(() {
          errorMessage = 'Token tidak ditemukan. Silakan login kembali.';
          isLoading = false;
        });
        return;
      }

      final response = await ApiService.getMyRewards(token);

      if (!mounted) return;

      if (response.isSuccess && response.data != null) {
        setState(() {
          myRewards = response.data!;
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = response.message;
          isLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        errorMessage = 'Gagal memuat riwayat: $e';
        isLoading = false;
      });
    }
  }

  IconData _getIconForReward(String name) {
    final lowerName = name.toLowerCase();
    if (lowerName.contains('tumbler') || lowerName.contains('botol')) {
      return Icons.local_drink;
    } else if (lowerName.contains('bag') || lowerName.contains('tas')) {
      return Icons.shopping_bag;
    } else if (lowerName.contains('key') || lowerName.contains('gantungan')) {
      return Icons.key;
    } else if (lowerName.contains('voucher') || lowerName.contains('diskon')) {
      return Icons.card_giftcard;
    }
    return Icons.card_giftcard;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F6FB),
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(colors: [Color(0xFF1565C0), Color(0xFF2196F3)]),
          ),
        ),
        title: const Text("Riwayat Penukaran",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: RefreshIndicator(
        onRefresh: _loadMyRewards,
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF1565C0)),
      );
    }

    if (errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 60, color: Colors.redAccent),
              const SizedBox(height: 16),
              Text(
                errorMessage!,
                style: const TextStyle(color: Colors.redAccent, fontSize: 14),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadMyRewards,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1565C0),
                  foregroundColor: Colors.white,
                ),
                child: const Text("Coba Lagi"),
              ),
            ],
          ),
        ),
      );
    }

    if (myRewards.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history, size: 60, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              "Belum ada riwayat penukaran",
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: myRewards.length,
      itemBuilder: (context, index) {
        final r = myRewards[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 14),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: const [
              BoxShadow(color: Color(0x11000000), blurRadius: 8, offset: Offset(0, 4))
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF1565C0).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(_getIconForReward(r.rewardName),
                    color: const Color(0xFF1565C0), size: 30),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(r.rewardName,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.black87)),
                    const SizedBox(height: 4),
                    Text("Kode: ${r.voucherCode}",
                        style: const TextStyle(color: Colors.black54, fontSize: 13)),
                    const SizedBox(height: 8),
                    // Info Ditukar
                    Row(
                      children: [
                        const Icon(Icons.swap_horiz, size: 14, color: Colors.black54),
                        const SizedBox(width: 4),
                        Text("Ditukar: ${r.exchangedAt}",
                            style: const TextStyle(color: Colors.black54, fontSize: 12)),
                      ],
                    ),
                    // Info Dipakai (jika sudah dipakai)
                    if (r.isUsed && r.usedAt != null) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.check_circle, size: 14, color: Colors.green),
                          const SizedBox(width: 4),
                          Text("Dipakai: ${r.usedAt}",
                              style: const TextStyle(color: Colors.green, fontSize: 12)),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              Icon(
                r.isUsed ? Icons.check_circle : Icons.hourglass_top,
                color: r.isUsed ? Colors.green : Colors.orange,
                size: 26,
              ),
            ],
          ),
        );
      },
    );
  }
}