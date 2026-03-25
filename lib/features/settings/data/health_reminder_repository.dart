import 'package:sqflite/sqflite.dart';

import '../../../core/database/database_helper.dart';
import '../domain/health_reminder.dart';

class HealthReminderRepository {
  Future<Database> get _db => DatabaseHelper.database;

  Future<List<HealthReminder>> getAllReminders() async {
    final db = await _db;
    final rows = await db.query(
      'health_reminders',
      orderBy: 'interval_minutes ASC',
    );
    return rows.map((row) => HealthReminder.fromMap(row)).toList();
  }

  Future<void> updateReminder(HealthReminder reminder) async {
    final db = await _db;
    await db.update(
      'health_reminders',
      {
        'interval_minutes': reminder.intervalMinutes,
        'is_enabled': reminder.isEnabled ? 1 : 0,
      },
      where: 'id = ?',
      whereArgs: [reminder.id],
    );
  }

  Future<void> resetDailyProgress() async {
    final db = await _db;
    await db.execute('''
      UPDATE health_reminders
      SET daily_completed = 0
      WHERE daily_completed > 0
    ''');
  }
}
