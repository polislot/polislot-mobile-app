import 'tier_model.dart';

class LeaderboardUser {
  final int id;
  final String name;
  final String? avatar;
  final int lifetimePoints;
  final UserTier? tier; 

  LeaderboardUser({
    required this.id,
    required this.name,
    this.avatar,
    required this.lifetimePoints,
    this.tier, 
  });

  factory LeaderboardUser.fromJson(Map<String, dynamic> json) {
    return LeaderboardUser(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      avatar: json['avatar'],
      lifetimePoints: json['lifetime_points'] ?? 0,
      tier: json['tier'] != null 
            ? UserTier.fromJson(json['tier']) 
            : null, 
    );
  }
}