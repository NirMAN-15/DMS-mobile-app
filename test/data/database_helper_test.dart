import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite/sqflite.dart';
import 'package:dms_mobile/data/database_helper.dart';
import 'package:dms_mobile/models/shop.dart';
import 'package:dms_mobile/models/product.dart';

void main() {
  late DatabaseHelper dbHelper;

  setUpAll(() {
    // Initialize FFI for unit testing SQLite on desktop environments
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    dbHelper = DatabaseHelper();
    final db = await dbHelper.database;
    
    // Clear all tables to ensure tests run in isolation
    await db.delete('shops');
    await db.delete('products');
    await db.delete('auth_session');
  });

  group('DatabaseHelper - Auth Methods', () {
    test('login() saves session and returns true when credentials are provided', () async {
      final success = await dbHelper.login('testuser', 'password123');
      expect(success, isTrue);

      final isLoggedIn = await dbHelper.isLoggedIn();
      expect(isLoggedIn, isTrue);

      final token = await dbHelper.getToken();
      expect(token, equals('mock_jwt_token_12345'));
    });

    test('login() returns false for empty credentials', () async {
      final success = await dbHelper.login('', '');
      expect(success, isFalse);

      final isLoggedIn = await dbHelper.isLoggedIn();
      expect(isLoggedIn, isFalse);
    });

    test('logout() clears session', () async {
      await dbHelper.login('testuser', 'password123');
      expect(await dbHelper.isLoggedIn(), isTrue);

      await dbHelper.logout();
      expect(await dbHelper.isLoggedIn(), isFalse);
      expect(await dbHelper.getToken(), isNull);
    });
  });

  group('DatabaseHelper - Shop & Route Methods', () {
    test('syncShops() inserts shops into the database', () async {
      final shop1 = Shop(name: 'Shop A', address: 'Address A', latitude: 10.0, longitude: 20.0);
      final shop2 = Shop(name: 'Shop B', address: 'Address B', latitude: 30.0, longitude: 40.0);

      await dbHelper.syncShops([shop1, shop2]);

      final shops = await dbHelper.getShops();
      expect(shops.length, equals(2));
      expect(shops[0].name, equals('Shop A'));
      expect(shops[1].name, equals('Shop B'));
    });

    test('markShopVisited() updates the isVisited status', () async {
      // First sync a shop
      final shop = Shop(id: 1, name: 'Shop A', address: 'Address A', latitude: 10.0, longitude: 20.0);
      await dbHelper.syncShops([shop]);

      // Initially not visited
      var storedShops = await dbHelper.getShops();
      expect(storedShops.first.isVisited, isFalse);

      // Mark as visited
      await dbHelper.markShopVisited(1);

      // Verify visited
      storedShops = await dbHelper.getShops();
      expect(storedShops.first.isVisited, isTrue);
    });
  });

  group('DatabaseHelper - Product Methods', () {
    test('syncProducts() overwrites existing products', () async {
      final product1 = Product(id: 1, name: 'Product 1', price: 10.0, stock: 5);
      
      await dbHelper.syncProducts([product1]);
      
      final db = await dbHelper.database;
      var count = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM products'));
      expect(count, equals(1));

      // Sync new products to ensure it overwrites
      final product2 = Product(id: 2, name: 'Product 2', price: 20.0, stock: 10);
      await dbHelper.syncProducts([product2]);

      count = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM products'));
      expect(count, equals(1)); // First product should be deleted

      final maps = await db.query('products');
      expect(maps.first['name'], equals('Product 2'));
    });
  });
}
