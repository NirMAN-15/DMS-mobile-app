import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:dms_mobile_app/data/database_helper.dart';
import 'package:dms_mobile_app/models/product.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

void main() {
  setUpAll(() {
    // Initialize FFI for unit testing
    sqfliteFfiInit();
    
    // Change the default factory for SQFlite calls
    // This allows SQLite execution in a pure desktop environment
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    // Ensure we start with a clean database environment for the test execution
    // Note: Due to singleton nature of DatabaseHelper, _database might hold a cached reference
    // To handle edge cases in testing, ensure the physical file starts clean.
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'dms_offline.db');
    await deleteDatabase(path);
  });

  test('Initialize SQLite database, insert a dummy Product, and read it back', () async {
    final dbHelper = DatabaseHelper.instance;

    // 1. Initialize the SQLite database
    final db = await dbHelper.database;
    expect(db.isOpen, isTrue, reason: 'Database should be initialized and open');

    // 2. Insert a dummy Product
    final dummyProduct = Product(
      name: 'Test Product',
      price: 25.50,
      stock: 100,
      isSynced: 0,
    );

    final insertedId = await dbHelper.insertProduct(dummyProduct);
    
    // Verify insertion was successful (returns a positive ID)
    expect(insertedId, isPositive, reason: 'Insert operation should return a positive ID');

    // 3. Read that Product back from local storage accurately
    final products = await dbHelper.getProducts();

    // Verify exactly one product exists
    expect(products.length, 1, reason: 'There should be exactly one product in the database');

    final fetchedProduct = products.first;
    
    // Validate that the fields match the inserted dummy Product accurately
    expect(fetchedProduct.id, insertedId);
    expect(fetchedProduct.name, 'Test Product');
    expect(fetchedProduct.price, 25.50);
    expect(fetchedProduct.stock, 100);
    expect(fetchedProduct.isSynced, 0);
  });
}
