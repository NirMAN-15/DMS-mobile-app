import 'package:flutter/material.dart';
import 'core/app_theme.dart';
import 'data/database_helper.dart';
import 'screens/login_screen.dart';
import 'screens/route_list_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize the database helper and check login status
  final dbHelper = DatabaseHelper();
  // Ensure DB is created before running the app
  await dbHelper.database;
  
  final bool loggedIn = await dbHelper.isLoggedIn();

  runApp(DMSApp(isLoggedIn: loggedIn));
}

class DMSApp extends StatelessWidget {
  final bool isLoggedIn;

  const DMSApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DMS Mobile',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: isLoggedIn ? const RouteListScreen() : const LoginScreen(),
    );
  }
}
