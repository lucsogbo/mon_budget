import 'package:sqflite/sqflite.dart';
import '../model/depense.dart';
import '../db/DatabaseHelper.dart';

class DepenseService {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  Future<int> insertDepense(Depense depense) async {
    final db = await _dbHelper.database;
    return await db.insert('depenses', depense.toMap());
  }

  Future<List<Depense>> getAllDepenses() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('depenses', orderBy: 'date DESC');
    return List.generate(maps.length, (i) => Depense.fromMap(maps[i]));
  }

  Future<int> updateDepense(Depense depense) async {
    final db = await _dbHelper.database;
    return await db.update(
      'depenses',
      depense.toMap(),
      where: 'id = ?',
      whereArgs: [depense.id],
    );
  }

  Future<int> deleteDepense(int id) async {
    final db = await _dbHelper.database;
    return await db.delete('depenses', where: 'id = ?', whereArgs: [id]);
  }
}
