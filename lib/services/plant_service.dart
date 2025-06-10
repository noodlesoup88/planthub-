import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/plant_model.dart';

class PlantService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Upload image to Firebase Storage
  Future<String?> uploadPlantImage(File imageFile, String plantName) async {
    try {
      String fileName = '${DateTime.now().millisecondsSinceEpoch}_$plantName.jpg';
      Reference ref = _storage.ref().child('plant_images/$fileName');
      
      UploadTask uploadTask = ref.putFile(imageFile);
      TaskSnapshot snapshot = await uploadTask;
      
      String downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }

  // Add plant to Firestore
  Future<bool> addPlant(PlantModel plant) async {
    try {
      await _firestore.collection('plants').add(plant.toFirestore());
      return true;
    } catch (e) {
      print('Error adding plant: $e');
      return false;
    }
  }

  // Get all plants
  Stream<List<PlantModel>> getAllPlants() {
    return _firestore
        .collection('plants')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => PlantModel.fromFirestore(doc))
            .toList());
  }

  // Get plants by category
  Stream<List<PlantModel>> getPlantsByCategory(String category) {
    return _firestore
        .collection('plants')
        .where('category', isEqualTo: category)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => PlantModel.fromFirestore(doc))
            .toList());
  }

  // Get plants by farmer ID
  Stream<List<PlantModel>> getPlantsByFarmer(String farmerId) {
    return _firestore
        .collection('plants')
        .where('farmerId', isEqualTo: farmerId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => PlantModel.fromFirestore(doc))
            .toList());
  }

  // Delete plant
  Future<bool> deletePlant(String plantId) async {
    try {
      await _firestore.collection('plants').doc(plantId).delete();
      return true;
    } catch (e) {
      print('Error deleting plant: $e');
      return false;
    }
  }

  // Update plant
  Future<bool> updatePlant(PlantModel plant) async {
    try {
      await _firestore.collection('plants').doc(plant.id).update(plant.toFirestore());
      return true;
    } catch (e) {
      print('Error updating plant: $e');
      return false;
    }
  }
}
