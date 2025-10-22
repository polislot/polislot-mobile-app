import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

// pastikan semua file ini ada di folder lib/
import 'home_screen.dart';
import 'mission_screen.dart';
import 'parkir_screen.dart';
import 'reward_screen.dart';
import 'profile_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen>
    with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;

  // daftar halaman
  final List<Widget> _pages = const [
    HomeScreen(),
    MissionScreen(),
    AreaParkirScreen(),
    RewardScreen(),
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOutCubic,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTabChanged(int index) {
    if (index == _selectedIndex) return;
    _controller.reverse().then((_) {
      if (mounted) {
        setState(() => _selectedIndex = index);
        _controller.forward();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F6FB),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: IndexedStack(
          index: _selectedIndex,
          children: _pages,
        ),
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              blurRadius: 10,
              color: Color.fromARGB(40, 0, 0, 0),
              offset: Offset(0, -3),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            child: GNav(
              gap: 8,
              color: Color(0xFF5A6BB5), // ikon & teks nonaktif lembut
              activeColor: Colors.white,
              textStyle: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 13.5,
              ),
              iconSize: 24,
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 9),
              duration: const Duration(milliseconds: 300),
              tabBackgroundGradient: const LinearGradient(
                colors: [
                  Color(0xFF1565C0),
                  Color(0xFF2196F3),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              tabs: const [
                GButton(icon: Icons.home_rounded, text: 'Home'),
                GButton(icon: Icons.flag_outlined, text: 'Misi'),
                GButton(icon: Icons.local_parking_rounded, text: 'Parkir'),
                GButton(icon: Icons.card_giftcard_rounded, text: 'Reward'),
                GButton(icon: Icons.person_outline_rounded, text: 'Profil'),
              ],
              selectedIndex: _selectedIndex,
              onTabChange: _onTabChanged,
            ),
          ),
        ),
      ),
    );
  }
}