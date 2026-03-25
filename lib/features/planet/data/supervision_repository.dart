import 'dart:math';

import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

import '../../../core/database/database_helper.dart';
import '../domain/supervision_partner.dart';

class SupervisionRepository {
  SupervisionRepository();

  static const _uuid = Uuid();
  static final _random = Random();

  Future<Database> get _db => DatabaseHelper.database;

  Future<List<SupervisionPartner>> getPartners() async {
    final db = await _db;
    final rows = await db.query(
      'supervision_partners',
      orderBy: 'created_at DESC',
    );
    return rows.map((row) => SupervisionPartner.fromMap(row)).toList();
  }

  Future<List<Map<String, dynamic>>> getLogs() async {
    final db = await _db;
    return db.rawQuery('''
      SELECT l.id, l.action_type, l.message, l.created_at, p.partner_name, p.avatar_emoji
      FROM supervision_logs l
      LEFT JOIN supervision_partners p ON p.id = l.partner_id
      ORDER BY l.created_at DESC
      LIMIT 60
    ''');
  }

  Future<void> addPartner({
    required String name,
    required String relation,
    required String avatarEmoji,
  }) async {
    final db = await _db;
    final now = DateTime.now().millisecondsSinceEpoch;
    final id = _uuid.v4();
    await db.insert('supervision_partners', {
      'id': id,
      'partner_name': name,
      'relation': relation,
      'avatar_emoji': avatarEmoji,
      'created_at': now,
    });
    await _insertLog(
      db: db,
      partnerId: id,
      actionType: 'join',
      message: '$name 已加入监督小队，今天一起加油。',
    );
  }

  Future<void> createEncourageLog(String partnerId, String partnerName) async {
    final db = await _db;
    final messages = [
      '$partnerName 说：今天也坚持一点点，你已经很棒了。',
      '$partnerName 提醒：把目标拆小，完成一个就值得庆祝。',
      '$partnerName 打气：别追求完美，先完成再优化。',
      '$partnerName 鼓励：稳定比爆发更厉害，继续保持。',
    ];
    await _insertLog(
      db: db,
      partnerId: partnerId,
      actionType: 'encourage',
      message: messages[_random.nextInt(messages.length)],
    );
  }

  Future<void> _insertLog({
    required DatabaseExecutor db,
    required String partnerId,
    required String actionType,
    required String message,
  }) async {
    await db.insert('supervision_logs', {
      'id': _uuid.v4(),
      'partner_id': partnerId,
      'action_type': actionType,
      'message': message,
      'created_at': DateTime.now().millisecondsSinceEpoch,
    });
  }
}
