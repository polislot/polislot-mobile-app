// ignore_for_file: deprecated_member_use
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:confetti/confetti.dart';

class RewardScreen extends StatefulWidget {
  const RewardScreen({super.key});

  @override
  State<RewardScreen> createState() => _RewardScreenState();
}

class _RewardScreenState extends State<RewardScreen> {
  late ConfettiController _confettiController;
  bool isTokoSelected = true;
  final Color primaryBlue = const Color(0xFF1352C8);
  int totalKoin = 480;

  final List<Map<String, dynamic>> _rewards = [
    {
      "icon": FontAwesomeIcons.mugHot,
      "title": "Tumbler Eksklusif",
      "subtitle": "Temani aktivitasmu — tahan panas & keren dibawa ke mana saja.",
      "poin": 500,
      "color": Colors.deepOrange
    },
    {
      "icon": FontAwesomeIcons.shirt,
      "title": "Hoodie Parkir",
      "subtitle": "Hoodie nyaman dengan logo PoliSlot — tampil keren tiap validasi.",
      "poin": 800,
      "color": Colors.purple
    },
    {
      "icon": FontAwesomeIcons.ticket,
      "title": "Voucher Belanja",
      "subtitle": "Voucher spesial untuk merchant kampus. Belanja lebih hemat!",
      "poin": 400,
      "color": Colors.green
    },
    {
      "icon": FontAwesomeIcons.gift,
      "title": "Kotak Misteri",
      "subtitle": "Isi acak — bisa voucher, merchandise, atau kejutan seru!",
      "poin": 600,
      "color": Colors.teal
    },
  ];

  final List<Map<String, dynamic>> _history = [];

  @override
  void initState() {
    super.initState();
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 2));

    _history.addAll([
      {
        "title": "Alendea menyukai postingan parkiran kamu",
        "tanggal": DateTime.now().subtract(const Duration(hours: 3)),
        "type": "info",
      },
      {
        "title": "Selamat! Kamu naik peringkat ke-5 pengguna teraktif 🎖️",
        "tanggal": DateTime.now().subtract(const Duration(days: 1)),
        "type": "achievement",
      },
      {
        "title": "Ayo tukarkan koinmu untuk hadiah menarik di toko!",
        "tanggal": DateTime.now().subtract(const Duration(days: 2)),
        "type": "reminder",
      },
    ]);
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  // --- Fade muncul lembut tiap card ---
  Widget _fadeInCard({required int index, required Widget child}) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 400 + (index * 100)),
      curve: Curves.easeOutCubic,
      builder: (_, value, childWidget) => Opacity(
        opacity: value,
        child: Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: childWidget,
        ),
      ),
      child: child,
    );
  }

  void _showRedeemDialog(Map<String, dynamic> item) {
    if (totalKoin < (item['poin'] as num).toInt()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("❌ Koin kamu belum cukup untuk menukar hadiah ini."),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    final voucherCode = _generateVoucherCode();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: Text("Tukar ${item['title']}",
            style: const TextStyle(fontWeight: FontWeight.bold)),
        content: Text(
          "Apakah Anda yakin ingin menukar ${item['poin']} Koin untuk mendapatkan ${item['title']}?",
          textAlign: TextAlign.justify,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Batal")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: primaryBlue,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            onPressed: () {
              Navigator.pop(context);
              _confettiController.play();

              setState(() {
                totalKoin -= (item['poin'] as num).toInt();
                _history.insert(0, {
                  "title": "Menukar ${item['title']}",
                  "tanggal": DateTime.now(),
                  "voucher": voucherCode,
                  "type": "redeem",
                });
              });

              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  title: const Text("🎉 Penukaran Berhasil!"),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(item['title'],
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          textAlign: TextAlign.center),
                      const SizedBox(height: 10),
                      Text("Kode Voucher Kamu:",
                          style: TextStyle(color: Colors.grey.shade700)),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(8)),
                        child: Text(voucherCode,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                      ),
                    ],
                  ),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Tutup"))
                  ],
                ),
              );
            },
            child: const Text("Ya, Tukar"),
          ),
        ],
      ),
    );
  }

  String _generateVoucherCode() {
    const chars = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789";
    return List.generate(8, (index) => chars[Random().nextInt(chars.length)]).join();
  }

  void _showCaraAmbilDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: const Text("📍 Cara Penukaran Hadiah"),
        content: const Text(
          "Tukar hadiah di Pusat Informasi Kampus dengan kode voucher kamu.\n"
          "Penukaran bisa dilakukan pukul 08.00 - 16.00.",
          textAlign: TextAlign.justify,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Tutup")),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Scaffold(
        backgroundColor: const Color(0xFFE9EEF6),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          automaticallyImplyLeading: false,
          title: const Text("Reward & Penukaran",
              style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
          centerTitle: true,
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            child: Column(
              children: [
                _headerCard(),
                const SizedBox(height: 18),
                _buildTabBar(),
                const SizedBox(height: 16),
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 400),
                    child: isTokoSelected
                        ? _buildRewardList(key: const ValueKey('toko'))
                        : _buildHistoryList(key: const ValueKey('riwayat')),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      Align(
        alignment: Alignment.topCenter,
        child: ConfettiWidget(
          confettiController: _confettiController,
          blastDirectionality: BlastDirectionality.explosive,
          emissionFrequency: 0.04,
          numberOfParticles: 25,
          gravity: 0.3,
        ),
      ),
    ]);
  }

  Widget _headerCard() => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
              colors: [primaryBlue, primaryBlue.withOpacity(0.8)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight),
          borderRadius: BorderRadius.circular(14),
          boxShadow: const [
            BoxShadow(color: Color(0x22000000), blurRadius: 8, offset: Offset(0, 4))
          ],
        ),
        child: Row(children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: Colors.greenAccent,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.attach_money, color: Colors.white, size: 26),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Total Koin Kamu", style: TextStyle(color: Colors.white70)),
              const SizedBox(height: 6),
              Text("$totalKoin Koin",
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
            ],
          ),
          const Spacer(),
          ElevatedButton.icon(
            onPressed: _showCaraAmbilDialog,
            icon: const Icon(Icons.info_outline, color: Colors.white),
            label: const Text("Cara Ambil", style: TextStyle(color: Colors.white)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white24,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          )
        ]),
      );

  Widget _buildTabBar() => Container(
        height: 45,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25),
          boxShadow: const [
            BoxShadow(color: Color(0x11000000), blurRadius: 6, offset: Offset(0, 3))
          ],
        ),
        child: Row(children: [
          _tabButton("Toko", isTokoSelected, () => setState(() => isTokoSelected = true)),
          _tabButton("Riwayat", !isTokoSelected, () => setState(() => isTokoSelected = false)),
        ]),
      );

  Expanded _tabButton(String text, bool active, VoidCallback onTap) => Expanded(
        child: GestureDetector(
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            decoration: BoxDecoration(
              color: active ? primaryBlue : Colors.white,
              borderRadius: BorderRadius.circular(25),
            ),
            child: Center(
                child: Text(text,
                    style: TextStyle(
                        color: active ? Colors.white : Colors.black87,
                        fontWeight: FontWeight.bold))),
          ),
        ),
      );

  Widget _buildRewardList({Key? key}) => ListView.builder(
        key: key,
        physics: const BouncingScrollPhysics(),
        itemCount: _rewards.length,
        itemBuilder: (context, index) {
          final item = _rewards[index];
          final bisaTukar = totalKoin >= (item['poin'] as num).toInt();

          return _fadeInCard(
            index: index,
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 8),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: const [
                  BoxShadow(color: Color(0x11000000), blurRadius: 8, offset: Offset(0, 4))
                ],
              ),
              child: Row(children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: (item['color'] as Color).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(item['icon'], color: item['color'] as Color, size: 30),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item['title'],
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 4),
                      Text(item['subtitle'],
                          style: const TextStyle(color: Colors.black54)),
                      const SizedBox(height: 8),
                      Text("${item['poin']} Koin",
                          style: const TextStyle(
                              color: Colors.green, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: bisaTukar ? () => _showRedeemDialog(item) : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: bisaTukar ? primaryBlue : Colors.grey.shade400,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text("Tukar", style: TextStyle(color: Colors.white)),
                ),
              ]),
            ),
          );
        },
      );

  Widget _buildHistoryList({Key? key}) => ListView.builder(
        key: key,
        physics: const BouncingScrollPhysics(),
        itemCount: _history.length,
        itemBuilder: (context, index) {
          final item = _history[index];
          final type = item["type"] ?? "redeem";

          IconData icon;
          Color iconColor;

          switch (type) {
            case "achievement":
              icon = FontAwesomeIcons.trophy;
              iconColor = Colors.amber;
              break;
            case "reminder":
              icon = FontAwesomeIcons.bell;
              iconColor = Colors.green;
              break;
            case "info":
              icon = FontAwesomeIcons.solidHeart;
              iconColor = Colors.pinkAccent;
              break;
            default:
              icon = FontAwesomeIcons.clockRotateLeft;
              iconColor = Colors.blueAccent;
          }

          return _fadeInCard(
            index: index,
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 8),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: const [
                  BoxShadow(color: Color(0x11000000), blurRadius: 6, offset: Offset(0, 3))
                ],
              ),
              child: Row(children: [
                Icon(icon, color: iconColor, size: 26),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item['title'],
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 15)),
                      const SizedBox(height: 4),
                      Text(
                        "Tanggal: ${item['tanggal'].day}/${item['tanggal'].month}/${item['tanggal'].year}",
                        style: const TextStyle(color: Colors.black54, fontSize: 13),
                      ),
                      if (item['voucher'] != null)
                        Text("Kode: ${item['voucher']}",
                            style: const TextStyle(
                                color: Colors.blueGrey, fontSize: 13)),
                    ],
                  ),
                ),
              ]),
            ),
          );
        },
      );
}
