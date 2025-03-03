import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';

double getRandomOffset() {
  return Random().nextDouble() * 0.009 - 0.0045;
}

String generatePhoneNumber() {
  int firstDigit = Random().nextInt(4) + 6;
  int remainingDigits = Random().nextInt(1000000000);
  String phoneNumber = "$firstDigit${remainingDigits.toString().padLeft(9, '0')}";
  return "+91$phoneNumber";
}

class SHOP {
  final String id;
  final String title;
  final String address;
  final String number;
  final double latitude;
  final double longitude;
  final String imageUrl;
  final bool delivered;
  final String city;

  SHOP({
    required this.id,
    required this.title,
    required this.address,
    required this.number,
    required this.latitude,
    required this.longitude,
    required this.imageUrl,
    required this.delivered,
    required this.city,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'address': address,
      'number': number,
      'latitude': latitude,
      'longitude': longitude,
      'imageUrl': imageUrl,
      'delivered': delivered,
      'city': city,
    };
  }
}

final List<SHOP> listOfShop = [
  for (int i = 1; i <= 10; i++)
    SHOP(
      id: "shop_rajnagar_$i",
      title: "Shop $i",
      address: "Raj Nagar",
      number: generatePhoneNumber(),
      latitude: 28.6712 + getRandomOffset(),
      longitude: 77.4321 + getRandomOffset(),
      imageUrl: "https://picsum.photos/400/30$i",
      delivered: false,
      city: "Kaushambi",
    ),

  for (int i = 1; i <= 10; i++)
    SHOP(
      id: "shop_indirapuram_$i",
      title: "Shop $i",
      address: "Indirapuram",
      number: generatePhoneNumber(),
      latitude: 28.6398 + getRandomOffset(),
      longitude: 77.3695 + getRandomOffset(),
      imageUrl: "https://picsum.photos/40$i/300",
      delivered: false,
      city: "Indirapuram",
    ),

  for (int i = 1; i <= 10; i++)
    SHOP(
      id: "shop_vaishali_$i",
      title: "Shop $i",
      address: "Vaishali",
      number: generatePhoneNumber(),
      latitude: 28.6545 + getRandomOffset(),
      longitude: 77.3567 + getRandomOffset(),
      imageUrl: "https://picsum.photos/401/30$i",
      delivered: false,
      city: "Vaishali",
    ),

  for (int i = 1; i <= 10; i++)
    SHOP(
      id: "shop_vasundhara_$i",
      title: "Shop $i",
      address: "Vasundhara",
      number: generatePhoneNumber(),
      latitude: 28.6660 + getRandomOffset(),
      longitude: 77.3699 + getRandomOffset(),
      imageUrl: "https://picsum.photos/40$i/302",
      delivered: false,
      city: "Gangapuram",
    ),

  for (int i = 1; i <= 10; i++)
    SHOP(
      id: "shop_crossings_$i",
      title: "Shop $i",
      address: "Crossings Republik",
      number: generatePhoneNumber(),
      latitude: 28.6176 + getRandomOffset(),
      longitude: 77.3985 + getRandomOffset(),
      imageUrl: "https://picsum.photos/400/300",
      delivered: false,
      city: "Govindpuram",
    ),

  for (int i = 1; i <= 10; i++)
    SHOP(
      id: "shop_sanjay_$i",
      title: "Shop $i",
      address: "Sanjay Nagar",
      number: generatePhoneNumber(),
      latitude: 28.6913 + getRandomOffset(),
      longitude: 77.4537 + getRandomOffset(),
      imageUrl: "https://picsum.photos/400/301",
      delivered: false,
      city: "Vijay Nagar",
    ),

  for (int i = 1; i <= 10; i++)
    SHOP(
      id: "shop_lohia_$i",
      title: "Shop $i",
      address: "Lohia Nagar",
      number: generatePhoneNumber(),
      latitude: 28.6810 + getRandomOffset(),
      longitude: 77.4412 + getRandomOffset(),
      imageUrl: "https://picsum.photos/400/302",
      delivered: false,
      city: "Raj Nagar",
    ),
];



