import 'package:sqflite/sqflite.dart';
import '../../../core/database/database_helper.dart';
import '../domain/habit.dart';

class HabitRepository {
  Future<Database> get _db => DatabaseHelper.database;

  Future<List<Habit>> getAllHabits({bool includeArchived = false}) async {
    final db = await _db;
    final List<Map<String, dynamic>> maps = includeArchived
        ? await db.query('habits', orderBy: 'created_at DESC')
        : await db.query('habits',
            where: 'is_archived = ?',
            whereArgs: [0],
            orderBy: 'created_at DESC');
    return maps.map((map) => Habit.fromMap(map)).toList();
  }

  Future<Habit?> getHabitById(String id) async {
    final db = await _db;
    final maps = await db.query('habits', where: 'id = ?', whereArgs: [id]);
    if (maps.isEmpty) return null;
    return Habit.fromMap(maps.first);
  }

  Future<List<Habit>> getHabitsByCategory(String categoryId) async {
    final db = await _db;
    final maps = await db.query(
      'habits',
      where: 'category_id = ? AND is_archived = ?',
      whereArgs: [categoryId, 0],
      orderBy: 'created_at DESC',
    );
    return maps.map((map) => Habit.fromMap(map)).toList();
  }

  Future<void> insertHabit(Habit habit) async {
    final db = await _db;
    await db.insert('habits', habit.toMap());
  }

  Future<void> updateHabit(Habit habit) async {
    final db = await _db;
    await db.update(
      'habits',
      habit.toMap(),
      where: 'id = ?',
      whereArgs: [habit.id],
    );
  }

  Future<void> deleteHabit(String id) async {
    final db = await _db;
    await db.delete('habits', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> archiveHabit(String id) async {
    final db = await _db;
    await db.update(
      'habits',
      {'is_archived': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> getHabitCount() async {
    final db = await _db;
    final result = await db
        .rawQuery('SELECT COUNT(*) as count FROM habits WHERE is_archived = 0');
    return Sqflite.firstIntValue(result) ?? 0;
  }
}
