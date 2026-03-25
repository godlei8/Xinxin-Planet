import 'dart:convert';

class UserProgress {
  final String id;
  final int totalCheckIns;
  final int currentStreak;
  final int bestStreak;
  final String? lastCheckInDate;
  final int planetLevel;
  final List<String> unlockedDecorations;
  final int createdAt;
  final int updatedAt;

  UserProgress({
    required this.id,
    this.totalCheckIns = 0,
    this.currentStreak = 0,
    this.bestStreak = 0,
    this.lastCheckInDate,
    this.planetLevel = 1,
    List<String>? unlockedDecorations,
    required this.createdAt,
    required this.updatedAt,
  }) : unlockedDecorations = unlockedDecorations ?? [];

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'total_check_ins': totalCheckIns,
      'current_streak': currentStreak,
      'best_streak': bestStreak,
      'last_check_in_date': lastCheckInDate,
      'planet_level': planetLevel,
      'unlocked_decorations': jsonEncode(unlockedDecorations),
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  factory UserProgress.fromMap(Map<String, dynamic> map) {
    return UserProgress(
      id: map['id'] as String,
      totalCheckIns: map['total_check_ins'] as int? ?? 0,
      currentStreak: map['current_streak'] as int? ?? 0,
      bestStreak: map['best_streak'] as int? ?? 0,
      lastCheckInDate: map['last_check_in_date'] as String?,
      planetLevel: map['planet_level'] as int? ?? 1,
      unlockedDecorations:
          _parseDecorations(map['unlocked_decorations'] as String?),
      createdAt: map['created_at'] as int,
      updatedAt: map['updated_at'] as int,
    );
  }

  static List<String> _parseDecorations(String? decorationsStr) {
    if (decorationsStr == null ||
        decorationsStr.isEmpty ||
        decorationsStr == '[]') {
      return [];
    }

    try {
      final decoded = jsonDecode(decorationsStr);
      if (decoded is List) {
        return decoded.whereType<String>().toList();
      }
    } catch (_) {
      final cleanStr = decorationsStr.replaceAll('[', '').replaceAll(']', '');
      if (cleanStr.isEmpty) {
        return [];
      }
      return cleanStr
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();
    }

    return [];
  }

  UserProgress copyWith({
    String? id,
    int? totalCheckIns,
    int? currentStreak,
    int? bestStreak,
    String? lastCheckInDate,
    int? planetLevel,
    List<String>? unlockedDecorations,
    int? createdAt,
    int? updatedAt,
  }) {
    return UserProgress(
      id: id ?? this.id,
      totalCheckIns: totalCheckIns ?? this.totalCheckIns,
      currentStreak: currentStreak ?? this.currentStreak,
      bestStreak: bestStreak ?? this.bestStreak,
      lastCheckInDate: lastCheckInDate ?? this.lastCheckInDate,
      planetLevel: planetLevel ?? this.planetLevel,
      unlockedDecorations: unlockedDecorations ?? this.unlockedDecorations,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
