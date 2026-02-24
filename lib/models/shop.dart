class Shop {
  final int? id;
  final String name;
  final String address;
  final double latitude;
  final double longitude;
  final bool isVisited;

  Shop({
    this.id,
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    this.isVisited = false,
  });

  // Convert a Shop into a Map. The keys must correspond to the names of the
  // columns in the database.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'isVisited': isVisited ? 1 : 0,
    };
  }

  // Extract a Shop object from a Map.
  factory Shop.fromMap(Map<String, dynamic> map) {
    return Shop(
      id: map['id'],
      name: map['name'],
      address: map['address'],
      latitude: map['latitude'],
      longitude: map['longitude'],
      isVisited: map['isVisited'] == 1,
    );
  }
}
