import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:dms_mobile_app/services/api_service.dart';

import 'api_service_test.mocks.dart';

@GenerateMocks([http.Client])
void main() {
  late ApiService apiService;
  late MockClient mockHttpClient;

  setUp(() {
    mockHttpClient = MockClient();
    apiService = ApiService(client: mockHttpClient);
  });

  group('ApiService Morning Sync', () {
    test('fetchProducts parses valid JSON response correctly', () async {
      // Arrange
      final List<Map<String, dynamic>> mockJsonResponse = [
        {
          'id': 1,
          'name': 'Apple',
          'price': 1.5,
          'stock': 100,
          'isSynced': 1
        },
        {
          'id': 2,
          'name': 'Banana',
          'price': 0.8,
          'stock': 150,
          'isSynced': 1
        }
      ];

      when(mockHttpClient.get(Uri.parse('${ApiService.baseUrl}/products')))
          .thenAnswer((_) async => http.Response(jsonEncode(mockJsonResponse), 200));

      // Act
      final products = await apiService.fetchProducts();

      // Assert
      expect(products, isA<List>());
      expect(products.length, 2);
      expect(products[0].name, 'Apple');
      expect(products[0].price, 1.5);
      expect(products[1].name, 'Banana');
      expect(products[1].stock, 150);
    });

    test('fetchProducts properly catches and throws network errors (404)', () async {
      // Arrange
      when(mockHttpClient.get(Uri.parse('${ApiService.baseUrl}/products')))
          .thenAnswer((_) async => http.Response('Not Found', 404));

      // Act & Assert
      expect(
        () async => await apiService.fetchProducts(),
        throwsA(isA<Exception>().having((e) => e.toString(), 'message', contains('Failed to load products'))),
      );
    });

    test('fetchProducts catches general exceptions during API call', () async {
      // Arrange
      when(mockHttpClient.get(Uri.parse('${ApiService.baseUrl}/products')))
          .thenThrow(Exception('No Internet Connection'));

      // Act & Assert
      expect(
        () async => await apiService.fetchProducts(),
        throwsA(isA<Exception>().having((e) => e.toString(), 'message', contains('Error fetching products'))),
      );
    });

    test('fetchShops parses valid JSON response correctly', () async {
      // Arrange
      final List<Map<String, dynamic>> mockJsonResponse = [
        {
          'id': 1,
          'name': 'Shop A',
          'address': 'Main St',
          'phone': '123456789',
          'isSynced': 1
        }
      ];

      when(mockHttpClient.get(Uri.parse('${ApiService.baseUrl}/shops')))
          .thenAnswer((_) async => http.Response(jsonEncode(mockJsonResponse), 200));

      // Act
      final shops = await apiService.fetchShops();

      // Assert
      expect(shops, isA<List>());
      expect(shops.length, 1);
      expect(shops[0].name, 'Shop A');
      expect(shops[0].address, 'Main St');
    });

    test('fetchShops properly catches and throws network errors (500)', () async {
      // Arrange
      when(mockHttpClient.get(Uri.parse('${ApiService.baseUrl}/shops')))
          .thenAnswer((_) async => http.Response('Server Error', 500));

      // Act & Assert
      expect(
        () async => await apiService.fetchShops(),
        throwsA(isA<Exception>().having((e) => e.toString(), 'message', contains('Failed to load shops'))),
      );
    });
  });
}
