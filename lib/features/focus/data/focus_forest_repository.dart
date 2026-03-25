import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

import '../../../core/database/database_helper.dart';
import '../domain/focus_forest_entry.dart';

class FocusForestRepository {
  FocusForestRepository();

  static const _uuid = Uuid();

  Future<Database> get _db => DatabaseHelper.database;

  Future<List<FocusForestEntry>> getRecentEntries({int limit = 30}) async {
    final db = await _db;
    final maps = await db.query(
      'focus_forest',
      orderBy: 'planted_at DESC',
      limit: limit,
    );
    return maps.map((item) => FocusForestEntry.fromMap(item)).toList();
  }

  Future<void> addSession({
    required int durationSec,
    required bool isAlive,
  }) async {
    final db = await _db;
    final now = DateTime.now().millisecondsSinceEpoch;

    await db.insert('focus_forest', {
      'id': _uuid.v4(),
      'duration_sec': durationSec,
      'tree_type': _resolveTreeType(durationSec),
      'tree_size': _resolveTreeSize(durationSec),
      'planted_at': now,
      'is_alive': isAlive ? 1 : 0,
    });
  }

  String _resolveTreeType(int durationSec) {
    if (durationSec >= 3600) {
      return 'golden';
    }
    if (durationSec >= 2700) {
      return 'pine';
    }
    if (durationSec >= 1500) {
      return 'oak';
    }
    return 'cherry';
  }

  String _resolveTreeSize(int durationSec) {
    if (durationSec >= 3600) {
      return 'ancient';
    }
    if (durationSec >= 1800) {
      return 'tree';
    }
    if (durationSec >= 900) {
      return 'sapling';
    }
    return 'seed';
  }
}
