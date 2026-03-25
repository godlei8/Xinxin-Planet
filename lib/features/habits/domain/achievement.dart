class Achievement {
  final String id;
  final String name;
  final String? description;
  final String iconCode;
  final int unlockThreshold;
  final bool isUnlocked;
  final int? unlockedAt;
  final int createdAt;

  Achievement({
    required this.id,
    required this.name,
    this.description,
    this.iconCode = '🏆',
    this.unlockThreshold = 0,
    this.isUnlocked = false,
    this.unlockedAt,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'icon_code': iconCode,
      'unlock_threshold': unlockThreshold,
      'is_unlocked': isUnlocked ? 1 : 0,
      'unlocked_at': unlockedAt,
      'created_at': createdAt,
    };
  }

  factory Achievement.fromMap(Map<String, dynamic> map) {
    return Achievement(
      id: map['id'] as String,
      name: map['name'] as String,
      description: map['description'] as String?,
      iconCode: map['icon_code'] as String? ?? '🏆',
      unlockThreshold: map['unlock_threshold'] as int? ?? 0,
      isUnlocked: (map['is_unlocked'] as int? ?? 0) == 1,
      unlockedAt: map['unlocked_at'] as int?,
      createdAt: map['created_at'] as int,
    );
  }
}
