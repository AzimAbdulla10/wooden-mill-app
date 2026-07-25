import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DbHelper {
  static final DbHelper instance = DbHelper._init();
  static Database? _database;

  DbHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('orders.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
      onConfigure: _onConfigure,
    );
  }

  Future<void> _onConfigure(Database db) async {
    // Enable foreign key support
    await db.execute('PRAGMA foreign_keys = ON');
  }

  Future<void> _createDB(Database db, int version) async {
    // Create Orders Table
    await db.execute('''
      CREATE TABLE Orders (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        customerName TEXT NOT NULL,
        phone TEXT NOT NULL,
        woodType TEXT NOT NULL,
        numberOfLogs INTEGER NOT NULL,
        totalVolume REAL NOT NULL,
        subtotal REAL NOT NULL,
        cuttingCharge REAL NOT NULL,
        discount REAL NOT NULL,
        finalPrice REAL NOT NULL,
        dateTime TEXT NOT NULL
      )
    ''');

    // Create LogDimensions Table
    await db.execute('''
      CREATE TABLE LogDimensions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        orderId INTEGER NOT NULL,
        length REAL NOT NULL,
        girth REAL NOT NULL,
        volume REAL NOT NULL,
        price REAL NOT NULL,
        FOREIGN KEY (orderId) REFERENCES Orders (id) ON DELETE CASCADE
      )
    ''');
  }

  Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
    }
  }
}
