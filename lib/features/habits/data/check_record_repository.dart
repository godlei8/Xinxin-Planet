import 'package:sqflite/sqflite.dart';

import '../../../core/database/database_helper.dart';
import '../domain/check_record.dart';

class CheckRecordRepository {
  Future<Database> get _db => DatabaseHelper.database;

  Future<List<CheckRecord>> getAllRecords() async {
    final db = await _db;
    final maps = await db.query('check_records', orderBy: 'check_time DESC');
    return maps.map((map) => CheckRecord.fromMap(map)).toList();
  }

  Future<List<CheckRecord>> getRecordsByHabitId(String habitId) async {
    final db = await _db;
    final maps = await db.query(
      'check_records',
      where: 'habit_id = ?',
      whereArgs: [habitId],
      orderBy: 'check_time DESC',
    );
    return maps.map((map) => CheckRecord.fromMap(map)).toList();
  }

  Future<List<CheckRecord>> getRecordsByDate(String date) async {
    final db = await _db;
    final maps = await db.query(
      'check_records',
      where: 'check_date = ?',
      whereArgs: [date],
      orderBy: 'check_time DESC',
    );
    return maps.map((map) => CheckRecord.fromMap(map)).toList();
  }

  Future<CheckRecord?> getRecordByHabitAndDate(
      String habitId, String date) async {
    final db = await _db;
    final maps = await db.query(
      'check_records',
      where: 'habit_id = ? AND check_date = ?',
      whereArgs: [habitId, date],
      limit: 1,
    );
    if (maps.isEmpty) {
      return null;
    }
    return CheckRecord.fromMap(maps.first);
  }

  Future<bool> hasCheckedIn(String habitId, String date) async {
    final record = await getRecordByHabitAndDate(habitId, date);
    return record != null;
  }

  Future<bool> insertRecord(CheckRecord record) async {
    final existing =
        await getRecordByHabitAndDate(record.habitId, record.checkDate);
    if (existing != null) {
      return false;
    }

    final db = await _db;
    await db.insert(
      'check_records',
      record.toMap(),
      conflictAlgorithm: ConflictAlgorithm.abort,
    );
    return true;
  }

  Future<void> updateRecord(CheckRecord record) async {
    final db = await _db;
    await db.update(
      'check_records',
      record.toMap(),
      where: 'id = ?',
      whereArgs: [record.id],
    );
  }

  Future<void> deleteRecord(String id) async {
    final db = await _db;
    await db.delete('check_records', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> deleteRecordsByHabitId(String habitId) async {
    final db = await _db;
    await db
        .delete('check_records', where: 'habit_id = ?', whereArgs: [habitId]);
  }

  Future<List<String>> getCheckedDatesForHabit(String habitId) async {
    final db = await _db;
    final maps = await db.query(
      'check_records',
      columns: ['check_date'],
      where: 'habit_id = ?',
      whereArgs: [habitId],
      orderBy: 'check_date DESC',
    );
    return maps.map((map) => map['check_date'] as String).toList();
  }

  Future<int> getTotalCheckInCount() async {
    final db = await _db;
    final result =
        await db.rawQuery('SELECT COUNT(*) as count FROM check_records');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<List<CheckRecord>> getRecordsInDateRange(
      String startDate, String endDate) async {
    final db = await _db;
    final maps = await db.query(
      'check_records',
      where: 'check_date >= ? AND check_date <= ?',
      whereArgs: [startDate, endDate],
      orderBy: 'check_date ASC',
    );
    return maps.map((map) => CheckRecord.fromMap(map)).toList();
  }
}
