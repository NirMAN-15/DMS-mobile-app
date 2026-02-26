class Product {
  final int? id;
  final String name;
  final double price;
  final int stock;
  final int isSynced;

  Product({
    this.id,
    required this.name,
    required this.price,
    required this.stock,
    this.isSynced = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'stock': stock,
      'isSynced': isSynced,
    };
  }

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'],
      name: map['name'],
      price: map['price'],
      stock: map['stock'],
      isSynced: map['isSynced'],
    );
  }
}
