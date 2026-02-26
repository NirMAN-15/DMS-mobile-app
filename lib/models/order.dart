class OrderModel {
  final int? id;
  final int shopId;
  final double totalAmount;
  final String date;
  final int isSynced;

  OrderModel({
    this.id,
    required this.shopId,
    required this.totalAmount,
    required this.date,
    this.isSynced = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'shopId': shopId,
      'totalAmount': totalAmount,
      'date': date,
      'isSynced': isSynced,
    };
  }

  factory OrderModel.fromMap(Map<String, dynamic> map) {
    return OrderModel(
      id: map['id'],
      shopId: map['shopId'],
      totalAmount: map['totalAmount'],
      date: map['date'],
      isSynced: map['isSynced'],
    );
  }
}
