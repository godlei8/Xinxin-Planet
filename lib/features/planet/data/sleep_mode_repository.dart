import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

import '../../../core/database/database_helper.dart';

class SleepModeRepository {
  SleepModeRepository();

  static const _uuid = Uuid();

  Future<Database> get _db => DatabaseHelper.database;

  Future<void> addSession({
    required int durationMin,
    required bool completed,
    required int moodAfter,
  }) async {
    final db = await _db;
    await db.insert('sleep_sessions', {
      'id': _uuid.v4(),
      'duration_min': durationMin,
      'completed': completed ? 1 : 0,
      'mood_after': moodAfter,
      'created_at': DateTime.now().millisecondsSinceEpoch,
    });
  }

  Future<List<Map<String, dynamic>>> recentSessions() async {
    final db = await _db;
    return db.query('sleep_sessions', orderBy: 'created_at DESC', limit: 30);
  }
}
