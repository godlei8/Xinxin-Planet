import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'migration_helper.dart';

class DatabaseHelper {
  static const String _databaseName = 'xinxin_planet.db';
  static const int _databaseVersion = 4;

  static const List<String> _exportTables = [
    'habits',
    'check_records',
    'categories',
    'achievements',
    'user_progress',
    'focus_forest',
    'health_reminders',
    'user_wallet',
    'user_inventory',
    'supervision_partners',
    'supervision_logs',
    'sleep_sessions',
  ];

  static const List<String> _clearOrder = [
    'check_records',
    'habits',
    'categories',
    'achievements',
    'user_progress',
    'focus_forest',
    'health_reminders',
    'user_wallet',
    'user_inventory',
    'supervision_logs',
    'supervision_partners',
    'sleep_sessions',
  ];

  static const List<String> _restoreOrder = [
    'categories',
    'habits',
    'check_records',
    'achievements',
    'user_progress',
    'focus_forest',
    'health_reminders',
    'user_wallet',
    'user_inventory',
    'supervision_partners',
    'supervision_logs',
    'sleep_sessions',
  ];

  static Database? _database;

  static Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }
    _database = await _initDatabase();
    return _database!;
  }

  static Future<String> get databasePath async {
    final dbPath = await getDatabasesPath();
    return join(dbPath, _databaseName);
  }

  static Future<Database> _initDatabase() async {
    final path = await databasePath;
    return openDatabase(
      path,
      version: _databaseVersion,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: _onCreate,
      onOpen: (db) async {
        await _ensureIndexes(db);
      },
      onUpgrade: _onUpgrade,
    );
  }

  static Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE habits (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        description TEXT DEFAULT '',
        category_id TEXT DEFAULT 'default',
        color_code TEXT DEFAULT '#E95C96',
        icon_code TEXT DEFAULT '🌸',
        frequency INTEGER DEFAULT 0,
        reminder_enabled INTEGER DEFAULT 0,
        reminder_time TEXT,
        created_at INTEGER NOT NULL,
        is_archived INTEGER DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE check_records (
        id TEXT PRIMARY KEY,
        habit_id TEXT NOT NULL,
        check_date TEXT NOT NULL,
        check_time INTEGER NOT NULL,
        note TEXT,
        mood INTEGER,
        focus_minutes INTEGER DEFAULT 0,
        image_path TEXT,
        FOREIGN KEY (habit_id) REFERENCES habits (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE categories (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        color_code TEXT DEFAULT '#E95C96',
        icon_code TEXT DEFAULT '🌸',
        is_default INTEGER DEFAULT 0,
        created_at INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE achievements (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        description TEXT,
        icon_code TEXT DEFAULT '🏆',
        unlock_threshold INTEGER DEFAULT 0,
        is_unlocked INTEGER DEFAULT 0,
        unlocked_at INTEGER,
        created_at INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE user_progress (
        id TEXT PRIMARY KEY,
        total_check_ins INTEGER DEFAULT 0,
        current_streak INTEGER DEFAULT 0,
        best_streak INTEGER DEFAULT 0,
        last_check_in_date TEXT,
        planet_level INTEGER DEFAULT 1,
        unlocked_decorations TEXT DEFAULT '[]',
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE focus_forest (
        id TEXT PRIMARY KEY,
        duration_sec INTEGER NOT NULL,
        tree_type TEXT NOT NULL,
        tree_size TEXT NOT NULL,
        planted_at INTEGER NOT NULL,
        is_alive INTEGER DEFAULT 1
      )
    ''');

    await db.execute('''
      CREATE TABLE health_reminders (
        id TEXT PRIMARY KEY,
        reminder_type TEXT NOT NULL,
        interval_minutes INTEGER NOT NULL,
        is_enabled INTEGER DEFAULT 1,
        last_triggered INTEGER,
        daily_target INTEGER DEFAULT 8,
        daily_completed INTEGER DEFAULT 0,
        created_at INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE user_wallet (
        id TEXT PRIMARY KEY,
        coins INTEGER DEFAULT 0,
        total_earned INTEGER DEFAULT 0,
        total_spent INTEGER DEFAULT 0,
        updated_at INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE user_inventory (
        id TEXT PRIMARY KEY,
        item_id TEXT NOT NULL,
        item_name TEXT NOT NULL,
        item_type TEXT NOT NULL,
        rarity INTEGER DEFAULT 1,
        acquired_at INTEGER NOT NULL,
        source TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE supervision_partners (
        id TEXT PRIMARY KEY,
        partner_name TEXT NOT NULL,
        relation TEXT DEFAULT 'friend',
        avatar_emoji TEXT DEFAULT '🐰',
        created_at INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE supervision_logs (
        id TEXT PRIMARY KEY,
        partner_id TEXT NOT NULL,
        action_type TEXT NOT NULL,
        message TEXT NOT NULL,
        created_at INTEGER NOT NULL,
        FOREIGN KEY (partner_id) REFERENCES supervision_partners (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE sleep_sessions (
        id TEXT PRIMARY KEY,
        duration_min INTEGER NOT NULL,
        completed INTEGER DEFAULT 0,
        mood_after INTEGER DEFAULT 3,
        created_at INTEGER NOT NULL
      )
    ''');

    await _ensureIndexes(db);
    await _seedDefaultData(db);
  }

  static Future<void> _ensureIndexes(DatabaseExecutor db) async {
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_check_records_habit_id ON check_records (habit_id)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_check_records_check_date ON check_records (check_date)',
    );
    await db.execute(
      'CREATE UNIQUE INDEX IF NOT EXISTS idx_check_records_habit_date ON check_records (habit_id, check_date)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_focus_forest_planted_at ON focus_forest (planted_at DESC)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_supervision_logs_partner ON supervision_logs (partner_id)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_sleep_sessions_created_at ON sleep_sessions (created_at DESC)',
    );
  }

  static Future<void> _insertDefaultCategories(DatabaseExecutor db) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final defaultCategories = [
      {
        'id': 'default',
        'name': '日常',
        'color_code': '#E95C96',
        'icon_code': '🌸',
        'is_default': 1,
        'created_at': now,
      },
      {
        'id': 'health',
        'name': '健康',
        'color_code': '#63C8A5',
        'icon_code': '💧',
        'is_default': 0,
        'created_at': now,
      },
      {
        'id': 'study',
        'name': '学习',
        'color_code': '#89CFF0',
        'icon_code': '📖',
        'is_default': 0,
        'created_at': now,
      },
      {
        'id': 'work',
        'name': '工作',
        'color_code': '#FFB879',
        'icon_code': '📝',
        'is_default': 0,
        'created_at': now,
      },
      {
        'id': 'hobby',
        'name': '兴趣',
        'color_code': '#D8A7F9',
        'icon_code': '🎨',
        'is_default': 0,
        'created_at': now,
      },
    ];

    for (final category in defaultCategories) {
      await db.insert(
        'categories',
        category,
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
    }
  }

  static Future<void> _insertDefaultAchievements(DatabaseExecutor db) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final achievements = [
      {
        'id': 'first_checkin',
        'name': '首次发光',
        'description': '完成第一次打卡',
        'icon_code': '✅',
        'unlock_threshold': 1,
        'is_unlocked': 0,
        'created_at': now,
      },
      {
        'id': 'week_warrior',
        'name': '一周坚持',
        'description': '连续打卡 7 天',
        'icon_code': '🔥',
        'unlock_threshold': 7,
        'is_unlocked': 0,
        'created_at': now,
      },
      {
        'id': 'month_master',
        'name': '月度达人',
        'description': '连续打卡 30 天',
        'icon_code': '🏆',
        'unlock_threshold': 30,
        'is_unlocked': 0,
        'created_at': now,
      },
      {
        'id': 'century_star',
        'name': '百日星光',
        'description': '连续打卡 100 天',
        'icon_code': '🌟',
        'unlock_threshold': 100,
        'is_unlocked': 0,
        'created_at': now,
      },
      {
        'id': 'habit_creator',
        'name': '习惯设计师',
        'description': '创建 5 个习惯',
        'icon_code': '🧠',
        'unlock_threshold': 5,
        'is_unlocked': 0,
        'created_at': now,
      },
    ];

    for (final achievement in achievements) {
      await db.insert(
        'achievements',
        achievement,
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
    }
  }

  static Future<void> _insertDefaultUserProgress(DatabaseExecutor db) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    await db.insert(
      'user_progress',
      {
        'id': 'main_progress',
        'total_check_ins': 0,
        'current_streak': 0,
        'best_streak': 0,
        'planet_level': 1,
        'unlocked_decorations': '[]',
        'created_at': now,
        'updated_at': now,
      },
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  static Future<void> _insertDefaultHealthReminders(DatabaseExecutor db) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final defaults = [
      {
        'id': 'water_reminder',
        'reminder_type': 'water',
        'interval_minutes': 60,
        'is_enabled': 0,
        'daily_target': 8,
        'daily_completed': 0,
        'created_at': now,
      },
      {
        'id': 'stand_reminder',
        'reminder_type': 'stand',
        'interval_minutes': 90,
        'is_enabled': 0,
        'daily_target': 6,
        'daily_completed': 0,
        'created_at': now,
      },
      {
        'id': 'eye_reminder',
        'reminder_type': 'eye',
        'interval_minutes': 45,
        'is_enabled': 0,
        'daily_target': 10,
        'daily_completed': 0,
        'created_at': now,
      },
    ];

    for (final reminder in defaults) {
      await db.insert(
        'health_reminders',
        reminder,
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
    }
  }

  static Future<void> _insertDefaultWallet(DatabaseExecutor db) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    await db.insert(
      'user_wallet',
      {
        'id': 'main_wallet',
        'coins': 50,
        'total_earned': 50,
        'total_spent': 0,
        'updated_at': now,
      },
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  static Future<Map<String, dynamic>> exportData() async {
    final db = await database;
    final export = <String, dynamic>{
      'schema_version': _databaseVersion,
      'exported_at': DateTime.now().toIso8601String(),
    };

    for (final table in _exportTables) {
      export[table] = await db.query(table);
    }

    return export;
  }

  static Future<void> importData(Map<String, dynamic> data) async {
    final db = await database;

    await db.transaction((txn) async {
      await _clearTransactionalData(txn);
      await _restoreImportedData(txn, data);
      await _ensureRequiredSeedData(txn);
    });
  }

  static Future<void> clearAllData() async {
    final db = await database;
    await db.transaction((txn) async {
      await _clearTransactionalData(txn);
      await _seedDefaultData(txn);
    });
  }

  static Future<void> _restoreTable(
    DatabaseExecutor db,
    String table,
    dynamic rawData,
  ) async {
    if (rawData is! List) {
      return;
    }

    for (final row in rawData) {
      if (row is Map) {
        await db.insert(
          table,
          Map<String, Object?>.from(row.cast<String, Object?>()),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    }
  }

  static Future<bool> _isTableEmpty(DatabaseExecutor db, String table) async {
    final result = await db.rawQuery('SELECT COUNT(*) AS count FROM $table');
    return Sqflite.firstIntValue(result) == 0;
  }

  static Future<void> _clearTransactionalData(DatabaseExecutor db) async {
    for (final table in _clearOrder) {
      await db.delete(table);
    }
  }

  static Future<void> _restoreImportedData(
    DatabaseExecutor db,
    Map<String, dynamic> data,
  ) async {
    for (final table in _restoreOrder) {
      await _restoreTable(db, table, data[table]);
    }
  }

  static Future<void> _seedDefaultData(DatabaseExecutor db) async {
    await _insertDefaultCategories(db);
    await _insertDefaultAchievements(db);
    await _insertDefaultUserProgress(db);
    await _insertDefaultHealthReminders(db);
    await _insertDefaultWallet(db);
  }

  static Future<void> _ensureRequiredSeedData(DatabaseExecutor db) async {
    if (await _isTableEmpty(db, 'categories')) {
      await _insertDefaultCategories(db);
    }
    if (await _isTableEmpty(db, 'achievements')) {
      await _insertDefaultAchievements(db);
    }
    if (await _isTableEmpty(db, 'user_progress')) {
      await _insertDefaultUserProgress(db);
    }
    if (await _isTableEmpty(db, 'health_reminders')) {
      await _insertDefaultHealthReminders(db);
    }
    if (await _isTableEmpty(db, 'user_wallet')) {
      await _insertDefaultWallet(db);
    }
  }

  static Future<void> _onUpgrade(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
    await MigrationHelper.upgradeDatabase(db, oldVersion, newVersion);
    await _ensureIndexes(db);
    await _ensureRequiredSeedData(db);
  }

  static Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }
}
