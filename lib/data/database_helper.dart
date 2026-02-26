import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/product.dart';
import '../models/order.dart';
import '../models/shop.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('dms_offline.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';
    const doubleType = 'REAL NOT NULL';
    const integerType = 'INTEGER NOT NULL';

    await db.execute('''
      CREATE TABLE products (
        id $idType,
        name $textType,
        price $doubleType,
        stock $integerType,
        isSynced $integerType
      )
    ''');

    await db.execute('''
      CREATE TABLE shops (
        id $idType,
        name $textType,
        address $textType,
        phone $textType,
        isSynced $integerType
      )
    ''');

    await db.execute('''
      CREATE TABLE orders (
        id $idType,
        shopId $integerType,
        totalAmount $doubleType,
        date $textType,
        isSynced $integerType,
        FOREIGN KEY (shopId) REFERENCES shops (id)
      )
    ''');
  }

  // --- Product Operations ---
  Future<int> insertProduct(Product product) async {
    final db = await instance.database;
    return await db.insert('products', product.toMap());
  }

  Future<List<Product>> getProducts() async {
    final db = await instance.database;
    final result = await db.query('products');
    return result.map((json) => Product.fromMap(json)).toList();
  }

  Future<int> updateProduct(Product product) async {
    final db = await instance.database;
    return await db.update(
      'products',
      product.toMap(),
      where: 'id = ?',
      whereArgs: [product.id],
    );
  }

  Future<int> deleteProduct(int id) async {
    final db = await instance.database;
    return await db.delete(
      'products',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // --- Shop Operations ---
  Future<int> insertShop(Shop shop) async {
    final db = await instance.database;
    return await db.insert('shops', shop.toMap());
  }

  Future<List<Shop>> getShops() async {
    final db = await instance.database;
    final result = await db.query('shops');
    return result.map((json) => Shop.fromMap(json)).toList();
  }

  Future<int> updateShop(Shop shop) async {
    final db = await instance.database;
    return await db.update(
      'shops',
      shop.toMap(),
      where: 'id = ?',
      whereArgs: [shop.id],
    );
  }

  Future<int> deleteShop(int id) async {
    final db = await instance.database;
    return await db.delete(
      'shops',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // --- Order Operations ---
  Future<int> insertOrder(OrderModel order) async {
    final db = await instance.database;
    return await db.insert('orders', order.toMap());
  }

  Future<List<OrderModel>> getOrders() async {
    final db = await instance.database;
    final result = await db.query('orders');
    return result.map((json) => OrderModel.fromMap(json)).toList();
  }

  Future<int> updateOrder(OrderModel order) async {
    final db = await instance.database;
    return await db.update(
      'orders',
      order.toMap(),
      where: 'id = ?',
      whereArgs: [order.id],
    );
  }

  Future<int> deleteOrder(int id) async {
    final db = await instance.database;
    return await db.delete(
      'orders',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
