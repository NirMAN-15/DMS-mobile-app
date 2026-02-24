import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import '../data/database_helper.dart';
import '../models/shop.dart';
import 'login_screen.dart';

class RouteListScreen extends StatefulWidget {
  const RouteListScreen({super.key});

  @override
  State<RouteListScreen> createState() => _RouteListScreenState();
}

class _RouteListScreenState extends State<RouteListScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<Shop> _shops = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadShops();
  }

  Future<void> _loadShops() async {
    setState(() => _isLoading = true);
    final shops = await _dbHelper.getShops();
    setState(() {
      _shops = shops;
      _isLoading = false;
    });
  }

  Future<void> _handleLogout() async {
    await _dbHelper.logout();
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  void _markVisited(Shop shop) async {
    if (shop.id != null) {
      await _dbHelper.markShopVisited(shop.id!);
      _loadShops();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Today\'s Route'),
        actions: [
          IconButton(
            icon: const Icon(Icons.sync),
            tooltip: 'Sync Data (Mock)',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Simulated Sync: Data is up to date.')),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: _handleLogout,
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            color: AppColors.accent.withOpacity(0.2),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.cloud_off, size: 16, color: AppColors.textPrimary),
                const SizedBox(width: 8),
                Text(
                  'Offline Mode Active - Data saved locally',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _shops.isEmpty
                  ? const Center(child: Text('No shops found for today.'))
                  : RefreshIndicator(
                      onRefresh: _loadShops,
                      child: ListView.builder(
                        itemCount: _shops.length,
                        itemBuilder: (context, index) {
                          final shop = _shops[index];
                          return Card(
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: shop.isVisited ? Colors.green : AppColors.primary,
                                child: Icon(
                                  shop.isVisited ? Icons.check : Icons.store,
                                  color: Colors.white,
                                ),
                              ),
                              title: Text(
                                shop.name,
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text(shop.address),
                              trailing: shop.isVisited
                                  ? const Text('Visited', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold))
                                  : ElevatedButton(
                                      onPressed: () => _markVisited(shop),
                                      style: ElevatedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                                      ),
                                      child: const Text('Visit'),
                                    ),
                            ),
                          );
                        },
                      ),
                    ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Mock Navigation to New Shop')),
          );
        },
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add_location_alt),
      ),
    );
  }
}
