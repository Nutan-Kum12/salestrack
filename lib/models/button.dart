// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:salestrack/models/shops.dart'; 

// class ModelSave extends StatelessWidget {
//   const ModelSave({super.key});

//   Future<void> saveShopToFirebase() async {
//     final CollectionReference ref = FirebaseFirestore.instance.collection("myShop");

//     try {
//       List<Future<void>> saveOperations = [];

//       for (final SHOP shop in listOfShop) {
//         final String shopId = ref.doc().id; // Generate a unique ID
//         saveOperations.add(ref.doc(shopId).set(shop.toMap()));
//       }

//       await Future.wait(saveOperations);
//       print("✅ All shops saved successfully!");
//     } catch (e) {
//       print("❌ Firestore Error: $e");
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("Home")),
//       body: Center(
//         child: ElevatedButton(
//           onPressed: saveShopToFirebase,
//           child: const Text("Save Shops to Firebase"),
//         ),
//       ),
//     );
//   }
// }
