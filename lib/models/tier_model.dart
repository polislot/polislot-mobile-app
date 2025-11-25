class UserTier {
  final int? id; // ⬅️ TAMBAH

  final String? tier;
  final String? color;
  final String? icon;
  final int lifetimePoints;
  final int currentPoints;
  final bool tierUp;

  UserTier({
    this.id, // ⬅️ TAMBAH
    this.tier,
    this.color,
    this.icon,
    required this.lifetimePoints,
    required this.currentPoints,
    this.tierUp = false,
  });

  factory UserTier.fromJson(Map<String, dynamic> json) {
    return UserTier(
      id: json['id'], // ⬅️ TAMBAH
      tier: json['tier'],
      color: json['tier_color'],
      icon: json['tier_icon'],
      lifetimePoints: json['lifetime_points'] ?? 0,
      currentPoints: json['current_points'] ?? 0,
      tierUp: json['tier_up'] ?? false,
    );
  }
}
