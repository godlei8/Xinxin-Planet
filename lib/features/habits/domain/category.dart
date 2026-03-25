class Category {
  final String id;
  final String name;
  final String colorCode;
  final String iconCode;
  final bool isDefault;
  final int createdAt;

  Category({
    required this.id,
    required this.name,
    this.colorCode = '#FF8FA3',
    this.iconCode = '📦',
    this.isDefault = false,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'color_code': colorCode,
      'icon_code': iconCode,
      'is_default': isDefault ? 1 : 0,
      'created_at': createdAt,
    };
  }

  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id'] as String,
      name: map['name'] as String,
      colorCode: map['color_code'] as String? ?? '#FF8FA3',
      iconCode: map['icon_code'] as String? ?? '📦',
      isDefault: (map['is_default'] as int? ?? 0) == 1,
      createdAt: map['created_at'] as int,
    );
  }
}
