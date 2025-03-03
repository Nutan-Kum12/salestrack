import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import '../models/shop.dart';

class ShopRepository {
  final CollectionReference _shopCollection =
      FirebaseFirestore.instance.collection('myShop');

  Stream<List<Shop>> getShops({int limit =20}) {
  return _shopCollection.limit(limit).snapshots().map((snapshot) {
    return snapshot.docs.map((doc) {
      return Shop.fromMap(doc.id, doc.data() as Map<String, dynamic>);
    }).toList();
  });
}

  Stream<List<Shop>> getShopsByCity(String city, Position userPosition) {
    return _shopCollection
        .where('city', isEqualTo: city)
        .snapshots()
        .map((snapshot) {
      List<Shop> shops = snapshot.docs.map((doc) {
        return Shop.fromMap(doc.id, doc.data() as Map<String, dynamic>);
      }).toList();

      shops.sort((a, b) {
        double distanceA = Geolocator.distanceBetween(
          userPosition.latitude,
          userPosition.longitude,
          a.latitude,
          a.longitude,
        );
        double distanceB = Geolocator.distanceBetween(
          userPosition.latitude,
          userPosition.longitude,
          b.latitude,
          b.longitude,
        );
        return distanceA.compareTo(distanceB);
      });

      return shops;
    });
  }

  Future<Shop> getShopById(String id) async {
    DocumentSnapshot doc = await _shopCollection.doc(id).get();
    return Shop.fromMap(doc.id, doc.data() as Map<String, dynamic>);
  }

  Future<void> updateDeliveryStatus(String shopId, bool delivered) async {
    await _shopCollection.doc(shopId).update({
      'delivered': delivered,
    });
  }
}
