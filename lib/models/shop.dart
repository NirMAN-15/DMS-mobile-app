class Shop {
  final int? id;
  final String name;
  final String address;
  final String phone;
  final int isSynced;

  Shop({
    this.id,
    required this.name,
    required this.address,
    required this.phone,
    this.isSynced = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'phone': phone,
      'isSynced': isSynced,
    };
  }

  factory Shop.fromMap(Map<String, dynamic> map) {
    return Shop(
      id: map['id'],
      name: map['name'],
      address: map['address'],
      phone: map['phone'],
      isSynced: map['isSynced'],
    );
  }
}
