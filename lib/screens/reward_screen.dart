// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:confetti/confetti.dart';
import '../models/reward_model.dart';
import '../models/user_reward_model.dart';
import '../routes/api_service.dart';

class RewardScreen extends StatefulWidget {
  const RewardScreen({super.key});

  @override
  State<RewardScreen> createState() => _RewardScreenState();
}

class _RewardScreenState extends State<RewardScreen> {
  late ConfettiController _confettiController;
  bool isTokoSelected = true;
  final Color primaryBlue = const Color(0xFF1565C0);
  
  int currentPoints = 0;
  List<Reward> rewards = [];
  List<UserReward> myRewards = [];
  
  bool isLoadingRewards = true;
  bool isLoadingHistory = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 2));
    _loadData();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    await Future.wait([
      _loadRewardCatalog(),
      _loadMyRewards(),
    ]);
  }

  Future<void> _loadRewardCatalog() async {
    setState(() => isLoadingRewards = true);
    
    try {
      final token = await ApiService.getToken();
      if (token == null) {
        setState(() => errorMessage = 'Token tidak ditemukan');
        return;
      }

      final response = await ApiService.getRewardCatalog(token);

      if (response.isSuccess && response.data != null) {
        setState(() {
          currentPoints = response.data!.currentPoints;
          rewards = response.data!.rewards;
          isLoadingRewards = false;
        });
      } else {
        setState(() {
          errorMessage = response.message;
          isLoadingRewards = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Gagal memuat katalog reward: $e';
        isLoadingRewards = false;
      });
    }
  }

  Future<void> _loadMyRewards() async {
    setState(() => isLoadingHistory = true);
    
    try {
      final token = await ApiService.getToken();
      if (token == null) return;

      final response = await ApiService.getMyRewards(token);

      if (response.isSuccess && response.data != null) {
        setState(() {
          myRewards = response.data!;
          isLoadingHistory = false;
        });
      } else {
        setState(() {
          isLoadingHistory = false;
        });
      }
    } catch (e) {
      setState(() => isLoadingHistory = false);
    }
  }

  void _showRedeemDialog(Reward reward) {
    if (!reward.canExchange) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("❌ Poin kamu belum cukup untuk menukar hadiah ini."),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: Text("Tukar ${reward.rewardName}",
            style: const TextStyle(fontWeight: FontWeight.bold)),
        content: Text(
          "Apakah Anda yakin ingin menukar ${reward.pointsRequired} Poin untuk mendapatkan ${reward.rewardName}?",
          textAlign: TextAlign.justify,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1565C0),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              Navigator.pop(context);
              _exchangeReward(reward);
            },
            child: const Text("Ya, Tukar"),
          ),
        ],
      ),
    );
  }

  Future<void> _exchangeReward(Reward reward) async {
    try {
      final token = await ApiService.getToken();
      if (token == null) {
        _showErrorSnackbar('Token tidak ditemukan');
        return;
      }

      // Show loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );

      final response = await ApiService.exchangeReward(
        accessToken: token,
        rewardId: reward.rewardId,
      );

      // Close loading
      if (mounted) Navigator.pop(context);

      if (response.isSuccess && response.data != null) {
        _confettiController.play();

        // Update poin
        setState(() {
          currentPoints = response.data!.remainingPoints;
        });

        // Reload data
        await _loadData();

        // Show success dialog
        if (mounted) {
          showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: const Text("🎉 Penukaran Berhasil!"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    response.data!.rewardName,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Kode Voucher Kamu:",
                    style: TextStyle(color: Colors.grey.shade700),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      response.data!.voucherCode,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    response.data!.instruction,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text("Tutup"),
                ),
              ],
            ),
          );
        }
      } else {
        _showErrorSnackbar(response.message);
      }
    } catch (e) {
      if (mounted) Navigator.pop(context); // Close loading
      _showErrorSnackbar('Terjadi kesalahan: $e');
    }
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
      ),
    );
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
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Tutup"),
          ),
        ],
      ),
    );
  }

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

  IconData _getIconForRewardType(String type) {
    switch (type.toLowerCase()) {
      case 'voucher':
        return FontAwesomeIcons.ticket;
      case 'merchandise':
        return FontAwesomeIcons.gift;
      default:
        return FontAwesomeIcons.gift;
    }
  }

  Color _getColorForRewardType(String type) {
    switch (type.toLowerCase()) {
      case 'voucher':
        return Colors.green;
      case 'merchandise':
        return Colors.deepOrange;
      default:
        return Colors.blue;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          backgroundColor: const Color(0xFFF3F6FB),
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            automaticallyImplyLeading: false,
            title: const Text(
              "Reward & Penukaran",
              style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
            ),
            centerTitle: true,
          ),
          body: SafeArea(
            child: RefreshIndicator(
              onRefresh: _loadData,
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
      ],
    );
  }

  Widget _headerCard() => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF1565C0), Color(0xFF2196F3)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(14),
          boxShadow: const [
            BoxShadow(color: Color(0x22000000), blurRadius: 8, offset: Offset(0, 4))
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.attach_money, color: Colors.white, size: 26),
            ),
            const SizedBox(width: 14),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Total Poin Kamu", style: TextStyle(color: Colors.white70)),
                const SizedBox(height: 6),
                Text(
                  "$currentPoints Poin",
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
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
          ],
        ),
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
        child: Row(
          children: [
            _tabButton("Toko", isTokoSelected, () => setState(() => isTokoSelected = true)),
            _tabButton("Riwayat", !isTokoSelected, () => setState(() => isTokoSelected = false)),
          ],
        ),
      );

  Expanded _tabButton(String text, bool active, VoidCallback onTap) => Expanded(
        child: GestureDetector(
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            decoration: BoxDecoration(
              gradient: active
                  ? const LinearGradient(
                      colors: [Color(0xFF1565C0), Color(0xFF2196F3)],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight)
                  : null,
              color: active ? null : Colors.white,
              borderRadius: BorderRadius.circular(25),
            ),
            child: Center(
              child: Text(
                text,
                style: TextStyle(
                  color: active ? Colors.white : Colors.black87,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      );

  Widget _buildRewardList({Key? key}) {
    if (isLoadingRewards) {
      return const Center(child: CircularProgressIndicator());
    }

    if (rewards.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.card_giftcard, size: 80, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              "Belum ada reward tersedia",
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      key: key,
      physics: const BouncingScrollPhysics(),
      itemCount: rewards.length,
      itemBuilder: (context, index) {
        final reward = rewards[index];
        final icon = _getIconForRewardType(reward.rewardType);
        final color = _getColorForRewardType(reward.rewardType);

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
            child: Row(
              children: [
                // Icon/Image
                reward.rewardImage != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          reward.rewardImage!,
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            width: 60,
                            height: 60,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: color.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(icon, color: color, size: 30),
                          ),
                        ),
                      )
                    : Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(icon, color: color, size: 30),
                      ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        reward.rewardName,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        reward.description ?? 'Reward menarik untuk kamu!',
                        style: const TextStyle(color: Colors.black54),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "${reward.pointsRequired} Poin",
                        style: const TextStyle(
                          color: Color(0xFF1352C8),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: reward.canExchange ? () => _showRedeemDialog(reward) : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: reward.canExchange
                        ? const Color(0xFF1565C0)
                        : Colors.grey.shade400,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text("Tukar", style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHistoryList({Key? key}) {
    if (isLoadingHistory) {
      return const Center(child: CircularProgressIndicator());
    }

    if (myRewards.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history, size: 80, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              "Belum ada riwayat penukaran",
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      key: key,
      physics: const BouncingScrollPhysics(),
      itemCount: myRewards.length,
      itemBuilder: (context, index) {
        final userReward = myRewards[index];
        final icon = userReward.isPending
            ? FontAwesomeIcons.clockRotateLeft
            : FontAwesomeIcons.circleCheck;
        final iconColor = userReward.isPending ? Colors.orange : Colors.green;

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
            child: Row(
              children: [
                Icon(icon, color: iconColor, size: 26),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        userReward.rewardName,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Kode: ${userReward.voucherCode}",
                        style: const TextStyle(color: Colors.blueGrey, fontSize: 13),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Status: ${userReward.status}",
                        style: TextStyle(
                          color: userReward.isPending ? Colors.orange : Colors.green,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        "Ditukar: ${userReward.exchangedAt}",
                        style: const TextStyle(color: Colors.black54, fontSize: 12),
                      ),
                      if (userReward.isUsed && userReward.usedAt != null)
                        Text(
                          "Dipakai: ${userReward.usedAt}",
                          style: const TextStyle(color: Colors.black54, fontSize: 12),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}