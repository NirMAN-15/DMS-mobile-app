import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product.dart';
import '../models/shop.dart';

class ApiService {
  final http.Client _client;

  ApiService({http.Client? client}) : _client = client ?? http.Client();

  // Placeholder for API calls like syncing local data to server
  Future<bool> syncData() async {
    // Implement API synchronization logic here
    await Future.delayed(const Duration(seconds: 2));
    return true;
  }

  // Replace with your actual backend URL
  static const String baseUrl = 'https://api.example.com'; 

  Future<List<Product>> fetchProducts() async {
    try {
      final response = await _client.get(Uri.parse('$baseUrl/products'));
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((item) => Product.fromMap(item as Map<String, dynamic>)).toList();
      } else {
        throw Exception('Failed to load products. Status Code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching products: $e');
    }
  }

  Future<List<Shop>> fetchShops() async {
    try {
      final response = await _client.get(Uri.parse('$baseUrl/shops'));
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((item) => Shop.fromMap(item as Map<String, dynamic>)).toList();
      } else {
        throw Exception('Failed to load shops. Status Code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching shops: $e');
    }
  }
}
