import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite/sqflite.dart';
import 'package:dms_mobile/screens/route_list_screen.dart';
import 'package:dms_mobile/data/database_helper.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    final dbHelper = DatabaseHelper();
    final db = await dbHelper.database;
    await db.delete('shops');
    
    // Insert some mock shops directly
    await db.insert('shops', {
      'name': 'Test Shop 1',
      'address': 'Address 1',
      'latitude': 0.0,
      'longitude': 0.0,
      'isVisited': 0
    });
    
    await db.insert('shops', {
      'name': 'Test Shop 2',
      'address': 'Address 2',
      'latitude': 0.0,
      'longitude': 0.0,
      'isVisited': 1
    });
  });

  testWidgets('RouteListScreen renders list of shops correctly', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: RouteListScreen()));
    
    // Initially isLoading = true, so we need to settle the future
    await tester.pumpAndSettle();

    // Verify shops are displayed
    expect(find.text('Test Shop 1'), findsOneWidget);
    expect(find.text('Test Shop 2'), findsOneWidget);

    // Verify one has a 'Visit' button, and the other is marked 'Visited'
    expect(find.text('Visit'), findsOneWidget);
    expect(find.text('Visited'), findsOneWidget);
  });

  testWidgets('Clicking "Visit" marks a shop as visited', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: RouteListScreen()));
    await tester.pumpAndSettle();

    // Verify we have one Visit button initially
    expect(find.text('Visit'), findsOneWidget);

    // Tap it
    await tester.tap(find.text('Visit'));
    await tester.pumpAndSettle();

    // Now Visit button should disappear, replaced by a second 'Visited' text text
    expect(find.text('Visit'), findsNothing);
    expect(find.text('Visited'), findsNWidgets(2));
  });
}
