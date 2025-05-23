import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;

  static Database? _database;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDb();
    return _database!;
  }

  Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'mon_budget.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE categories (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        libelle TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE depenses (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        montant REAL NOT NULL,
        date TEXT NOT NULL,
        categorieId INTEGER,
        libelle TEXT,
        observation TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE revenus (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        montant REAL NOT NULL,
        date TEXT NOT NULL,
        libelle TEXT,
        observation TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE budgets (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        categorieId INTEGER NOT NULL,
        montant REAL NOT NULL,
        periodicite TEXT NOT NULL
      )
    ''');
  }
}
