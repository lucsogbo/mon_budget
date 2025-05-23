import 'package:sqflite/sqflite.dart';
import '../model/revenu.dart';
import '../db/DatabaseHelper.dart';

class RevenuService {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  Future<int> insertRevenu(Revenu revenu) async {
    final db = await _dbHelper.database;
    return await db.insert('revenus', revenu.toMap());
  }

  Future<List<Revenu>> getAllRevenus() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('revenus', orderBy: 'date DESC');
    return List.generate(maps.length, (i) => Revenu.fromMap(maps[i]));
  }

  Future<int> updateRevenu(Revenu revenu) async {
    final db = await _dbHelper.database;
    return await db.update(
      'revenus',
      revenu.toMap(),
      where: 'id = ?',
      whereArgs: [revenu.id],
    );
  }

  Future<int> deleteRevenu(int id) async {
    final db = await _dbHelper.database;
    return await db.delete('revenus', where: 'id = ?', whereArgs: [id]);
  }
}
