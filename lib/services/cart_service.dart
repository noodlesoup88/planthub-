import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/plant_model.dart';

class CartService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Add plant to cart
  Future<bool> addToCart({
    required String userId,
    required PlantModel plant,
  }) async {
    try {
      await _firestore.collection('cart').add({
        'userId': userId,
        'plantId': plant.id,
        'plantName': plant.name,
        'plantImage': plant.imageUrl,
        'price': plant.price,
        'farmerId': plant.farmerId,
        'farmerName': plant.farmerName,
        'addedAt': DateTime.now(),
      });
      return true;
    } catch (e) {
      print('Error adding to cart: $e');
      return false;
    }
  }

  // Get user's cart items
  Stream<List<Map<String, dynamic>>> getCartItems(String userId) {
    return _firestore
        .collection('cart')
        .where('userId', isEqualTo: userId)
        .orderBy('addedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => {
                  'id': doc.id,
                  ...doc.data(),
                })
            .toList());
  }

  // Remove item from cart
  Future<bool> removeFromCart(String cartItemId) async {
    try {
      await _firestore.collection('cart').doc(cartItemId).delete();
      return true;
    } catch (e) {
      print('Error removing from cart: $e');
      return false;
    }
  }

  // Clear entire cart
  Future<bool> clearCart(String userId) async {
    try {
      final cartItems = await _firestore
          .collection('cart')
          .where('userId', isEqualTo: userId)
          .get();
      
      for (var doc in cartItems.docs) {
        await doc.reference.delete();
      }
      return true;
    } catch (e) {
      print('Error clearing cart: $e');
      return false;
    }
  }
}
