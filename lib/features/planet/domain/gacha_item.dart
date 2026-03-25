class GachaItem {
  const GachaItem({
    required this.itemId,
    required this.name,
    required this.emoji,
    required this.rarity,
    required this.itemType,
  });

  final String itemId;
  final String name;
  final String emoji;
  final int rarity;
  final String itemType;
}
