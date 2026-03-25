import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static const String _databaseName = 'xinxin_planet.db';
  static const int _databaseVersion = 1;

  static const List<String> _exportTables = [
    'habits',
    'check_records',
    'categories',
    'achievements',
    'user_progress',
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
        color_code TEXT DEFAULT '#FF8FA3',
        icon_code TEXT DEFAULT '⭐',
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
        FOREIGN KEY (habit_id) REFERENCES habits (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE categories (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        color_code TEXT DEFAULT '#FF8FA3',
        icon_code TEXT DEFAULT '📦',
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

    await _ensureIndexes(db);
    await _insertDefaultCategories(db);
    await _insertDefaultAchievements(db);
    await _insertDefaultUserProgress(db);
  }

  static Future<void> _ensureIndexes(DatabaseExecutor db) async {
    await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_check_records_habit_id ON check_records (habit_id)');
    await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_check_records_check_date ON check_records (check_date)');
    await db.execute(
      'CREATE UNIQUE INDEX IF NOT EXISTS idx_check_records_habit_date ON check_records (habit_id, check_date)',
    );
  }

  static Future<void> _insertDefaultCategories(DatabaseExecutor db) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final defaultCategories = [
      {
        'id': 'default',
        'name': '日常',
        'color_code': '#FF8FA3',
        'icon_code': '🌷',
        'is_default': 1,
        'created_at': now,
      },
      {
        'id': 'health',
        'name': '健康',
        'color_code': '#74D3AE',
        'icon_code': '💪',
        'is_default': 0,
        'created_at': now,
      },
      {
        'id': 'study',
        'name': '学习',
        'color_code': '#7DB8FF',
        'icon_code': '📚',
        'is_default': 0,
        'created_at': now,
      },
      {
        'id': 'work',
        'name': '工作',
        'color_code': '#FFB86C',
        'icon_code': '💼',
        'is_default': 0,
        'created_at': now,
      },
      {
        'id': 'hobby',
        'name': '兴趣',
        'color_code': '#C7A6FF',
        'icon_code': '🎨',
        'is_default': 0,
        'created_at': now,
      },
    ];

    for (final category in defaultCategories) {
      await db.insert('categories', category);
    }
  }

  static Future<void> _insertDefaultAchievements(DatabaseExecutor db) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final achievements = [
      {
        'id': 'first_checkin',
        'name': '初次闪亮',
        'description': '完成第一次打卡',
        'icon_code': '🎉',
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
        'name': '月度小达人',
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
        'icon_code': '🪄',
        'unlock_threshold': 5,
        'is_unlocked': 0,
        'created_at': now,
      },
    ];

    for (final achievement in achievements) {
      await db.insert('achievements', achievement);
    }
  }

  static Future<void> _insertDefaultUserProgress(DatabaseExecutor db) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    await db.insert('user_progress', {
      'id': 'main_progress',
      'total_check_ins': 0,
      'current_streak': 0,
      'best_streak': 0,
      'planet_level': 1,
      'unlocked_decorations': '[]',
      'created_at': now,
      'updated_at': now,
    });
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
      await txn.delete('check_records');
      await txn.delete('habits');
      await txn.delete('categories');
      await txn.delete('achievements');
      await txn.delete('user_progress');

      await _restoreTable(txn, 'categories', data['categories']);
      await _restoreTable(txn, 'habits', data['habits']);
      await _restoreTable(txn, 'check_records', data['check_records']);
      await _restoreTable(txn, 'achievements', data['achievements']);
      await _restoreTable(txn, 'user_progress', data['user_progress']);

      if (await _isTableEmpty(txn, 'categories')) {
        await _insertDefaultCategories(txn);
      }
      if (await _isTableEmpty(txn, 'achievements')) {
        await _insertDefaultAchievements(txn);
      }
      if (await _isTableEmpty(txn, 'user_progress')) {
        await _insertDefaultUserProgress(txn);
      }
    });
  }

  static Future<void> clearAllData() async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.delete('check_records');
      await txn.delete('habits');
      await txn.delete('categories');
      await txn.delete('achievements');
      await txn.delete('user_progress');
      await _insertDefaultCategories(txn);
      await _insertDefaultAchievements(txn);
      await _insertDefaultUserProgress(txn);
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

  static Future<void> _onUpgrade(
      Database db, int oldVersion, int newVersion) async {
    await _ensureIndexes(db);
  }

  static Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }
}
