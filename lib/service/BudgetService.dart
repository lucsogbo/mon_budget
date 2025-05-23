import 'package:sqflite/sqflite.dart';
import '../model/budget.dart';
import '../db/DatabaseHelper.dart';

class BudgetService {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  Future<int> insertBudget(Budget budget) async {
    final db = await _dbHelper.database;
    return await db.insert('budgets', budget.toMap());
  }

  Future<List<Budget>> getAllBudgets() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('budgets');
    return List.generate(maps.length, (i) => Budget.fromMap(maps[i]));
  }

  Future<int> updateBudget(Budget budget) async {
    final db = await _dbHelper.database;
    return await db.update(
      'budgets',
      budget.toMap(),
      where: 'id = ?',
      whereArgs: [budget.id],
    );
  }

  Future<int> deleteBudget(int id) async {
    final db = await _dbHelper.database;
    return await db.delete('budgets', where: 'id = ?', whereArgs: [id]);
  }

  Future<bool> isDuplicate(int categorieId, String periode) async {
    final db = await _dbHelper.database;
    final result = await db.query(
      'budgets',
      where: 'categorieId = ? AND periode = ?',
      whereArgs: [categorieId, periode],
      limit: 1,
    );
    return result.isNotEmpty;
  }
}
