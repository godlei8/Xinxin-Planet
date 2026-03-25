class CheckRecord {
  final String id;
  final String habitId;
  final String checkDate;
  final int checkTime;
  final String? note;
  final int? mood;
  final int focusMinutes;

  CheckRecord({
    required this.id,
    required this.habitId,
    required this.checkDate,
    required this.checkTime,
    this.note,
    this.mood,
    this.focusMinutes = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'habit_id': habitId,
      'check_date': checkDate,
      'check_time': checkTime,
      'note': note,
      'mood': mood,
      'focus_minutes': focusMinutes,
    };
  }

  factory CheckRecord.fromMap(Map<String, dynamic> map) {
    return CheckRecord(
      id: map['id'] as String,
      habitId: map['habit_id'] as String,
      checkDate: map['check_date'] as String,
      checkTime: map['check_time'] as int,
      note: map['note'] as String?,
      mood: map['mood'] as int?,
      focusMinutes: map['focus_minutes'] as int? ?? 0,
    );
  }

  CheckRecord copyWith({
    String? id,
    String? habitId,
    String? checkDate,
    int? checkTime,
    String? note,
    int? mood,
    int? focusMinutes,
  }) {
    return CheckRecord(
      id: id ?? this.id,
      habitId: habitId ?? this.habitId,
      checkDate: checkDate ?? this.checkDate,
      checkTime: checkTime ?? this.checkTime,
      note: note ?? this.note,
      mood: mood ?? this.mood,
      focusMinutes: focusMinutes ?? this.focusMinutes,
    );
  }
}
