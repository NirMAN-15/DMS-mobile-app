import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/shop.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'dms_mobile.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Create shops table
    await db.execute('''
      CREATE TABLE shops(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        address TEXT,
        latitude REAL,
        longitude REAL,
        isVisited INTEGER
      )
    ''');

    // Create a dummy auth table to handle offline login / mock JWT
    await db.execute('''
      CREATE TABLE auth_session(
        id INTEGER PRIMARY KEY,
        token TEXT,
        username TEXT,
        isLogged INTEGER
      )
    ''');

    // Insert dummy shops for the route list
    await _insertDummyData(db);
  }

  Future<void> _insertDummyData(Database db) async {
    List<Map<String, dynamic>> dummyShops = [
      {'name': 'Supermart Central', 'address': '123 Main St, City Center', 'latitude': 40.7128, 'longitude': -74.0060, 'isVisited': 0},
      {'name': 'Corner Store', 'address': '45 Elm St, Westside', 'latitude': 40.7138, 'longitude': -74.0160, 'isVisited': 0},
      {'name': 'Mega Grocery', 'address': '789 Oak Ave, Eastside', 'latitude': 40.7228, 'longitude': -73.9960, 'isVisited': 0},
      {'name': 'Daily Needs', 'address': '12 Pine Ln, Northville', 'latitude': 40.7028, 'longitude': -74.0160, 'isVisited': 0},
    ];

    for (var shop in dummyShops) {
      await db.insert('shops', shop);
    }
  }

  // --- Auth Methods ---
  Future<bool> login(String username, String password) async {
    // Dummy login: accept any non-empty username/password
    if (username.isNotEmpty && password.isNotEmpty) {
      final db = await database;
      // Clear previous sessions
      await db.delete('auth_session');
      // Store new session
      await db.insert('auth_session', {
        'id': 1,
        'token': 'mock_jwt_token_12345',
        'username': username,
        'isLogged': 1,
      });
      return true;
    }
    return false;
  }

  Future<void> logout() async {
    final db = await database;
    await db.delete('auth_session');
  }

  Future<bool> isLoggedIn() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('auth_session');
    return maps.isNotEmpty && maps.first['isLogged'] == 1;
  }

  // --- Shop/Route Methods ---
  Future<List<Shop>> getShops() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('shops');
    return List.generate(maps.length, (i) {
      return Shop.fromMap(maps[i]);
    });
  }

  Future<void> markShopVisited(int id) async {
    final db = await database;
    await db.update(
      'shops',
      {'isVisited': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
