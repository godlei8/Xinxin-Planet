class Habit {
  final String id;
  final String name;
  final String description;
  final String categoryId;
  final String colorCode;
  final String iconCode;
  final int frequency;
  final bool reminderEnabled;
  final String? reminderTime;
  final int createdAt;
  final bool isArchived;

  Habit({
    required this.id,
    required this.name,
    this.description = '',
    this.categoryId = 'default',
    this.colorCode = '#FF8FA3',
    this.iconCode = '⭐',
    this.frequency = 0,
    this.reminderEnabled = false,
    this.reminderTime,
    required this.createdAt,
    this.isArchived = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'category_id': categoryId,
      'color_code': colorCode,
      'icon_code': iconCode,
      'frequency': frequency,
      'reminder_enabled': reminderEnabled ? 1 : 0,
      'reminder_time': reminderTime,
      'created_at': createdAt,
      'is_archived': isArchived ? 1 : 0,
    };
  }

  factory Habit.fromMap(Map<String, dynamic> map) {
    return Habit(
      id: map['id'] as String,
      name: map['name'] as String,
      description: map['description'] as String? ?? '',
      categoryId: map['category_id'] as String? ?? 'default',
      colorCode: map['color_code'] as String? ?? '#FF8FA3',
      iconCode: map['icon_code'] as String? ?? '⭐',
      frequency: map['frequency'] as int? ?? 0,
      reminderEnabled: (map['reminder_enabled'] as int? ?? 0) == 1,
      reminderTime: map['reminder_time'] as String?,
      createdAt: map['created_at'] as int,
      isArchived: (map['is_archived'] as int? ?? 0) == 1,
    );
  }

  Habit copyWith({
    String? id,
    String? name,
    String? description,
    String? categoryId,
    String? colorCode,
    String? iconCode,
    int? frequency,
    bool? reminderEnabled,
    String? reminderTime,
    int? createdAt,
    bool? isArchived,
  }) {
    return Habit(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      categoryId: categoryId ?? this.categoryId,
      colorCode: colorCode ?? this.colorCode,
      iconCode: iconCode ?? this.iconCode,
      frequency: frequency ?? this.frequency,
      reminderEnabled: reminderEnabled ?? this.reminderEnabled,
      reminderTime: reminderTime ?? this.reminderTime,
      createdAt: createdAt ?? this.createdAt,
      isArchived: isArchived ?? this.isArchived,
    );
  }
}
