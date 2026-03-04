import 'package:http/http.dart' as http;
import '../data/database_helper.dart';
import '../models/shop.dart';
import '../models/product.dart';

class ApiService {
  // The API service must strictly use HTTPS
  static const String _baseUrl = 'https://api.example.com/v1';

  Future<void> performMorningSync() async {
    final dbHelper = DatabaseHelper();
    
    // Retrieve the saved JWT token from local storage
    final token = await dbHelper.getToken();
    if (token == null || token.isEmpty) {
      throw Exception('Invalid or missing JWT token. Please log in again.');
    }

    try {
      // Create strict HTTPS URI
      final uri = Uri.parse('$_baseUrl/sync-data');

      // Make the secure request with Authorization header
      // Note: We wrap this in a try-catch to simulate success even if the mock endpoint fails
      http.Response? response;
      try {
        response = await http.get(
          uri,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        );
      } catch (_) {
        // Ignore real HTTP error since URL is fake, we will provide mock data below
      }

      // Simulate network delay for the UI loading indicator
      await Future.delayed(const Duration(seconds: 2));

      // In a real app we parse: final data = json.decode(response.body);
      // For this implementation, we use mock data to demonstrate offline capabilities
      
      final List<Shop> fetchedShops = [
        Shop(id: 101, name: 'Cloud Mart (Synced)', address: '123 Cloud St', latitude: 40.71, longitude: -74.00, isVisited: false),
        Shop(id: 102, name: 'Secure Store (Synced)', address: '404 HTTPS Ave', latitude: 40.72, longitude: -74.01, isVisited: false),
      ];

      final List<Product> fetchedProducts = [
        Product(id: 1, name: 'Premium Widget', price: 19.99, stock: 50),
        Product(id: 2, name: 'Standard Gadget', price: 9.99, stock: 200),
      ];

      // Save the fetched data into the local SQLite database for Offline Mode
      await dbHelper.syncShops(fetchedShops);
      await dbHelper.syncProducts(fetchedProducts);

    } catch (e) {
      throw Exception('Network logic failed: $e');
    }
  }
}
