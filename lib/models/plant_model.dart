import 'package:cloud_firestore/cloud_firestore.dart';

class PlantModel {
  final String id;
  final String name;
  final String imageUrl;
  final String category;
  final double price;
  final String location;
  final String farmerId;
  final String farmerName;
  final DateTime createdAt;

  PlantModel({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.category,
    required this.price,
    required this.location,
    required this.farmerId,
    required this.farmerName,
    required this.createdAt,
  });

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'imageUrl': imageUrl,
      'category': category,
      'price': price,
      'location': location,
      'farmerId': farmerId,
      'farmerName': farmerName,
      'createdAt': createdAt,
    };
  }

  factory PlantModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return PlantModel(
      id: doc.id,
      name: data['name'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      category: data['category'] ?? '',
      price: (data['price'] ?? 0).toDouble(),
      location: data['location'] ?? '',
      farmerId: data['farmerId'] ?? '',
      farmerName: data['farmerName'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }
}
