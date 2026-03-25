import 'dart:math';

import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

import '../../../core/database/database_helper.dart';
import '../domain/gacha_item.dart';

class GachaRepository {
  GachaRepository();

  static const int drawCost = 10;
  static const _uuid = Uuid();
  static final _random = Random();

  static const List<GachaItem> _pool = [
    GachaItem(
      itemId: 'bg_cotton',
      name: '棉花云背景',
      emoji: '☁️',
      rarity: 1,
      itemType: 'bg',
    ),
    GachaItem(
      itemId: 'bg_candy',
      name: '糖果街背景',
      emoji: '🍬',
      rarity: 1,
      itemType: 'bg',
    ),
    GachaItem(
      itemId: 'badge_ribbon',
      name: '蝴蝶结徽章',
      emoji: '🎀',
      rarity: 2,
      itemType: 'badge',
    ),
    GachaItem(
      itemId: 'badge_star',
      name: '星愿徽章',
      emoji: '🌟',
      rarity: 2,
      itemType: 'badge',
    ),
    GachaItem(
      itemId: 'deco_castle',
      name: '梦幻城堡摆件',
      emoji: '🏰',
      rarity: 3,
      itemType: 'decoration',
    ),
  ];

  Future<Database> get _db => DatabaseHelper.database;

  Future<int> getCoins() async {
    final db = await _db;
    await _ensureWallet(db);
    final result = await db.query(
      'user_wallet',
      columns: ['coins'],
      where: 'id = ?',
      whereArgs: ['main_wallet'],
      limit: 1,
    );
    if (result.isEmpty) {
      return 0;
    }
    return result.first['coins'] as int? ?? 0;
  }

  Future<List<Map<String, dynamic>>> getInventory() async {
    final db = await _db;
    return db.query('user_inventory', orderBy: 'acquired_at DESC');
  }

  Future<void> addCoins(int amount) async {
    final db = await _db;
    await _ensureWallet(db);
    final now = DateTime.now().millisecondsSinceEpoch;
    await db.rawUpdate(
      '''
      UPDATE user_wallet
      SET coins = coins + ?,
          total_earned = total_earned + ?,
          updated_at = ?
      WHERE id = 'main_wallet'
      ''',
      [amount, amount, now],
    );
  }

  Future<GachaItem> drawOnce() async {
    final db = await _db;
    return db.transaction((txn) async {
      await _ensureWallet(txn);
      final walletRows = await txn.query(
        'user_wallet',
        where: 'id = ?',
        whereArgs: ['main_wallet'],
        limit: 1,
      );
      final coins =
          walletRows.isEmpty ? 0 : (walletRows.first['coins'] as int? ?? 0);
      if (coins < drawCost) {
        throw Exception('金币不足，当前仅有 $coins');
      }

      final item = _pickWeightedItem();
      final now = DateTime.now().millisecondsSinceEpoch;
      await txn.rawUpdate(
        '''
        UPDATE user_wallet
        SET coins = coins - ?,
            total_spent = total_spent + ?,
            updated_at = ?
        WHERE id = 'main_wallet'
        ''',
        [drawCost, drawCost, now],
      );

      await txn.insert('user_inventory', {
        'id': _uuid.v4(),
        'item_id': item.itemId,
        'item_name': '${item.emoji} ${item.name}',
        'item_type': item.itemType,
        'rarity': item.rarity,
        'acquired_at': now,
        'source': 'gacha',
      });

      return item;
    });
  }

  GachaItem _pickWeightedItem() {
    final weighted = <GachaItem>[];
    for (final item in _pool) {
      final weight = switch (item.rarity) {
        1 => 55,
        2 => 30,
        _ => 15,
      };
      for (var i = 0; i < weight; i++) {
        weighted.add(item);
      }
    }
    return weighted[_random.nextInt(weighted.length)];
  }

  Future<void> _ensureWallet(DatabaseExecutor db) async {
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
}
