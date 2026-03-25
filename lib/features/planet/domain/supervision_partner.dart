class SupervisionPartner {
  const SupervisionPartner({
    required this.id,
    required this.name,
    required this.relation,
    required this.avatarEmoji,
  });

  final String id;
  final String name;
  final String relation;
  final String avatarEmoji;

  factory SupervisionPartner.fromMap(Map<String, dynamic> map) {
    return SupervisionPartner(
      id: map['id'] as String,
      name: map['partner_name'] as String? ?? '',
      relation: map['relation'] as String? ?? 'friend',
      avatarEmoji: map['avatar_emoji'] as String? ?? '⭐',
    );
  }
}
