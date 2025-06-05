import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  
  Future<String?> signUp({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String username,
    required String phone,
    required UserType userType,
  }) async {
    try {
      // Create user with Firebase Auth
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Save additional user data to Firestore
      await _firestore.collection('users').doc(result.user!.uid).set({
        'email': email,
        'firstName': firstName,
        'lastName': lastName,
        'username': username,
        'phone': phone,
        'userType': userType == UserType.farmer ? 'farmer' : 'client',
        'createdAt': DateTime.now(),
      });

      return null; // Success - no error
    } catch (e) {
      return e.toString(); // Return error message
    }
  }

  // Simple login method
  Future<UserModel?> getCurrentUser() async {
    User? user = _auth.currentUser;
    if (user != null) {
      DocumentSnapshot doc = await _firestore.collection('users').doc(user.uid).get();
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      
      return UserModel(
        uid: user.uid,
        email: data['email'],
        firstName: data['firstName'],
        lastName: data['lastName'],
        username: data['username'],
        phone: data['phone'],
        userType: data['userType'] == 'farmer' ? UserType.farmer : UserType.client,
      );
    }
    return null;
  }
}
