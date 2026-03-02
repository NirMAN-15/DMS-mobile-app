import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../data/database_helper.dart';
import '../core/colors.dart';

class SyncScreen extends StatefulWidget {
  const SyncScreen({Key? key}) : super(key: key);

  @override
  State<SyncScreen> createState() => _SyncScreenState();
}

class _SyncScreenState extends State<SyncScreen> {
  bool _isLoading = false;
  String _statusMessage = 'Ready to sync';
  final ApiService _apiService = ApiService();

  Future<void> _performMorningSync() async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Fetching data from server...';
    });

    try {
      // 1. Fetch data from backend
      final products = await _apiService.fetchProducts();
      final shops = await _apiService.fetchShops();

      setState(() {
        _statusMessage = 'Saving data to local database...';
      });

      // 2. Save data to SQLite (using the bulk insert methods we created)
      final dbHelper = DatabaseHelper.instance;
      await dbHelper.insertProducts(products);
      await dbHelper.insertShops(shops);

      setState(() {
        _statusMessage = 'Sync completed successfully!\n\n'
            'Downloaded ${products.length} products and ${shops.length} shops.';
      });
      
      // Optional: Show a success snackbar
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Morning sync successful!'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _statusMessage = 'Error during sync:\n$e';
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Sync failed: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Data Synchronization'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(
                Icons.sync,
                size: 80,
                color: AppColors.primary,
              ),
              const SizedBox(height: 32),
              Text(
                _statusMessage,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 48),
              if (_isLoading)
                const Center(child: CircularProgressIndicator())
              else
                ElevatedButton.icon(
                  onPressed: _performMorningSync,
                  icon: const Icon(Icons.cloud_download),
                  label: const Text('Morning Sync'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
