import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite/sqflite.dart';
import 'package:dms_mobile/screens/login_screen.dart';
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
    await db.delete('auth_session');
    await db.delete('shops'); // Ensure clean state
  });

  testWidgets('LoginScreen shows validation error for empty fields', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: LoginScreen()));

    final loginButton = find.text('LOGIN');
    expect(loginButton, findsOneWidget);

    await tester.tap(loginButton);
    await tester.pump();

    expect(find.text('Please enter both username and password.'), findsOneWidget);
  });

  testWidgets('LoginScreen processes valid login and navigates to RouteListScreen', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: LoginScreen()));

    // Enter username and password
    await tester.enterText(find.byType(TextField).at(0), 'test_user');
    await tester.enterText(find.byType(TextField).at(1), 'password123');

    // Tap login button
    await tester.tap(find.text('LOGIN'));
    
    await tester.pump(); // Trigger setState for loading

    // Verify loading indicator shows up
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    // Let the microtasks and animations finish (login completes)
    await tester.pumpAndSettle();

    // Verify navigation to RouteListScreen occurred
    expect(find.byType(RouteListScreen), findsOneWidget);
  });
}
