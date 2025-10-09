import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'parkir_screen.dart';

class MissionScreen extends StatefulWidget {
  const MissionScreen({super.key});

  @override
  State<MissionScreen> createState() => _MissionScreenState();
}

class _MissionScreenState extends State<MissionScreen> {
  bool isDaily = true;

  void _showSuggestionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          "Saran Validasi",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text(
          "Pastikan lokasi dan waktu parkir sesuai sebelum melakukan validasi ya 🚗✨",
          textAlign: TextAlign.justify,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Kembali"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ParkirScreen()),
              );
            },
            child: const Text("Lanjut Validasi"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE9EEF6),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text(
          "Misi Pengguna",
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _statCard(isDaily: isDaily),
            const SizedBox(height: 22),
            _missionTabs(),
            const SizedBox(height: 22),
            isDaily ? _dailyMissions() : _weeklyMissions(),
          ],
        ),
      ),
    );
  }

  // ==================== TAB ====================
  Widget _missionTabs() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(color: Color(0x11000000), blurRadius: 6, offset: Offset(0, 3)),
        ],
      ),
      padding: const EdgeInsets.all(10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _missionTab("Misi Harian", isDaily),
          _missionTab("Misi Mingguan", !isDaily),
        ],
      ),
    );
  }

  Widget _missionTab(String title, bool active) {
    return GestureDetector(
      onTap: () => setState(() => isDaily = title == "Misi Harian"),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          gradient: active
              ? const LinearGradient(
                  colors: [Color(0xFF0A3D91), Color(0xFF1352C8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: active ? null : const Color(0xFFF0F0F0),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: active ? Colors.white : Colors.black54,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  // ==================== KARTU STATISTIK ====================
  Widget _statCard({required bool isDaily}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0A3D91), Color(0xFF1352C8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(color: Color(0x330A3D91), blurRadius: 6, offset: Offset(0, 3)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isDaily ? "Statistik Hari Ini!" : "Statistik Mingguan!",
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text("⭐ 2400 Poin", style: TextStyle(color: Colors.white, fontSize: 15)),
              Text("Total Validasi: 70", style: TextStyle(color: Colors.white, fontSize: 15)),
            ],
          ),
          const SizedBox(height: 4),
          const Text("🔥 Streak: 7 Hari", style: TextStyle(color: Colors.white, fontSize: 15)),
        ],
      ),
    );
  }

  // ==================== MISI HARIAN ====================
  Widget _dailyMissions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Misi Harian", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        const SizedBox(height: 14),

        // Tombol validasi di sini 🔥
        GestureDetector(
          onTap: _showSuggestionDialog,
          child: _missionRow("Validasi Parkiran", "+30 poin", 0.66, FontAwesomeIcons.squareCheck),
        ),
        _missionRow("Streak Master", "+50 poin", 0.85, FontAwesomeIcons.fire),

        const SizedBox(height: 22),
        _tipsCard(),
      ],
    );
  }

  // ==================== MISI MINGGUAN ====================
  Widget _weeklyMissions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Misi Mingguan", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        const SizedBox(height: 14),
        _missionRow("Kontributor Hebat", "+300 poin", 0.98, FontAwesomeIcons.award),
        _missionRow("Eksplorer Parkir", "+200 poin", 0.66, FontAwesomeIcons.mapLocationDot),
        const SizedBox(height: 22),
        _tipsCard(),
      ],
    );
  }

  // ==================== ROW MISI ====================
  Widget _missionRow(String title, String point, double progress, IconData icon) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(color: Color(0x11000000), blurRadius: 5, offset: Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF1352C8), size: 26),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: const Color(0xFFE0E0E0),
                    color: const Color(0xFF1352C8),
                    minHeight: 6,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Text(point,
              style: const TextStyle(color: Colors.green, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  // ==================== KARTU TIPS ====================
  Widget _tipsCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFDCE6FA),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Icon(FontAwesomeIcons.lightbulb, color: Color(0xFF1352C8), size: 20),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              "✅ Validasi setiap hari untuk mempertahankan streak\n"
              "🎯 Fokus pada akurasi agar dapat poin bonus\n"
              "🗺️ Kunjungi lokasi berbeda untuk misi eksplorasi",
              style: TextStyle(color: Colors.black87, fontSize: 13, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}
