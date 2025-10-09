import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int _sectionIndex = 0;

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

  void _changeSection(int idx) => setState(() => _sectionIndex = idx);

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF0A4AE1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        contentPadding: const EdgeInsets.all(20),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.logout_rounded, size: 56, color: Colors.white),
            SizedBox(height: 12),
            Text(
              "Apakah anda yakin ingin keluar?",
              style: TextStyle(color: Colors.white, fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.redAccent,
              shape:
                  RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Logout berhasil")),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0A4AE1),
              shape:
                  RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text("Ya"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar kept minimal to integrate with main app if used standalone
      appBar: AppBar(
        title: const Text('Profil'),
        backgroundColor: const Color(0xFF0A4AE1),
        elevation: 0,
        centerTitle: true,
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _sectionIndex == 0
            ? _buildMainProfile()
            : _sectionIndex == 1
                ? _buildEditProfile()
                : _buildFeedbackForm(),
      ),
    );
  }

  // ================= MAIN PROFILE =================
  Widget _buildMainProfile() {
    return Container(
      key: const ValueKey('mainProfile'),
      // lighter, friendly gradient
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFEAF3FF), Color(0xFFD9E8FF)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // PROFILE CARD (white card for readability)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 6,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const CircleAvatar(
                      radius: 36,
                      backgroundColor: Color(0xFFDDEEFF),
                      child:
                          Icon(Icons.person, size: 40, color: Color(0xFF0A3D91)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text("Andri Yani Meuraxa",
                              style: TextStyle(
                                  color: Colors.black87,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold)),
                          SizedBox(height: 6),
                          Text("yani123@gmail.com",
                              style: TextStyle(color: Colors.black54)),
                        ],
                      ),
                    ),
                    Container(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFE082),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text("Rank #23",
                          style: TextStyle(color: Colors.black87)),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ACTION BUTTONS (white background for contrast)
              _menuButton(
                "Ubah Profil",
                Icons.edit,
                () => _changeSection(1),
                bgColor: Colors.white,
                fgColor: const Color(0xFF0A3D91),
                iconColor: const Color(0xFF0A3D91),
              ),
              _menuButton(
                "Riwayat Penukaran",
                Icons.card_giftcard,
                () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const ProfileRewardScreen()));
                },
                bgColor: Colors.white,
                fgColor: const Color(0xFF0A3D91),
                iconColor: const Color(0xFF0A3D91),
              ),
              _menuButton(
                "Masukan Pengguna",
                Icons.feedback_outlined,
                () => _changeSection(2),
                bgColor: Colors.white,
                fgColor: const Color(0xFF0A3D91),
                iconColor: const Color(0xFF0A3D91),
              ),
              _menuButton(
                "Keluar Akun",
                Icons.logout,
                _showLogoutDialog,
                bgColor: Colors.white,
                fgColor: Colors.redAccent,
                iconColor: Colors.redAccent,
              ),

              const Spacer(),
              // small footer/info
              const Text(
                'PoliSlot • Versi 1.0.0',
                style: TextStyle(color: Colors.black45, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ================= EDIT PROFILE =================
  Widget _buildEditProfile() {
    return Container(
      key: const ValueKey('editProfile'),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFEAF3FF), Color(0xFFD9E8FF)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Row(
              children: [
                IconButton(
                    onPressed: () => _changeSection(0),
                    icon: const Icon(Icons.arrow_back_ios,
                        color: Color(0xFF0A3D91))),
                const SizedBox(width: 6),
                const Text("Ubah Profil",
                    style: TextStyle(color: Color(0xFF0A3D91), fontSize: 18)),
              ],
            ),
            const SizedBox(height: 16),
            Center(
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  const CircleAvatar(
                    radius: 56,
                    backgroundColor: Color(0xFFDDEEFF),
                    child:
                        Icon(Icons.person, size: 60, color: Color(0xFF0A3D91)),
                  ),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                        color: Colors.white, borderRadius: BorderRadius.circular(30)),
                    child: const Icon(Icons.camera_alt, size: 18, color: Color(0xFF0A3D91)),
                  )
                ],
              ),
            ),
            const SizedBox(height: 18),

            _label('Email'),
            _textField(_emailController, hint: 'Email'),

            const SizedBox(height: 12),
            _label('Nama Lengkap'),
            _textField(_nameController, hint: 'Nama'),

            const SizedBox(height: 12),
            _label('Kata Sandi Baru'),
            _textField(_passController, hint: 'Kata Sandi', obscure: true),
            const SizedBox(height: 8),
            _textField(_confirmPassController,
                hint: 'Konfirmasi Kata Sandi', obscure: true),

            const SizedBox(height: 18),
            ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Perubahan disimpan')));
                _changeSection(0);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0A4AE1),
                minimumSize: const Size.fromHeight(50),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              child: const Text('Simpan Perubahan'),
            ),
            const SizedBox(height: 10),
            OutlinedButton(
              onPressed: () => _changeSection(0),
              style: OutlinedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF0A3D91),
                minimumSize: const Size.fromHeight(50),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                side: const BorderSide(color: Color(0xFF0A3D91)),
              ),
              child: const Text('Batal'),
            ),
          ],
        ),
      ),
    );
  }

  // ================= FEEDBACK FORM =================
  Widget _buildFeedbackForm() {
    return Container(
      key: const ValueKey('feedback'),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFEAF3FF), Color(0xFFD9E8FF)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Row(
              children: [
                IconButton(
                    onPressed: () => _changeSection(0),
                    icon:
                        const Icon(Icons.arrow_back_ios, color: Color(0xFF0A3D91))),
                const SizedBox(width: 6),
                const Text("Masukan Pengguna",
                    style: TextStyle(color: Color(0xFF0A3D91), fontSize: 18)),
              ],
            ),
            const SizedBox(height: 12),
            const Text("Berikan Masukan",
                style: TextStyle(
                    color: Color(0xFF0A3D91),
                    fontSize: 18,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),

            _label('Kategori'),
            _dropdownField(kategoriList, _selectedKategori,
                (val) => setState(() => _selectedKategori = val)),

            _label('Jenis Masukan'),
            _dropdownField(jenisList, _selectedJenis,
                (val) => setState(() => _selectedJenis = val)),

            _label('Judul Masukan'),
            _textField(_judulCtrl, hint: 'Judul singkat'),

            const SizedBox(height: 8),
            _label('Deskripsi Detail'),
            _textField(_deskripsiCtrl,
                hint: 'Deskripsikan detail masukan', maxLines: 5),

            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Terima kasih atas masukan Anda')));
                _changeSection(0);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0A4AE1),
                minimumSize: const Size.fromHeight(50),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              child: const Text('Kirim Masukan'),
            ),
            const SizedBox(height: 10),
            OutlinedButton(
              onPressed: () => _changeSection(0),
              style: OutlinedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF0A3D91),
                minimumSize: const Size.fromHeight(50),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                side: const BorderSide(color: Color(0xFF0A3D91)),
              ),
              child: const Text('Kembali'),
            ),
          ],
        ),
      ),
    );
  }

  // ================== HELPERS ==================

  Widget _menuButton(String label, IconData icon, VoidCallback onTap,
      {Color? bgColor, Color? fgColor, Color? iconColor}) {
    final bg = bgColor ?? Colors.white;
    final fg = fgColor ?? Colors.black87;
    final ic = iconColor ?? Colors.black87;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, color: ic),
        label: Text(label, style: TextStyle(color: fg)),
        style: ElevatedButton.styleFrom(
          backgroundColor: bg,
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 0,
        ),
      ),
    );
  }

  Widget _textField(TextEditingController ctrl,
      {String? hint, bool obscure = false, int maxLines = 1}) {
    return TextField(
      controller: ctrl,
      obscureText: obscure,
      maxLines: maxLines,
      style: const TextStyle(color: Colors.black87),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.black38),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      ),
    );
  }

  Widget _dropdownField(List<String> items, String? value, Function(String?) onChanged) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          dropdownColor: Colors.white,
          isExpanded: true,
          icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF0A3D91)),
          style: const TextStyle(color: Colors.black87),
          hint: const Text("Pilih", style: TextStyle(color: Colors.black45)),
          items: items
              .map((item) => DropdownMenuItem(
                    value: item,
                    child: Text(item, style: const TextStyle(color: Colors.black87)),
                  ))
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _label(String text) => Padding(
        padding: const EdgeInsets.only(top: 10, bottom: 6),
        child: Text(text, style: const TextStyle(color: Color(0xFF0A3D91))),
      );
}

// ================== RIWAYAT PENUKARAN ==================
class ProfileRewardScreen extends StatelessWidget {
  const ProfileRewardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appbar keeping brand color
      appBar: AppBar(
        title: const Text('Riwayat Penukaran'),
        backgroundColor: const Color(0xFF0A4AE1),
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFEAF3FF), Color(0xFFD9E8FF)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // saldo card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6)],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [
                    Text('Saldo Poin', style: TextStyle(color: Colors.black54)),
                    SizedBox(height: 6),
                    Text('2400 Poin',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                  ]),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFE082),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.monetization_on, color: Colors.black87, size: 28),
                  )
                ],
              ),
            ),

            const SizedBox(height: 18),

            // animated reward items (lighter cards)
            _rewardCardAnimated(Icons.local_drink, 'Tumbler', 'TOTE-VX229'),
            _rewardCardAnimated(Icons.shopping_bag, 'Tote Bag', 'TOTE-XY206'),
            _rewardCardAnimated(Icons.key, 'Gantungan Kunci', 'KEYC-9823'),
            _rewardCardAnimated(Icons.sticky_note_2, 'Stiker PoliSlot', 'STIK-0012'),

            const SizedBox(height: 18),

            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
              ),
              child: const Text(
                '📦 Pengambilan Hadiah!\nSilakan datang ke pusat informasi dan tunjukkan kode voucher untuk menukarkan merchandise.',
                style: TextStyle(color: Colors.black87),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _rewardCardAnimated(IconData icon, String title, String code) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.9, end: 1.0),
      duration: const Duration(milliseconds: 420),
      builder: (context, v, child) {
        return Transform.scale(
          scale: v,
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0A4AE1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: Colors.white, size: 28),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title,
                          style: const TextStyle(
                              color: Colors.black87, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text('Kode Voucher: $code', style: const TextStyle(color: Colors.black54)),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0A4AE1),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('Tersedia'),
                )
              ],
            ),
          ),
        );
      },
    );
  }
}
