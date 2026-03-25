class HealthReminder {
  const HealthReminder({
    required this.id,
    required this.reminderType,
    required this.intervalMinutes,
    required this.isEnabled,
    required this.dailyTarget,
    required this.dailyCompleted,
  });

  final String id;
  final String reminderType;
  final int intervalMinutes;
  final bool isEnabled;
  final int dailyTarget;
  final int dailyCompleted;

  factory HealthReminder.fromMap(Map<String, dynamic> map) {
    return HealthReminder(
      id: map['id'] as String,
      reminderType: map['reminder_type'] as String? ?? '',
      intervalMinutes: map['interval_minutes'] as int? ?? 60,
      isEnabled: (map['is_enabled'] as int? ?? 0) == 1,
      dailyTarget: map['daily_target'] as int? ?? 0,
      dailyCompleted: map['daily_completed'] as int? ?? 0,
    );
  }

  HealthReminder copyWith({
    String? id,
    String? reminderType,
    int? intervalMinutes,
    bool? isEnabled,
    int? dailyTarget,
    int? dailyCompleted,
  }) {
    return HealthReminder(
      id: id ?? this.id,
      reminderType: reminderType ?? this.reminderType,
      intervalMinutes: intervalMinutes ?? this.intervalMinutes,
      isEnabled: isEnabled ?? this.isEnabled,
      dailyTarget: dailyTarget ?? this.dailyTarget,
      dailyCompleted: dailyCompleted ?? this.dailyCompleted,
    );
  }
}
