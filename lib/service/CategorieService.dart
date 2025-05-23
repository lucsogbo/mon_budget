import 'package:sqflite/sqflite.dart';
import '../model/categorie.dart';
import '../db/DatabaseHelper.dart';

class CategorieService {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  Future<int> insertCategorie(Categorie categorie) async {
    final db = await _dbHelper.database;
    return await db.insert('categories', categorie.toMap());
  }

  Future<List<Categorie>> getAllCategories() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('categories');
    return List.generate(maps.length, (i) => Categorie.fromMap(maps[i]));
  }

  Future<int> updateCategorie(Categorie categorie) async {
    final db = await _dbHelper.database;
    return await db.update(
      'categories',
      categorie.toMap(),
      where: 'id = ?',
      whereArgs: [categorie.id],
    );
  }

  Future<int> deleteCategorie(int id) async {
    final db = await _dbHelper.database;
    return await db.delete('categories', where: 'id = ?', whereArgs: [id]);
  }

  Future<bool> isUsedInDepense(int id) async {
    final db = await _dbHelper.database;
    final result = await db.query('depenses',
        where: 'categorieId = ?', whereArgs: [id], limit: 1);
    return result.isNotEmpty;
  }
}
