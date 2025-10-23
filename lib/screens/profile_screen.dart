// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../routes/api_service.dart';
import '../routes/app_routes.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with TickerProviderStateMixin {
  int _sectionIndex = 0;
  File? _selectedImage;
  bool _isLoggingOut = false;

  final TextEditingController _emailController =
      TextEditingController(text: "yani123@gmail.com");
  final TextEditingController _nameController =
      TextEditingController(text: "Andri Yani Meuraxa");
  final TextEditingController _passController = TextEditingController();
  final TextEditingController _confirmPassController = TextEditingController();
  final TextEditingController _judulCtrl = TextEditingController();
  final TextEditingController _deskripsiCtrl = TextEditingController();

  String? _selectedKategori;
  String? _selectedJenis;

  final List<String> kategoriList = [
    'Masukan dari pengguna parkir',
    'Masukan dari penyedia layanan'
  ];
  final List<String> jenisList = [
    'Kendala Teknis',
    'Perilaku',
    'Pengalaman Pengguna',
    'Saran Perbaikan'
  ];

  late final AnimationController _menuAnimCtrl;
  late final List<Animation<double>> _fadeAnims;
  late final List<Animation<Offset>> _slideAnims;

  @override
  void initState() {
    super.initState();
    _menuAnimCtrl =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 800));

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
  }

  @override
  void dispose() {
    _menuAnimCtrl.dispose();
    super.dispose();
  }

  void _changeSection(int idx) => setState(() => _sectionIndex = idx);

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) setState(() => _selectedImage = File(picked.path));
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: const Color(0xFFF3F6FB),
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.warning_amber_rounded,
                  color: Color(0xFF1565C0), size: 50),
              const SizedBox(height: 10),
              const Text("Konfirmasi Logout",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1565C0),
                      fontSize: 18)),
              const SizedBox(height: 10),
              const Text(
                "Apakah Anda yakin ingin keluar dari akun Anda?",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.black87),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFF1565C0), width: 1.5),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      minimumSize: const Size(110, 44),
                    ),
                    child: const Text("Batal",
                        style: TextStyle(color: Color(0xFF1565C0), fontWeight: FontWeight.bold)),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      Navigator.pop(context);
                      await _performLogout();
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
              )
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _performLogout() async {
    if (!mounted) return;
    setState(() => _isLoggingOut = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token') ?? '';

      if (token.isEmpty) {
        await prefs.remove('access_token');
        await prefs.remove('user_data');
        await prefs.setBool('isLoggedIn', false);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Logout berhasil')));
        Navigator.of(context).pushNamedAndRemoveUntil(AppRoutes.login, (route) => false);
        return;
      }

      final responseMap = await ApiService.logout(token);
      final statusCode = responseMap['statusCode'] as int;
      final body = responseMap['body'] as Map<String, dynamic>;

      if (statusCode == 200) {
        await prefs.remove('access_token');
        await prefs.remove('user_data');
        await prefs.setBool('isLoggedIn', false);

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(body['message'] ?? 'Logout berhasil')));
        Navigator.of(context).pushNamedAndRemoveUntil(AppRoutes.login, (route) => false);
        
      } else {
        // --- GAGAL (API Error) ---
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(body['message'] ?? 'Gagal logout')));
        setState(() => _isLoggingOut = false);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal terhubung ke server: $e')));
      setState(() => _isLoggingOut = false);
    } 
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
                icon: const Icon(Icons.arrow_back_ios_new_rounded,
                    color: Colors.white),
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
    final menuItems = [
      ("Ubah Profil", Icons.edit, Colors.blue, () => _changeSection(1)),
      ("Riwayat Penukaran", Icons.card_giftcard, Colors.green, () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ProfileRewardScreen()),
        );
      }),
      ("Masukan Pengguna", Icons.feedback_outlined, Colors.orange,
          () => _changeSection(2)),
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
                BoxShadow(
                    color: Color(0x22000000),
                    blurRadius: 8,
                    offset: Offset(0, 4))
              ],
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 36,
                  backgroundColor: Colors.white.withOpacity(0.3),
                  backgroundImage:
                      _selectedImage != null ? FileImage(_selectedImage!) : null,
                  child: _selectedImage == null
                      ? const Icon(Icons.person,
                          size: 40, color: Colors.white)
                      : null,
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Andri Yani Meuraxa",
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white)),
                      SizedBox(height: 4),
                      Text("yani123@gmail.com",
                          style: TextStyle(color: Colors.white70)),
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

  Widget _menuButton(
      String text, IconData icon, VoidCallback onTap, Color color) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: const [
            BoxShadow(
                color: Color(0x11000000), blurRadius: 8, offset: Offset(0, 3))
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
                  style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                      fontWeight: FontWeight.w500)),
            ),
            const Icon(Icons.arrow_forward_ios,
                color: Colors.black45, size: 18),
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
                backgroundImage:
                    _selectedImage != null ? FileImage(_selectedImage!) : null,
                child: _selectedImage == null
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
                  child:
                      const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                ),
              )
            ],
          ),
        ),
        const SizedBox(height: 20),
        _inputField("Email", _emailController),
        _inputField("Nama Lengkap", _nameController),
        _inputField("Kata Sandi Baru", _passController, obscure: true),
        _inputField("Konfirmasi Kata Sandi", _confirmPassController,
            obscure: true),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: () {
            ScaffoldMessenger.of(context)
                .showSnackBar(const SnackBar(content: Text("Perubahan disimpan")));
            _changeSection(0);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1565C0),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
          child: const Text("Simpan Perubahan",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ),
        const SizedBox(height: 12),
        OutlinedButton(
          onPressed: () => _changeSection(0),
          style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Color(0xFF1565C0), width: 1.5),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(vertical: 14)),
          child: const Text("Batal",
              style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF1565C0),
                  fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }

  Widget _inputField(String label, TextEditingController controller,
      {bool obscure = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                  color: Color(0xFF1565C0), fontWeight: FontWeight.w500)),
          const SizedBox(height: 6),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: const [
                BoxShadow(
                    color: Color(0x11000000),
                    blurRadius: 6,
                    offset: Offset(0, 3))
              ],
            ),
            child: TextField(
              controller: controller,
              obscureText: obscure,
              decoration: const InputDecoration(
                border: InputBorder.none,
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeedbackForm() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text("Masukan Pengguna",
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1565C0))),
        const SizedBox(height: 16),
        _dropdownField("Kategori", kategoriList, _selectedKategori,
            (val) => setState(() => _selectedKategori = val)),
        _dropdownField("Jenis Masukan", jenisList, _selectedJenis,
            (val) => setState(() => _selectedJenis = val)),
        _inputField("Judul Masukan", _judulCtrl),
        _inputField("Deskripsi Detail", _deskripsiCtrl),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: () {
            ScaffoldMessenger.of(context)
                .showSnackBar(const SnackBar(content: Text("Masukan berhasil dikirim")));
            _changeSection(0);
          },
          style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1565C0),
              foregroundColor: Colors.white,
              minimumSize: const Size.fromHeight(50),
              shape:
                  RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
          child: const Text("Kirim Masukan"),
        ),
        const SizedBox(height: 10),
        OutlinedButton(
          onPressed: () => _changeSection(0),
          style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Color(0xFF1565C0), width: 1.5),
              shape:
                  RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              minimumSize: const Size.fromHeight(50)),
          child: const Text("Kembali",
              style: TextStyle(
                  color: Color(0xFF1565C0), fontWeight: FontWeight.bold)),
        )
      ],
    );
  }

  Widget _dropdownField(
      String label, List<String> list, String? value, Function(String?) onChanged) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                  color: Color(0xFF1565C0), fontWeight: FontWeight.w500)),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: const [
                BoxShadow(
                    color: Color(0x11000000),
                    blurRadius: 6,
                    offset: Offset(0, 3))
              ],
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: value,
                isExpanded: true,
                hint: const Text("Pilih"),
                onChanged: onChanged,
                items: list
                    .map((e) =>
                        DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ================= RIWAYAT PENUKARAN =================
class ProfileRewardScreen extends StatefulWidget {
  const ProfileRewardScreen({super.key});

  @override
  State<ProfileRewardScreen> createState() => _ProfileRewardScreenState();
}

class _ProfileRewardScreenState extends State<ProfileRewardScreen> {
  late final List<Map<String, dynamic>> rewards;

  @override
  void initState() {
    super.initState();
    rewards = [
      {"icon": Icons.local_drink, "name": "Tumbler", "code": "TMBL-8273"},
      {"icon": Icons.shopping_bag, "name": "Tote Bag", "code": "TOTE-2931"},
      {"icon": Icons.key, "name": "Gantungan Kunci", "code": "KEYC-9812"},
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F6FB),
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient:
                LinearGradient(colors: [Color(0xFF1565C0), Color(0xFF2196F3)]),
          ),
        ),
        title: const Text("Riwayat Penukaran",
            style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: rewards.length,
        itemBuilder: (context, index) {
          final r = rewards[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 14),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: const [
                BoxShadow(
                    color: Color(0x11000000),
                    blurRadius: 8,
                    offset: Offset(0, 4))
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1565C0).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(r["icon"] as IconData,
                      color: const Color(0xFF1565C0), size: 30),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(r["name"] as String,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.black87)),
                      const SizedBox(height: 4),
                      Text("Kode: ${r["code"]}",
                          style: const TextStyle(
                              color: Colors.black54, fontSize: 13)),
                    ],
                  ),
                ),
                const Icon(Icons.check_circle,
                    color: Colors.green, size: 26),
              ],
            ),
          );
        },
      ),
    );
  }
}