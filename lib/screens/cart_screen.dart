import 'package:flutter/material.dart';
import '../data/database_helper.dart';
import '../models/product.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/custom_card.dart';
import 'print_screen.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({Key? key}) : super(key: key);

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  List<Product> _products = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    setState(() => _isLoading = true);
    final products = await DatabaseHelper.instance.getProducts();
    setState(() {
      _products = products;
      _isLoading = false;
    });
  }

  Future<void> _addDummyProduct() async {
    final newProduct = Product(
      name: 'Sample Product ${_products.length + 1}',
      price: 15.0 + (_products.length * 2),
      stock: 10,
    );
    await DatabaseHelper.instance.insertProduct(newProduct);
    _loadProducts(); // refresh UI
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Cart & Products (Offline)'),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _products.isEmpty
              ? const Center(child: Text('No products available offline. Add some!'))
              : ListView.builder(
                  itemCount: _products.length,
                  itemBuilder: (context, index) {
                    final product = _products[index];
                    return CustomCard(
                      child: ListTile(
                        title: Text(product.name),
                        subtitle: Text('Price: \$${product.price} | Stock: ${product.stock}'),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () async {
                            if (product.id != null) {
                              await DatabaseHelper.instance.deleteProduct(product.id!);
                              _loadProducts();
                            }
                          },
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 'add_product',
            onPressed: _addDummyProduct,
            child: const Icon(Icons.add),
            tooltip: 'Add Dummy Product',
          ),
          const SizedBox(height: 16),
          FloatingActionButton(
            heroTag: 'go_to_print',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PrintScreen()),
              );
            },
            child: const Icon(Icons.print),
            tooltip: 'Go To Print Screen',
          ),
        ],
      ),
    );
  }
}
