// lib/models/reward_model.dart

class Reward {
  final int rewardId;
  final String rewardName;
  final String? description;
  final int pointsRequired;
  final String rewardType; // 'merchandise' atau 'voucher'
  final String? rewardImage;
  final bool canExchange;

  Reward({
    required this.rewardId,
    required this.rewardName,
    this.description,
    required this.pointsRequired,
    required this.rewardType,
    this.rewardImage,
    required this.canExchange,
  });

  factory Reward.fromJson(Map<String, dynamic> json) {
    return Reward(
      rewardId: json['reward_id'] ?? 0,
      rewardName: json['reward_name'] ?? 'Reward',
      description: json['description'],
      pointsRequired: json['points_required'] ?? 0,
      rewardType: json['reward_type'] ?? 'merchandise',
      rewardImage: json['reward_image'],
      canExchange: json['can_exchange'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'reward_id': rewardId,
      'reward_name': rewardName,
      'description': description,
      'points_required': pointsRequired,
      'reward_type': rewardType,
      'reward_image': rewardImage,
      'can_exchange': canExchange,
    };
  }
}

// Response untuk katalog reward
class RewardCatalogResponse {
  final int currentPoints;
  final List<Reward> rewards;

  RewardCatalogResponse({
    required this.currentPoints,
    required this.rewards,
  });

  factory RewardCatalogResponse.fromJson(Map<String, dynamic> json) {
    return RewardCatalogResponse(
      currentPoints: json['current_points'] ?? 0,
      rewards: (json['rewards'] as List?)
              ?.map((item) => Reward.fromJson(item))
              .toList() ??
          [],
    );
  }
}