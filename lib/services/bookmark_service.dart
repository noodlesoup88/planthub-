import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/plant_model.dart';

class BookmarkService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Add plant to bookmarks
  Future<bool> addBookmark({
    required String userId,
    required PlantModel plant,
  }) async {
    try {
      await _firestore.collection('bookmarks').add({
        'userId': userId,
        'plantId': plant.id,
        'plantName': plant.name,
        'plantImage': plant.imageUrl,
        'price': plant.price,
        'farmerId': plant.farmerId,
        'farmerName': plant.farmerName,
        'bookmarkedAt': DateTime.now(),
      });
      return true;
    } catch (e) {
      print('Error adding bookmark: $e');
      return false;
    }
  }

  // Get user's bookmarks
  Stream<List<Map<String, dynamic>>> getBookmarks(String userId) {
    return _firestore
        .collection('bookmarks')
        .where('userId', isEqualTo: userId)
        .orderBy('bookmarkedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => {
                  'id': doc.id,
                  ...doc.data(),
                })
            .toList());
  }

  // Remove bookmark
  Future<bool> removeBookmark(String bookmarkId) async {
    try {
      await _firestore.collection('bookmarks').doc(bookmarkId).delete();
      return true;
    } catch (e) {
      print('Error removing bookmark: $e');
      return false;
    }
  }

  // Check if plant is bookmarked
  Future<bool> isBookmarked(String userId, String plantId) async {
    try {
      final query = await _firestore
          .collection('bookmarks')
          .where('userId', isEqualTo: userId)
          .where('plantId', isEqualTo: plantId)
          .limit(1)
          .get();
      return query.docs.isNotEmpty;
    } catch (e) {
      return false;
    }
  }
}
