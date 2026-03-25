import 'package:sqflite/sqflite.dart';
import '../../../core/database/database_helper.dart';
import '../domain/category.dart';

class CategoryRepository {
  Future<Database> get _db => DatabaseHelper.database;

  Future<List<Category>> getAllCategories() async {
    final db = await _db;
    final maps = await db.query('categories',
        orderBy: 'is_default DESC, created_at ASC');
    return maps.map((map) => Category.fromMap(map)).toList();
  }

  Future<Category?> getCategoryById(String id) async {
    final db = await _db;
    final maps = await db.query('categories', where: 'id = ?', whereArgs: [id]);
    if (maps.isEmpty) return null;
    return Category.fromMap(maps.first);
  }

  Future<void> insertCategory(Category category) async {
    final db = await _db;
    await db.insert('categories', category.toMap());
  }

  Future<void> updateCategory(Category category) async {
    final db = await _db;
    await db.update(
      'categories',
      category.toMap(),
      where: 'id = ?',
      whereArgs: [category.id],
    );
  }

  Future<void> deleteCategory(String id) async {
    final db = await _db;
    await db.delete('categories',
        where: 'id = ? AND is_default = ?', whereArgs: [id, 0]);
  }
}
