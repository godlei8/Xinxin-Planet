import '../../../core/utils/date_utils.dart' as app_date;

class PlanetPetSpecies {
  const PlanetPetSpecies({
    required this.id,
    required this.label,
    required this.story,
  });

  final String id;
  final String label;
  final String story;

  static const panda = PlanetPetSpecies(
    id: 'panda',
    label: '大熊猫',
    story: '稳重温柔，最擅长陪你慢慢变厉害。',
  );

  static const rabbit = PlanetPetSpecies(
    id: 'rabbit',
    label: '兔子',
    story: '灵巧轻快，会提醒你把任务拆小做完。',
  );

  static const cat = PlanetPetSpecies(
    id: 'cat',
    label: '猫咪',
    story: '优雅自律，把每次打卡都变成小仪式。',
  );

  static const dog = PlanetPetSpecies(
    id: 'dog',
    label: '小狗',
    story: '活力满格，最会给你情绪价值。',
  );

  static const fox = PlanetPetSpecies(
    id: 'fox',
    label: '狐狸',
    story: '机灵聪明，适合挑战更高目标。',
  );

  static const hamster = PlanetPetSpecies(
    id: 'hamster',
    label: '仓鼠',
    story: '圆滚滚的小能量包，适合碎片化打卡。',
  );

  static const penguin = PlanetPetSpecies(
    id: 'penguin',
    label: '企鹅',
    story: '冷静可爱，擅长帮你稳定专注节奏。',
  );

  static const koala = PlanetPetSpecies(
    id: 'koala',
    label: '考拉',
    story: '慢慢来也能很厉害，陪你温柔坚持。',
  );

  static const deer = PlanetPetSpecies(
    id: 'deer',
    label: '小鹿',
    story: '轻盈灵动，适合目标升级挑战。',
  );

  static const alpaca = PlanetPetSpecies(
    id: 'alpaca',
    label: '羊驼',
    story: '治愈感满满，让每天都松弛又有进步。',
  );

  static const values = [
    panda,
    rabbit,
    cat,
    dog,
    fox,
    hamster,
    penguin,
    koala,
    deer,
    alpaca,
  ];

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
    required this.dailyInteractionUsed,
    required this.dailyInteractionDate,
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
  final int dailyInteractionUsed;
  final String dailyInteractionDate;
  final int? lastFedAt;
  final int? lastPlayAt;
  final int? lastRestAt;

  static PlanetPet createDefault() {
    final now = DateTime.now().millisecondsSinceEpoch;
    final today = app_date.DateUtils.getTodayString();
    return PlanetPet(
      id: 'main_pet',
      name: '团团',
      species: PlanetPetSpecies.rabbit.id,
      level: 1,
      exp: 0,
      energy: 72,
      mood: 78,
      lastInteractionAt: now,
      dailyInteractionUsed: 0,
      dailyInteractionDate: today,
      lastFedAt: now,
      lastPlayAt: null,
      lastRestAt: null,
    );
  }

  PlanetPetSpecies get speciesMeta => PlanetPetSpecies.byId(species);

  int get nextLevelExp => 40 + ((level - 1) * 15);

  int usedInteractionsOn(String date) {
    if (dailyInteractionDate != date) {
      return 0;
    }
    return dailyInteractionUsed.clamp(0, 999999);
  }

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
      'daily_interaction_used': dailyInteractionUsed,
      'daily_interaction_date': dailyInteractionDate,
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
      dailyInteractionUsed: map['daily_interaction_used'] as int? ?? 0,
      dailyInteractionDate: map['daily_interaction_date'] as String? ??
          app_date.DateUtils.getTodayString(),
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
    int? dailyInteractionUsed,
    String? dailyInteractionDate,
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
      dailyInteractionUsed: dailyInteractionUsed ?? this.dailyInteractionUsed,
      dailyInteractionDate: dailyInteractionDate ?? this.dailyInteractionDate,
      lastFedAt: lastFedAt ?? this.lastFedAt,
      lastPlayAt: lastPlayAt ?? this.lastPlayAt,
      lastRestAt: lastRestAt ?? this.lastRestAt,
    );
  }
}
