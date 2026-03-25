import 'package:sqflite/sqflite.dart';

class MigrationHelper {
  const MigrationHelper._();

  static Future<void> upgradeDatabase(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
    if (oldVersion < 2 && newVersion >= 2) {
      await _upgradeToV2(db);
    }
    if (oldVersion < 3 && newVersion >= 3) {
      await _upgradeToV3(db);
    }
    if (oldVersion < 4 && newVersion >= 4) {
      await _upgradeToV4(db);
    }
  }

  static Future<void> _upgradeToV2(Database db) async {
    if (!await _columnExists(db, 'check_records', 'image_path')) {
      await db.execute('ALTER TABLE check_records ADD COLUMN image_path TEXT');
    }
  }

  static Future<void> _upgradeToV3(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS focus_forest (
        id TEXT PRIMARY KEY,
        duration_sec INTEGER NOT NULL,
        tree_type TEXT NOT NULL,
        tree_size TEXT NOT NULL,
        planted_at INTEGER NOT NULL,
        is_alive INTEGER DEFAULT 1
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS health_reminders (
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

  static Future<void> _upgradeToV4(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS user_wallet (
        id TEXT PRIMARY KEY,
        coins INTEGER DEFAULT 0,
        total_earned INTEGER DEFAULT 0,
        total_spent INTEGER DEFAULT 0,
        updated_at INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS user_inventory (
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
      CREATE TABLE IF NOT EXISTS supervision_partners (
        id TEXT PRIMARY KEY,
        partner_name TEXT NOT NULL,
        relation TEXT DEFAULT 'friend',
        avatar_emoji TEXT DEFAULT '🐰',
        created_at INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS supervision_logs (
        id TEXT PRIMARY KEY,
        partner_id TEXT NOT NULL,
        action_type TEXT NOT NULL,
        message TEXT NOT NULL,
        created_at INTEGER NOT NULL,
        FOREIGN KEY (partner_id) REFERENCES supervision_partners (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS sleep_sessions (
        id TEXT PRIMARY KEY,
        duration_min INTEGER NOT NULL,
        completed INTEGER DEFAULT 0,
        mood_after INTEGER DEFAULT 3,
        created_at INTEGER NOT NULL
      )
    ''');

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

  static Future<bool> _columnExists(
    DatabaseExecutor db,
    String table,
    String column,
  ) async {
    final rows = await db.rawQuery('PRAGMA table_info($table)');
    for (final row in rows) {
      if ((row['name'] as String?) == column) {
        return true;
      }
    }
    return false;
  }
}
