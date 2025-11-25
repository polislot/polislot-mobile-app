import 'dart:math';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../routes/api_service.dart';
import '../models/leaderboard_user.dart';
import 'parkir_screen.dart';

class MissionScreen extends StatefulWidget {
  final bool initialTabIsMission;

  const MissionScreen({
    super.key,
    this.initialTabIsMission = true,
  });

  @override
  State<MissionScreen> createState() => _MissionScreenState();
}

class _MissionScreenState extends State<MissionScreen>
    with SingleTickerProviderStateMixin {
  late bool isMissionTab;

  // ANIMATION
  late AnimationController _animController;
  late Animation<double> _validasiAnim;
  late Animation<double> _koinAnim;

  // STATIC (VALIDASI)
  int totalValidasi = 24;

  // API VALUES
  int totalPoints = 0;
  bool loadingTier = true;
  bool loadingLeaderboard = true;
  String? currentUserId;

  List<LeaderboardUser> leaderboard = [];

  @override
  void initState() {
    super.initState();

    isMissionTab = widget.initialTabIsMission;

    // ANIMATION INITIAL
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _validasiAnim = Tween<double>(begin: 0, end: totalValidasi.toDouble())
        .animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));

    _koinAnim = Tween<double>(begin: 0, end: 0)
        .animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));

    _loadTier();
    _loadLeaderboard();
  }

  Future<void> _loadTier() async {
    final token = await ApiService.getToken();
    if (token == null) return;

    final res = await ApiService.getUserTier(token);

    if (res.isSuccess && res.data != null) {
      print('=== USER TIER DATA ===');
      print('ID: ${res.data!.id}');
      print('Lifetime Points: ${res.data!.lifetimePoints}');
      print('======================');
      
      setState(() {
        totalPoints = res.data!.lifetimePoints;

        if (res.data!.id != null) {
          currentUserId = res.data!.id.toString();
          print('✅ Current User ID set to: $currentUserId');
        } else {
          print('❌ res.data!.id is NULL!');
        }

        _koinAnim = Tween<double>(begin: 0, end: totalPoints.toDouble())
            .animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));

        loadingTier = false;
      });

      _animController.forward();
    }
  }

  Future<void> _loadLeaderboard() async {
    final token = await ApiService.getToken();

    if (token == null) return;

    final res = await ApiService.getLeaderboard(token);

    if (res.isSuccess && res.data != null) {
      setState(() {
        leaderboard = res.data!;
        loadingLeaderboard = false;
      });
    }
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
          const AreaParkirScreen(),
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
    final slide = Tween<Offset>(begin: Offset(0, offsetY), end: Offset.zero)
        .animate(CurvedAnimation(
      parent: _animController,
      curve: Interval(min(1, index * 0.1), 1.0, curve: Curves.easeOut),
    ));
    final fade =
        CurvedAnimation(parent: _animController, curve: Curves.easeIn);

    return SlideTransition(
      position: slide,
      child: FadeTransition(opacity: fade, child: child),
    );
  }

  // STATIC MISSIONS
  final List<Map<String, dynamic>> _missions = [
    {
      "title": "Validasi Parkiran",
      "points": "+30 poin",
      "desc":
          "Selesaikan 3 kali validasi lokasi parkir hari ini untuk bonus tambahan.",
      "progress": 0.66,
      "icon": FontAwesomeIcons.squareCheck,
      "color": const Color(0xFF1352C8),
    },
    {
      "title": "Streak Master",
      "points": "+50 poin",
      "desc":
          "Pertahankan streak validasi selama 7 hari berturut-turut untuk poin ekstra.",
      "progress": 0.85,
      "icon": FontAwesomeIcons.fire,
      "color": Colors.orange,
    },
    {
      "title": "Kontributor Hebat",
      "points": "+300 poin",
      "desc":
          "Lengkapi 10 validasi selama minggu ini untuk jadi kontributor terbaik.",
      "progress": 0.98,
      "icon": FontAwesomeIcons.award,
      "color": Colors.amber,
    },
    {
      "title": "Eksplorer Parkir",
      "points": "+200 poin",
      "desc":
          "Temukan dan validasi 5 area parkir baru selama minggu ini.",
      "progress": 0.66,
      "icon": FontAwesomeIcons.mapLocationDot,
      "color": Colors.green,
    },
  ];

  @override
  Widget build(BuildContext context) {
    // Cari ranking user saat ini untuk card fixed
    int? currentUserRank;
    LeaderboardUser? currentUser;
    
    if (!isMissionTab) {
      for (int i = 0; i < leaderboard.length; i++) {
        if (currentUserId != null && leaderboard[i].id.toString() == currentUserId) {
          currentUserRank = i + 1;
          currentUser = leaderboard[i];
          break;
        }
      }
    }

    return Scaffold(
      backgroundColor: const Color(0xFFE9EEF6),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        centerTitle: true,
        title: const Text(
          "Misi & Leaderboard",
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Stack(
        children: [
          // MAIN CONTENT
          loadingTier
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(18),
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _fadeSlide(_topStatsCard(), 0),
                      const SizedBox(height: 16),
                      _fadeSlide(_animatedTabs(), 1),
                      const SizedBox(height: 20),
                      _fadeSlide(
                        isMissionTab ? _allMissions() : _leaderboard(),
                        2,
                        offsetY: 0.12,
                      ),
                    ],
                  ),
                ),
          
          // FIXED CARD POSISI USER (hanya muncul di tab leaderboard)
          if (!isMissionTab && !loadingLeaderboard)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: _buildUserPositionCard(currentUserRank, currentUser),
            ),
        ],
      ),
    );
  }

  // === CARD STATISTIK ===
  Widget _topStatsCard() {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1565C0), Color(0xFF2196F3)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
              color: Color(0x33000000), blurRadius: 10, offset: Offset(0, 4))
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
              title: "Total Poin",
              value: _koinAnim.value.toInt().toString(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statBox({
    required IconData icon,
    required Color color,
    required String title,
    required String value,
  }) {
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
          style:
              TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 13),
        ),
      ],
    );
  }

  // === TABS ===
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
                  colors: [Color(0xFF1565C0), Color(0xFF2196F3)],
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

  // Helper untuk membuat teks judul Tier dengan garis horizontal
  Widget _buildTierHeader(String title) {
    return Row(
      children: [
        const Expanded(
          child: Divider(
            color: Color(0xFFE0E0E0), // Warna abu-abu soft
            thickness: 1.5,
            endIndent: 10,
          ),
        ),
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Colors.black54, // Warna yang lebih soft dari hitam pekat
          ),
        ),
        const Expanded(
          child: Divider(
            color: Color(0xFFE0E0E0),
            thickness: 1.5,
            indent: 10,
          ),
        ),
      ],
    );
  }


  // === LEADERBOARD ===
  Widget _leaderboard() {
    if (loadingLeaderboard) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(40),
          child: CircularProgressIndicator(),
        ),
      );
    }

    // Cari ranking user saat ini
    int? currentUserRank;
    LeaderboardUser? currentUser;
    for (int i = 0; i < leaderboard.length; i++) {
      if (currentUserId != null && leaderboard[i].id.toString() == currentUserId) {
        currentUserRank = i + 1;
        currentUser = leaderboard[i];
        break;
      }
    }

    // Ambil top 3
    final top3 = leaderboard.take(3).toList();
    
    // Ambil sisanya (rank 4-10 dst)
    final restOfLeaderboard = leaderboard.skip(3).take(7).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // TOP 3 PODIUM
        if (top3.isNotEmpty) _buildPodium(top3),
        
        const SizedBox(height: 16),
        
        // PERINGKAT LAINNYA
        if (restOfLeaderboard.isNotEmpty) ...[
          _buildTierHeader("Peringkat 4-10"),
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
            child: Column(
              children: [
                for (int i = 0; i < restOfLeaderboard.length; i++)
                  _modernLeaderboardTile(i + 3, restOfLeaderboard[i], i < restOfLeaderboard.length - 1),
              ],
            ),
          ),
        ],
        
        const SizedBox(height: 80), // Beri space untuk fixed card di bawah
      ],
    );
  }

  // PODIUM TOP 3
  Widget _buildPodium(List<LeaderboardUser> top3) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // RANK 2 (Kiri)
          if (top3.length > 1)
            Expanded(child: _podiumItem(top3[1], 2, 140, Colors.grey.shade400)),
          
          const SizedBox(width: 8),
          
          // RANK 1 (Tengah)
          Expanded(child: _podiumItem(top3[0], 1, 180, Colors.amber)),
          
          const SizedBox(width: 8),
          
          // RANK 3 (Kanan)
          if (top3.length > 2)
            Expanded(child: _podiumItem(top3[2], 3, 110, Colors.brown.shade400)),
        ],
      ),
    );
  }

  Widget _podiumItem(LeaderboardUser user, int rank, double height, Color color) {
    IconData icon;
    if (rank == 1) icon = Icons.emoji_events;
    else if (rank == 2) icon = Icons.military_tech;
    else icon = Icons.star;

    final bool isCurrentUser = currentUserId != null && user.id.toString() == currentUserId;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // AVATAR & CROWN
        CircleAvatar(
          radius: rank == 1 ? 36 : 30,
          backgroundColor: color.withOpacity(0.2),
          child: Icon(
            icon,
            color: color,
            size: rank == 1 ? 36 : 28,
          ),
        ),
        const SizedBox(height: 8),
        
        // NAMA
        Text(
          user.name ?? "-",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontWeight: isCurrentUser ? FontWeight.bold : FontWeight.w600,
            fontSize: 13,
            color: isCurrentUser ? const Color(0xFF1352C8) : Colors.black87,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        
        const SizedBox(height: 4),
        
        // POIN
        Text(
          "${user.lifetimePoints}",
          style: TextStyle(
            fontSize: 12,
            color: Colors.black54,
            fontWeight: FontWeight.bold,
          ),
        ),
        
        const SizedBox(height: 12),
        
        // PODIUM BOX
        Container(
          width: double.infinity,
          height: height,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [color, color.withOpacity(0.6)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: Text(
              "#$rank",
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // CARD POSISI USER (Fixed di bawah)
  Widget _buildUserPositionCard(int? rank, LeaderboardUser? user) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1565C0), Color(0xFF2196F3)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x55000000),
            blurRadius: 12,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          // RANK NUMBER
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.25),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                rank != null ? "#$rank" : "#?",
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          
          const SizedBox(width: 16),
          
          // USER INFO
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Anda",
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white70,
                  ),
                ),
                Text(
                  user?.name ?? "-",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                // Menggunakan user?.lifetimePoints jika tersedia, atau totalPoints
                Text(
                  "${user?.lifetimePoints ?? totalPoints} Poin", 
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          
          // ICON
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.person,
              color: Colors.white,
              size: 28,
            ),
          ),
        ],
      ),
    );
  }

  // LEADERBOARD TILE (untuk rank 4 dst) - MODERN
  Widget _modernLeaderboardTile(int index, LeaderboardUser user, [bool hasDivider = true]) {
    final rank = index + 1;
    final bool isCurrentUser = currentUserId != null && user.id.toString() == currentUserId;
    final Color highlightColor = const Color(0xFF1352C8);

    // KONTROL UKURAN BULATAN
    const double chipSize = 40.0;
    const double rankFontSize = 15.0;

    final Widget tile = Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: isCurrentUser ? highlightColor.withOpacity(0.12) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        boxShadow: isCurrentUser
            ? [
                BoxShadow(
                  color: highlightColor.withOpacity(0.15),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              ]
            : null,
      ),
      child: Row(
        children: [
          // RANK NUMBER (Bulatan/Chip)
          Container(
            width: chipSize,
            height: chipSize,
            decoration: BoxDecoration(
              color: isCurrentUser ? highlightColor : const Color(0xFFE9EEF6),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                "#$rank",
                style: TextStyle(
                  fontSize: rankFontSize,
                  fontWeight: FontWeight.bold,
                  color: isCurrentUser ? Colors.white : highlightColor,
                ),
              ),
            ),
          ),
          
          const SizedBox(width: 14),

          // USER INFO
          Expanded(
            child: Text(
              user.name ?? "-",
              style: TextStyle(
                fontWeight: isCurrentUser ? FontWeight.w800 : FontWeight.w600,
                fontSize: 15,
                color: isCurrentUser ? highlightColor : Colors.black87,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          // POIN (DENGAN IKON)
          Row(
            children: [
              Icon(
                Icons.monetization_on, // 👈 IKON BARU DITAMBAHKAN
                size: 18,
                color: isCurrentUser ? highlightColor : Colors.orange.shade700,
              ),
              const SizedBox(width: 4),
              Text(
                "${user.lifetimePoints} Poin",
                style: TextStyle(
                  color: isCurrentUser ? highlightColor : Colors.black54,
                  fontWeight: isCurrentUser ? FontWeight.bold : FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ],
      ),
    );

    // Tambahkan Divider jika tidak di item terakhir
    if (hasDivider) { 
      return Column(
        children: [
          tile,
          const Divider(height: 1, thickness: 0.8, color: Color(0xFFE9EEF6)),
        ],
      );
    }

    return tile;
  }

  // === MISI ===
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
        boxShadow: const [
          BoxShadow(color: Color(0x11000000), blurRadius: 5)
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(m['icon'] as IconData,
                  color: m['color'] as Color, size: 26),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  m['title'] as String,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 15),
                ),
              ),
              Text(
                m['points'] as String,
                style: const TextStyle(
                    color: Colors.green, fontWeight: FontWeight.w600),
              ),
            ],
          ),
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
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            icon: const Icon(Icons.play_arrow_rounded, color: Colors.white),
            label: const Text(
              "Mulai Validasi",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}