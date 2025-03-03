class Shop {
  final String id;
  final String title;
  final int number;
  final String address;
  final double latitude;
  final double longitude;
  final String imageUrl;
  final bool delivered;
  final String city;

  Shop({
    required this.id,
    required this.title,
    required this.number,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.imageUrl,
    required this.delivered,
    required this.city,
  });

  factory Shop.fromMap(String id, Map<String, dynamic> map) {
    try {
      return Shop(
        id: id,
        title: map['title'] ?? '',
        number: (map['number'] is int) 
            ? map['number'] 
            : int.tryParse(map['number'].toString()) ?? 0,
        
        address: map['address'] ?? '',
        latitude: (map['latitude'] is double) 
            ? map['latitude'] 
            : double.tryParse(map['latitude'].toString()) ?? 0.0,
        
        longitude: (map['longitude'] is double) 
            ? map['longitude'] 
            : double.tryParse(map['longitude'].toString()) ?? 0.0,
        
        imageUrl: map['imageUrl'] ?? '',
        delivered: map['delivered'] ?? false,
        city: map['city'] ?? '',
      );
    } catch (e) {
      print("Error parsing Shop from Firestore: $e");
      throw Exception("Error parsing Shop data");
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'number': number,
      'imageUrl': imageUrl,
      'delivered': delivered,
      'city': city,
    };
  }
}


