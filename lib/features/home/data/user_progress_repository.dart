import 'package:sqflite/sqflite.dart';
import '../../../core/database/database_helper.dart';
import '../domain/user_progress.dart';

class UserProgressRepository {
  Future<Database> get _db => DatabaseHelper.database;

  Future<UserProgress> getUserProgress() async {
    final db = await _db;
    final maps = await db
        .query('user_progress', where: 'id = ?', whereArgs: ['main_progress']);
    if (maps.isEmpty) {
      throw Exception('User progress not found');
    }
    return UserProgress.fromMap(maps.first);
  }

  Future<void> updateUserProgress(UserProgress progress) async {
    final db = await _db;
    await db.update(
      'user_progress',
      progress.toMap(),
      where: 'id = ?',
      whereArgs: [progress.id],
    );
  }

  Future<void> incrementCheckIns() async {
    final progress = await getUserProgress();
    final updated = progress.copyWith(
      totalCheckIns: progress.totalCheckIns + 1,
      updatedAt: DateTime.now().millisecondsSinceEpoch,
    );
    await updateUserProgress(updated);
  }

  Future<void> updateStreak(
      int currentStreak, int bestStreak, String lastCheckInDate) async {
    final progress = await getUserProgress();
    final updated = progress.copyWith(
      currentStreak: currentStreak,
      bestStreak: bestStreak,
      lastCheckInDate: lastCheckInDate,
      updatedAt: DateTime.now().millisecondsSinceEpoch,
    );
    await updateUserProgress(updated);
  }

  Future<void> updatePlanetLevel(int level) async {
    final progress = await getUserProgress();
    final updated = progress.copyWith(
      planetLevel: level,
      updatedAt: DateTime.now().millisecondsSinceEpoch,
    );
    await updateUserProgress(updated);
  }

  Future<void> addDecoration(String decoration) async {
    final progress = await getUserProgress();
    final newDecorations = [...progress.unlockedDecorations, decoration];
    final updated = progress.copyWith(
      unlockedDecorations: newDecorations,
      updatedAt: DateTime.now().millisecondsSinceEpoch,
    );
    await updateUserProgress(updated);
  }
}
