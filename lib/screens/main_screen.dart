import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
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

  final List<Widget> _pages = const [
    HomeScreen(),
    MissionScreen(),
    ParkirFullScreen(),
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
      setState(() => _selectedIndex = index);
      _controller.forward();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
            padding: const EdgeInsets.symmetric(
              horizontal: 14, // ✅ sedikit lebih kecil
              vertical: 6, // ✅ fix overflow di semua layar
            ),
            child: GNav(
              gap: 8,
              backgroundColor: Colors.white,
              color: const Color(0xFF1352C8), // ikon & teks default biru
              activeColor: Colors.white, // ikon & teks aktif putih
              textStyle: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 13.5,
              ),
              iconSize: 25,
              padding: const EdgeInsets.symmetric(
                horizontal: 15,
                vertical: 9,
              ),
              duration: const Duration(milliseconds: 300),
              tabBackgroundGradient: const LinearGradient(
                colors: [
                  Color(0xFF1352C8),
                  Color(0xFF0A3D91),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              tabs: const [
                GButton(icon: Icons.home_rounded, text: 'Home'),
                GButton(icon: Icons.flag_outlined, text: 'Misi'),
                GButton(icon: Icons.local_parking, text: 'Parkir'),
                GButton(icon: Icons.card_giftcard, text: 'Reward'),
                GButton(icon: Icons.person_outline, text: 'Profil'),
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
