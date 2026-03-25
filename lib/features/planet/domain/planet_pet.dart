class PlanetPetSpecies {
  const PlanetPetSpecies({
    required this.id,
    required this.label,
    required this.modelAsset,
    required this.story,
  });

  final String id;
  final String label;
  final String modelAsset;
  final String story;

  static const panda = PlanetPetSpecies(
    id: 'panda',
    label: '大熊猫',
    modelAsset: 'assets/models/panda.glb',
    story: '慢热但很可靠，喜欢稳定节奏。',
  );

  static const rabbit = PlanetPetSpecies(
    id: 'rabbit',
    label: '兔子',
    modelAsset: 'assets/models/rabbit.glb',
    story: '行动轻快，最擅长把任务拆小完成。',
  );

  static const cat = PlanetPetSpecies(
    id: 'cat',
    label: '猫',
    modelAsset: 'assets/models/cat.glb',
    story: '独立又温柔，喜欢有仪式感的打卡。',
  );

  static const dog = PlanetPetSpecies(
    id: 'dog',
    label: '狗',
    modelAsset: 'assets/models/dog.glb',
    story: '活力满满，最会鼓励你持续坚持。',
  );

  static const fox = PlanetPetSpecies(
    id: 'fox',
    label: '狐狸',
    modelAsset: 'assets/models/fox.glb',
    story: '聪明灵活，适合进阶目标挑战。',
  );

  static const values = [panda, rabbit, cat, dog, fox];

  static PlanetPetSpecies byId(String id) {
    return values.firstWhere(
      (item) => item.id == id,
      orElse: () => rabbit,
    );
  }
}

class PlanetPet {
  const PlanetPet({
    required this.id,
    required this.name,
    required this.species,
    required this.level,
    required this.exp,
    required this.energy,
    required this.mood,
    required this.lastInteractionAt,
    this.lastFedAt,
    this.lastPlayAt,
    this.lastRestAt,
  });

  final String id;
  final String name;
  final String species;
  final int level;
  final int exp;
  final int energy;
  final int mood;
  final int lastInteractionAt;
  final int? lastFedAt;
  final int? lastPlayAt;
  final int? lastRestAt;

  static PlanetPet createDefault() {
    final now = DateTime.now().millisecondsSinceEpoch;
    return PlanetPet(
      id: 'main_pet',
      name: '团团',
      species: PlanetPetSpecies.rabbit.id,
      level: 1,
      exp: 0,
      energy: 72,
      mood: 78,
      lastInteractionAt: now,
      lastFedAt: now,
      lastPlayAt: null,
      lastRestAt: null,
    );
  }

  PlanetPetSpecies get speciesMeta => PlanetPetSpecies.byId(species);

  int get nextLevelExp => 40 + ((level - 1) * 15);

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'species': species,
      'level': level,
      'exp': exp,
      'energy': energy,
      'mood': mood,
      'last_interaction_at': lastInteractionAt,
      'last_fed_at': lastFedAt,
      'last_play_at': lastPlayAt,
      'last_rest_at': lastRestAt,
    };
  }

  factory PlanetPet.fromMap(Map<String, dynamic> map) {
    return PlanetPet(
      id: map['id'] as String? ?? 'main_pet',
      name: map['name'] as String? ?? '团团',
      species: map['species'] as String? ?? PlanetPetSpecies.rabbit.id,
      level: map['level'] as int? ?? 1,
      exp: map['exp'] as int? ?? 0,
      energy: map['energy'] as int? ?? 70,
      mood: map['mood'] as int? ?? 70,
      lastInteractionAt: map['last_interaction_at'] as int? ??
          DateTime.now().millisecondsSinceEpoch,
      lastFedAt: map['last_fed_at'] as int?,
      lastPlayAt: map['last_play_at'] as int?,
      lastRestAt: map['last_rest_at'] as int?,
    );
  }

  PlanetPet copyWith({
    String? id,
    String? name,
    String? species,
    int? level,
    int? exp,
    int? energy,
    int? mood,
    int? lastInteractionAt,
    int? lastFedAt,
    int? lastPlayAt,
    int? lastRestAt,
  }) {
    return PlanetPet(
      id: id ?? this.id,
      name: name ?? this.name,
      species: species ?? this.species,
      level: level ?? this.level,
      exp: exp ?? this.exp,
      energy: energy ?? this.energy,
      mood: mood ?? this.mood,
      lastInteractionAt: lastInteractionAt ?? this.lastInteractionAt,
      lastFedAt: lastFedAt ?? this.lastFedAt,
      lastPlayAt: lastPlayAt ?? this.lastPlayAt,
      lastRestAt: lastRestAt ?? this.lastRestAt,
    );
  }
}
