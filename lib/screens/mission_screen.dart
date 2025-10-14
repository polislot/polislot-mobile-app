import 'dart:math';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'parkir_screen.dart';

class MissionScreen extends StatefulWidget {
  const MissionScreen({super.key});

  @override
  State<MissionScreen> createState() => _MissionScreenState();
}

class _MissionScreenState extends State<MissionScreen>
    with SingleTickerProviderStateMixin {
  bool isMissionTab = true;
  late AnimationController _animController;
  late Animation<double> _validasiAnim;
  late Animation<double> _koinAnim;

  int totalValidasi = 24;
  int totalKoin = 480;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _validasiAnim =
        Tween<double>(begin: 0, end: totalValidasi.toDouble()).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOut),
    );

    _koinAnim = Tween<double>(begin: 0, end: totalKoin.toDouble()).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOut),
    );

    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _navigateToParkir() {
    Navigator.of(context).push(_createRoute());
  }

  Route _createRoute() {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) =>
          const ParkirFullScreen(),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final fade = CurvedAnimation(parent: animation, curve: Curves.easeInOut);
        final slide = Tween<Offset>(
          begin: const Offset(0, 0.2),
          end: Offset.zero,
        ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOut));
        return FadeTransition(
          opacity: fade,
          child: SlideTransition(position: slide, child: child),
        );
      },
      transitionDuration: const Duration(milliseconds: 500),
    );
  }

  Widget _fadeSlide(Widget child, int index, {double offsetY = 0.08}) {
    final Animation<Offset> slide =
        Tween<Offset>(begin: Offset(0, offsetY), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _animController,
        curve: Interval(min(1, index * 0.1), 1.0, curve: Curves.easeOut),
      ),
    );
    final Animation<double> fade =
        CurvedAnimation(parent: _animController, curve: Curves.easeIn);

    return SlideTransition(
      position: slide,
      child: FadeTransition(opacity: fade, child: child),
    );
  }

  final List<Map<String, dynamic>> _missions = [
    {
      "title": "Validasi Parkiran",
      "points": "+30 poin",
      "desc": "Selesaikan 3 kali validasi lokasi parkir hari ini untuk bonus tambahan.",
      "progress": 0.66,
      "icon": FontAwesomeIcons.squareCheck,
      "color": Color(0xFF1352C8),
    },
    {
      "title": "Streak Master",
      "points": "+50 poin",
      "desc": "Pertahankan streak validasi selama 7 hari berturut-turut untuk poin ekstra.",
      "progress": 0.85,
      "icon": FontAwesomeIcons.fire,
      "color": Colors.orange,
    },
    {
      "title": "Kontributor Hebat",
      "points": "+300 poin",
      "desc": "Lengkapi 10 validasi selama minggu ini untuk jadi kontributor terbaik.",
      "progress": 0.98,
      "icon": FontAwesomeIcons.award,
      "color": Colors.amber,
    },
    {
      "title": "Eksplorer Parkir",
      "points": "+200 poin",
      "desc": "Temukan dan validasi 5 area parkir baru selama minggu ini.",
      "progress": 0.66,
      "icon": FontAwesomeIcons.mapLocationDot,
      "color": Colors.green,
    },
  ];

  final List<Map<String, dynamic>> _leaderboardData = List.generate(
    20,
    (i) => {
      "name": [
        "Andri Yani Meuraxa",
        "Alndea Resta Amaira",
        "Ardila Putri",
        "Rafi Putra",
        "Nanda Azizah",
        "Dimas Hidayat",
        "Putri Maharani",
        "Rizki Fadillah",
        "Aulia Rahman",
        "Febrianti Sari",
        "Bayu Saputra",
        "Tania Marlina",
        "Yusuf Alamsyah",
        "Citra Ayu",
        "Wahyu Nugraha",
        "Lina Oktaviani",
        "Fajar Ramadhan",
        "Siska Amelia",
        "Gilang Permana",
        "Rara Nurhaliza"
      ][i],
      "validasi": 98 - i * 2,
    },
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE9EEF6),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        centerTitle: true,
        title: const Text(
          "Misi & Leaderboard",
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _fadeSlide(_topStatsCard(), 0),
            const SizedBox(height: 16),
            _fadeSlide(_animatedTabs(), 1),
            const SizedBox(height: 20),
            _fadeSlide(isMissionTab ? _allMissions() : _leaderboard(), 2,
                offsetY: 0.12),
          ],
        ),
      ),
    );
  }

  // === CARD DENGAN ANIMASI COUNT-UP ===
  Widget _topStatsCard() {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0.8, end: 1.0),
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOutBack,
      builder: (context, scale, _) {
        return Transform.scale(
          scale: scale,
          child: Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0A3D91), Color(0xFF1352C8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(18),
              boxShadow: const [
                BoxShadow(color: Color(0x33000000), blurRadius: 10, offset: Offset(0, 4))
              ],
            ),
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                AnimatedBuilder(
                  animation: _validasiAnim,
                  builder: (context, child) => _statBox(
                    icon: Icons.verified_rounded,
                    color: Colors.amber,
                    title: "Total Validasi",
                    value: _validasiAnim.value.toInt().toString(),
                  ),
                ),
                AnimatedBuilder(
                  animation: _koinAnim,
                  builder: (context, child) => _statBox(
                    icon: Icons.monetization_on_rounded,
                    color: Colors.greenAccent,
                    title: "Total Koin",
                    value: _koinAnim.value.toInt().toString(),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _statBox(
      {required IconData icon,
      required Color color,
      required String title,
      required String value}) {
    return Column(
      children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.white,
          ),
        ),
        Text(
          title,
          style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 13),
        ),
      ],
    );
  }

  // === ANIMATED TAB BUTTONS ===
  Widget _animatedTabs() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _animatedTab("Misi", Icons.flag_rounded, isMissionTab),
        _animatedTab("Leaderboard", Icons.emoji_events_rounded, !isMissionTab),
      ],
    );
  }

  Widget _animatedTab(String title, IconData icon, bool active) {
    return GestureDetector(
      onTap: () => setState(() => isMissionTab = title == "Misi"),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 12),
        decoration: BoxDecoration(
          gradient: active
              ? const LinearGradient(
                  colors: [Color(0xFF0A3D91), Color(0xFF1352C8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: active ? null : Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            if (active)
              const BoxShadow(
                color: Color(0x33000000),
                blurRadius: 8,
                offset: Offset(0, 3),
              ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon,
                color: active ? Colors.white : const Color(0xFF1352C8),
                size: 20),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: active ? Colors.white : Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // === Misi ===
  Widget _allMissions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Daftar Misi Kamu",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        const SizedBox(height: 14),
        for (int i = 0; i < _missions.length; i++)
          _fadeSlide(_missionCard(i, _missions[i]), i + 1),
      ],
    );
  }

  Widget _missionCard(int index, Map<String, dynamic> m) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [BoxShadow(color: Color(0x11000000), blurRadius: 5)],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(m['icon'] as IconData, color: m['color'] as Color, size: 26),
          const SizedBox(width: 10),
          Expanded(
            child: Text(m['title'] as String,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          ),
          Text(m['points'] as String,
              style: const TextStyle(color: Colors.green, fontWeight: FontWeight.w600))
        ]),
        const SizedBox(height: 8),
        Text(m['desc'] as String,
            style: const TextStyle(color: Colors.black54, fontSize: 13)),
        const SizedBox(height: 10),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: m['progress'] as double,
            backgroundColor: const Color(0xFFE0E0E0),
            color: m['color'] as Color,
            minHeight: 6,
          ),
        ),
        const SizedBox(height: 12),
        ElevatedButton.icon(
          onPressed: _navigateToParkir,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1352C8),
            minimumSize: const Size(double.infinity, 42),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          icon: const Icon(Icons.play_arrow_rounded, color: Colors.white),
          label:
              const Text("Mulai Validasi", style: TextStyle(color: Colors.white)),
        ),
      ]),
    );
  }

  // === Leaderboard ===
  Widget _leaderboard() {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0.9, end: 1.0),
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutBack,
      builder: (context, scale, _) => Transform.scale(
        scale: scale,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Peringkat Teratas",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(color: Color(0x11000000), blurRadius: 6)
                ],
              ),
              child: ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _leaderboardData.length,
                itemBuilder: (context, index) {
                  final user = _leaderboardData[index];
                  final rank = index + 1;
                  Color badgeColor;
                  IconData icon;

                  if (rank == 1) {
                    badgeColor = Colors.amber;
                    icon = Icons.emoji_events;
                  } else if (rank == 2) {
                    badgeColor = Colors.grey;
                    icon = Icons.military_tech;
                  } else if (rank == 3) {
                    badgeColor = Colors.brown;
                    icon = Icons.star;
                  } else {
                    badgeColor = Colors.primaries[index % Colors.primaries.length];
                    icon = Icons.person;
                  }

                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: badgeColor.withOpacity(0.15),
                      child: Icon(icon, color: badgeColor),
                    ),
                    title: Text(user['name'],
                        style: const TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 15)),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.verified, color: badgeColor, size: 18),
                        const SizedBox(width: 4),
                        Text("${user['validasi']} Validasi",
                            style: const TextStyle(color: Colors.black87)),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
