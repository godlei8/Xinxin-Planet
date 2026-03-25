class FocusForestEntry {
  const FocusForestEntry({
    required this.id,
    required this.durationSec,
    required this.treeType,
    required this.treeSize,
    required this.plantedAt,
    required this.isAlive,
  });

  final String id;
  final int durationSec;
  final String treeType;
  final String treeSize;
  final int plantedAt;
  final bool isAlive;

  factory FocusForestEntry.fromMap(Map<String, dynamic> map) {
    return FocusForestEntry(
      id: map['id'] as String,
      durationSec: map['duration_sec'] as int? ?? 0,
      treeType: map['tree_type'] as String? ?? 'oak',
      treeSize: map['tree_size'] as String? ?? 'seed',
      plantedAt: map['planted_at'] as int? ?? 0,
      isAlive: (map['is_alive'] as int? ?? 0) == 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'duration_sec': durationSec,
      'tree_type': treeType,
      'tree_size': treeSize,
      'planted_at': plantedAt,
      'is_alive': isAlive ? 1 : 0,
    };
  }
}
