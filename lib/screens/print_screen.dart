import 'package:flutter/material.dart';
import '../data/database_helper.dart';
import '../models/order.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/custom_card.dart';

class PrintScreen extends StatefulWidget {
  const PrintScreen({Key? key}) : super(key: key);

  @override
  State<PrintScreen> createState() => _PrintScreenState();
}

class _PrintScreenState extends State<PrintScreen> {
  List<OrderModel> _orders = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    setState(() => _isLoading = true);
    final orders = await DatabaseHelper.instance.getOrders();
    setState(() {
      _orders = orders;
      _isLoading = false;
    });
  }

  Future<void> _addDummyOrder() async {
    final order = OrderModel(
      shopId: 1,
      totalAmount: 150.0 + (_orders.length * 10),
      date: DateTime.now().toIso8601String(),
    );
    await DatabaseHelper.instance.insertOrder(order);
    _loadOrders(); // refresh UI
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Print Orders (Offline)'),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _orders.isEmpty
              ? const Center(child: Text('No orders to print. Create an order!'))
              : ListView.builder(
                  itemCount: _orders.length,
                  itemBuilder: (context, index) {
                    final order = _orders[index];
                    return CustomCard(
                      child: ListTile(
                        leading: const Icon(Icons.receipt),
                        title: Text('Order ID: ${order.id} | Shop: ${order.shopId}'),
                        subtitle: Text('Amount: \$${order.totalAmount}\nDate: ${order.date.substring(0, 10)}'),
                        trailing: IconButton(
                          icon: const Icon(Icons.print, color: Colors.blue),
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Printing order ${order.id}...')),
                            );
                          },
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addDummyOrder,
        child: const Icon(Icons.add),
        tooltip: 'Add Dummy Order',
      ),
    );
  }
}
