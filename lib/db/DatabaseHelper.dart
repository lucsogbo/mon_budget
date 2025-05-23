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
    try {
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

      // Insertions par défaut
      await db.execute('''
        INSERT INTO categories (libelle) VALUES
        ('Alimentation'), ('Transport'), ('Loisir'), ('Santé'), ('Logement')
      ''');

      await db.execute('''
        INSERT INTO depenses (montant, date, libelle, categorieId, observation) VALUES
        (2500, '2025-05-01', 'Courses', 1, 'Supermarché'),
        (5000, '2025-05-05', 'Taxi', 2, ''),
        (3000, '2025-05-10', 'Cinéma', 3, 'Séance Marvel')
      ''');

      await db.execute('''
        INSERT INTO revenus (montant, date, libelle, observation) VALUES
        (20000, '2025-05-01', 'Salaire', ''),
        (5000, '2025-05-10', 'Freelance', 'Projet mobile')
      ''');

      await db.execute('''
        INSERT INTO budgets (montant, categorieId, periodicite) VALUES
        (15000, 1, 'Mensuel'),
        (8000, 2, 'Mensuel'),
        (5000, 3, 'Mensuel')
      ''');
    } catch (e) {
      print('Erreur lors de la création de la base : \$e');
    }
  }
}
