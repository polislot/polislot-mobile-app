// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'mission_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<String> slideTexts = [
    "💪 Ayo klaim validasi harian untuk dapatkan poin!",
    "🔥 Kumpulkan streak untuk jadi pemenang mingguan!",
    "🎯 Selesaikan misi dan rebut posisi top leaderboard!",
  ];

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation =
        CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut);
    _fadeController.forward();

    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 3));
      if (!mounted) return false;
      _currentPage = (_currentPage + 1) % slideTexts.length;
      _pageController.animateToPage(
        _currentPage,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOut,
      );
      return true;
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _showInfoPopup() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("📢 Info Board"),
        content: const Text(
          "Pada Hari Selasa tanggal 08 Oktober akan diberlakukan peraturan berupa wajib helm bagi pengguna motor!!",
          textAlign: TextAlign.justify,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Tutup"),
          ),
        ],
      ),
    );
  }

  // ===================== UI =====================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F6FB),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // ===== HEADER TITLE (match Reward style) =====
                const Padding(
                  padding: EdgeInsets.only(bottom: 14),
                  child: Center(
                    child: Text(
                      "Home",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),

                // ===== GREETING CARD =====
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF0A3D91), Color(0xFF1352C8)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x22000000),
                        blurRadius: 8,
                        offset: Offset(0, 3),
                      )
                    ],
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Hai, Andri Yani 👋",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        height: 40,
                        child: PageView.builder(
                          controller: _pageController,
                          itemCount: slideTexts.length,
                          itemBuilder: (context, index) => Center(
                            child: Text(
                              slideTexts[index],
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 22),

                // ===== INFO BOARD =====
                _animatedCard(
                  delay: 200,
                  child: _customCard(
                    padding: 20,
                    child: GestureDetector(
                      onTap: _showInfoPopup,
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.orange.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.campaign_rounded,
                              color: Colors.orange,
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Text(
                              "Info Board: Aturan wajib helm berlaku mulai 08 Oktober 🚨",
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                          const Icon(Icons.arrow_forward_ios_rounded,
                              size: 18, color: Colors.grey),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 18),

                // ===== MISI HARIAN =====
                _animatedCard(
                  delay: 400,
                  child: _customCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.blue.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.flag_rounded,
                                color: Colors.blue,
                                size: 26,
                              ),
                            ),
                            const SizedBox(width: 10),
                            const Text(
                              "Misi Harian",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _missionTile("🕓 Validasi Pagi", 2 / 3, Colors.blue, "+30"),
                        const SizedBox(height: 10),
                        _missionTile("🔥 Streak Master", 6 / 7, Colors.green, "+70"),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => const MissionScreen()),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1352C8),
                              padding:
                                  const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            icon: const Icon(Icons.play_arrow_rounded,
                                color: Colors.white),
                            label: const Text(
                              "Mulai Validasi",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 18),

                // ===== LEADERBOARD =====
                _animatedCard(
                  delay: 600,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const MissionScreen()),
                      );
                    },
                    child: _customCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.amber.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.leaderboard_rounded,
                                  color: Colors.amber,
                                  size: 26,
                                ),
                              ),
                              const SizedBox(width: 10),
                              const Text(
                                "Peringkat Teratas",
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold),
                              ),
                              const Spacer(),
                              const Icon(Icons.arrow_forward_ios_rounded,
                                  size: 18, color: Colors.grey),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Column(
                            children: List.generate(5, (index) {
                              final rank = index + 1;
                              return _leaderRow(
                                rank.toString(),
                                _leaderData[rank - 1]['name']!,
                                _leaderData[rank - 1]['validasi']!,
                                _leaderData[rank - 1]['color']!,
                              );
                            }),
                          ),
                        ],
                      ),
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

  // ===================== Components =====================
  Widget _animatedCard({required Widget child, required int delay}) {
    return TweenAnimationBuilder(
      tween: Tween(begin: 40.0, end: 0.0),
      duration: Duration(milliseconds: 500 + delay),
      curve: Curves.easeOut,
      builder: (context, value, _) => Transform.translate(
        offset: Offset(0, value),
        child: Opacity(opacity: 1 - (value / 40), child: child),
      ),
    );
  }

  Widget _customCard({required Widget child, double padding = 16}) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Color(0x22000000),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: child,
    );
  }

  static Widget _missionTile(
      String title, double value, Color color, String point) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Text(title,
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w500)),
            ),
            Text(point, style: const TextStyle(color: Colors.black54)),
          ],
        ),
        const SizedBox(height: 6),
        LinearProgressIndicator(
          value: value,
          backgroundColor: Colors.grey[300],
          color: color,
          minHeight: 6,
          borderRadius: BorderRadius.circular(4),
        ),
      ],
    );
  }

  static Widget _leaderRow(
      String rank, String name, String validasi, Color color) {
    IconData icon;
    if (rank == "1") {
      icon = Icons.emoji_events_rounded;
    } else if (rank == "2") {
      icon = Icons.military_tech_rounded;
    } else if (rank == "3") {
      icon = Icons.star_rounded;
    } else {
      icon = Icons.person_outline_rounded;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: color,
            child: Icon(icon, color: Colors.white, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(name,
                style: const TextStyle(
                    fontWeight: FontWeight.w500, color: Colors.black87)),
          ),
          Row(
            children: [
              const Icon(Icons.verified_rounded,
                  color: Colors.blue, size: 18),
              const SizedBox(width: 4),
              Text("$validasi Validasi",
                  style: const TextStyle(
                      fontSize: 13,
                      color: Colors.black54,
                      fontWeight: FontWeight.w500)),
            ],
          ),
        ],
      ),
    );
  }

  static final List<Map<String, dynamic>> _leaderData = [
    {"name": "Andri Yani Meuraxa", "validasi": "98", "color": Colors.amber},
    {"name": "Alndea Resta Amaira", "validasi": "91", "color": Colors.grey},
    {"name": "Ardila Putri", "validasi": "87", "color": Colors.brown},
    {"name": "Rafi Putra", "validasi": "80", "color": Colors.blueAccent},
    {"name": "Nanda Azizah", "validasi": "76", "color": Colors.purpleAccent},
  ];
}
