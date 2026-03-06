import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite/sqflite.dart';
import 'package:dms_mobile/widgets/sync_button.dart';
import 'package:dms_mobile/data/database_helper.dart';

void main() {
  setUpAll(() {
    // Required since ApiService depends on DatabaseHelper
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    final dbHelper = DatabaseHelper();
    final db = await dbHelper.database;
    await db.delete('auth_session');
    
    // Simulate a logged-in state so Morning Sync doesn't immediately fail on missing JWT
    await dbHelper.login('testuser', 'password');
  });

  testWidgets('SyncButton shows loading indicator when pressed', (WidgetTester tester) async {
    bool syncCompleted = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SyncButton(
            onSyncComplete: () {
              syncCompleted = true;
            },
          ),
        ),
      ),
    );

    // Verify initial state (Icon button)
    final syncIcon = find.byIcon(Icons.sync);
    expect(syncIcon, findsOneWidget);

    // Tap the sync button
    await tester.tap(syncIcon);
    await tester.pump(); // Trigger setState

    // Verify state changed to loading
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    // Wait for the simulated API delay (2 seconds) to finish
    await tester.pumpAndSettle(const Duration(seconds: 3));

    // Verify loading indicator is gone, back to normal button
    expect(find.byIcon(Icons.sync), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);

    // Verify callback was triggered
    expect(syncCompleted, isTrue);
  });
}
