import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:dms_mobile/services/api_service.dart';
import 'package:dms_mobile/data/database_helper.dart';

void main() {
  late DatabaseHelper dbHelper;

  setUpAll(() {
    // Initialize FFI for local SQLite DB which ApiService indirectly depends on
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    dbHelper = DatabaseHelper();
    final db = await dbHelper.database;
    await db.delete('auth_session');
    await db.delete('shops');
    await db.delete('products');
  });

  test('performMorningSync throws exception if no JWT token is present', () async {
    final client = MockClient((request) async {
      return http.Response('', 200);
    });
    
    final apiService = ApiService(client: client);
    
    expect(
      () => apiService.performMorningSync(),
      throwsA(isA<Exception>().having((e) => e.toString(), 'message', contains('Invalid or missing JWT token'))),
    );
  });

  test('performMorningSync attaches JWT and syncs data to local DB', () async {
    // 1. Log in to simulate an existing JWT token
    await dbHelper.login('testuser', 'testpass');
    
    // 2. Create a MockClient that verifies the Authorization header
    final client = MockClient((request) async {
      // Verify strict HTTPS and headers
      expect(request.url.scheme, equals('https'));
      expect(request.url.host, equals('api.example.com'));
      expect(request.headers['Authorization'], equals('Bearer mock_jwt_token_12345'));
      
      // Return a dummy successful response
      return http.Response('{"status": "success"}', 200);
    });

    final apiService = ApiService(client: client);
    
    // 3. Perform the sync
    await apiService.performMorningSync();
    
    // 4. Verify data was saved locally (since ApiService hardcodes mock data saving for now)
    final shops = await dbHelper.getShops();
    expect(shops.length, equals(2));
    expect(shops[0].name, equals('Cloud Mart (Synced)'));

    final db = await dbHelper.database;
    final productsCount = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM products'));
    expect(productsCount, equals(2));
  });
}
