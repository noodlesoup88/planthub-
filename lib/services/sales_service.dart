import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:planthub/models/sale_model.dart';
import 'package:planthub/models/plant_model.dart';
import 'package:planthub/models/user_model.dart';

class SalesService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Record a new sale
  Future<bool> recordSale({
    required PlantModel plant,
    required UserModel buyer,
  }) async {
    try {
      // Create sale model
      final sale = SaleModel(
        id: '',
        plantId: plant.id,
        plantName: plant.name,
        price: plant.price,
        saleDate: DateTime.now(),
        farmerId: plant.farmerId,
        farmerName: plant.farmerName,
        buyerId: buyer.uid,
        buyerName: '${buyer.firstName} ${buyer.lastName}',
      );

      // Add to Firestore
      await _firestore.collection('sales').add(sale.toFirestore());
      return true;
    } catch (e) {
      print('Error recording sale: $e');
      return false;
    }
  }

  // Get sales for a specific farmer
  Stream<List<SaleModel>> getFarmerSales(String farmerId) {
    return _firestore
        .collection('sales')
        .where('farmerId', isEqualTo: farmerId)
        .orderBy('saleDate', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => SaleModel.fromFirestore(doc))
            .toList());
  }

  // Get sales for a specific buyer
  Stream<List<SaleModel>> getBuyerPurchases(String buyerId) {
    return _firestore
        .collection('sales')
        .where('buyerId', isEqualTo: buyerId)
        .orderBy('saleDate', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => SaleModel.fromFirestore(doc))
            .toList());
  }
}
