import 'package:cloud_firestore/cloud_firestore.dart';

class SaleModel {
  final String id;
  final String plantId;
  final String plantName;
  final double price;
  final DateTime saleDate;
  final String farmerId;
  final String farmerName;
  final String buyerId;
  final String buyerName;

  SaleModel({
    required this.id,
    required this.plantId,
    required this.plantName,
    required this.price,
    required this.saleDate,
    required this.farmerId,
    required this.farmerName,
    required this.buyerId,
    required this.buyerName,
  });

  Map<String, dynamic> toFirestore() {
    return {
      'plantId': plantId,
      'plantName': plantName,
      'price': price,
      'saleDate': saleDate,
      'farmerId': farmerId,
      'farmerName': farmerName,
      'buyerId': buyerId,
      'buyerName': buyerName,
    };
  }

  factory SaleModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return SaleModel(
      id: doc.id,
      plantId: data['plantId'] ?? '',
      plantName: data['plantName'] ?? '',
      price: (data['price'] ?? 0).toDouble(),
      saleDate: (data['saleDate'] as Timestamp).toDate(),
      farmerId: data['farmerId'] ?? '',
      farmerName: data['farmerName'] ?? '',
      buyerId: data['buyerId'] ?? '',
      buyerName: data['buyerName'] ?? '',
    );
  }
}
