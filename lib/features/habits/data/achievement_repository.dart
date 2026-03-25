import 'package:sqflite/sqflite.dart';
import '../../../core/database/database_helper.dart';
import '../domain/achievement.dart';

class AchievementRepository {
  Future<Database> get _db => DatabaseHelper.database;

  Future<List<Achievement>> getAllAchievements() async {
    final db = await _db;
    final maps =
        await db.query('achievements', orderBy: 'unlock_threshold ASC');
    return maps.map((map) => Achievement.fromMap(map)).toList();
  }

  Future<List<Achievement>> getUnlockedAchievements() async {
    final db = await _db;
    final maps = await db.query(
      'achievements',
      where: 'is_unlocked = ?',
      whereArgs: [1],
      orderBy: 'unlocked_at DESC',
    );
    return maps.map((map) => Achievement.fromMap(map)).toList();
  }

  Future<Achievement?> getAchievementById(String id) async {
    final db = await _db;
    final maps =
        await db.query('achievements', where: 'id = ?', whereArgs: [id]);
    if (maps.isEmpty) return null;
    return Achievement.fromMap(maps.first);
  }

  Future<void> unlockAchievement(String id) async {
    final db = await _db;
    await db.update(
      'achievements',
      {'is_unlocked': 1, 'unlocked_at': DateTime.now().millisecondsSinceEpoch},
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
