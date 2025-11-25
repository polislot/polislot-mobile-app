// lib/models/user_reward_model.dart

class UserReward {
  final int userRewardId;
  final String voucherCode;
  final String rewardName;
  final String rewardType;
  final String? rewardImage;
  final int pointsRequired;
  final String status;
  final String exchangedAt;
  final String? usedAt;

  UserReward({
    required this.userRewardId,
    required this.voucherCode,
    required this.rewardName,
    required this.rewardType,
    this.rewardImage,
    required this.pointsRequired,
    required this.status,
    required this.exchangedAt,
    this.usedAt,
  });

  factory UserReward.fromJson(Map<String, dynamic> json) {
    return UserReward(
      userRewardId: json['user_reward_id'] ?? 0,
      voucherCode: json['voucher_code'] ?? '',
      rewardName: json['reward_name'] ?? 'Reward',
      rewardType: json['reward_type'] ?? 'merchandise',
      rewardImage: json['reward_image'],
      pointsRequired: json['points_required'] ?? 0,
      status: json['status'] ?? 'belum dipakai',
      exchangedAt: json['exchanged_at'] ?? '',
      usedAt: json['used_at'],
    );
  }

  bool get isUsed => status == 'terpakai';
  bool get isPending => status == 'belum dipakai';
}

// Response setelah penukaran
class ExchangeRewardResponse {
  final int userRewardId;
  final String voucherCode;
  final String rewardName;
  final String rewardType;
  final String? rewardImage;
  final int pointsUsed;
  final int remainingPoints;
  final String redeemedAt;
  final String status;
  final String instruction;

  ExchangeRewardResponse({
    required this.userRewardId,
    required this.voucherCode,
    required this.rewardName,
    required this.rewardType,
    this.rewardImage,
    required this.pointsUsed,
    required this.remainingPoints,
    required this.redeemedAt,
    required this.status,
    required this.instruction,
  });

  factory ExchangeRewardResponse.fromJson(Map<String, dynamic> json) {
    return ExchangeRewardResponse(
      userRewardId: json['user_reward_id'] ?? 0,
      voucherCode: json['voucher_code'] ?? '',
      rewardName: json['reward_name'] ?? '',
      rewardType: json['reward_type'] ?? '',
      rewardImage: json['reward_image'],
      pointsUsed: json['points_used'] ?? 0,
      remainingPoints: json['remaining_points'] ?? 0,
      redeemedAt: json['redeemed_at'] ?? '',
      status: json['status'] ?? 'belum dipakai',
      instruction: json['instruction'] ?? '',
    );
  }
}