import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // sign up
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
      // prevent duplicate emails
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // check if username exists in firestore
      try {
        final usernameQuery = await _firestore
            .collection('users')
            .where('username', isEqualTo: username)
            .get();
        
        // If username exists, delete the auth account and return error
        if (usernameQuery.docs.isNotEmpty) {
          await result.user?.delete(); 
          return 'Username already exists. Please choose another one.';
        }
      } catch (usernameError) {
        print('Warning: Could not check username uniqueness: $usernameError');
        
      }

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

  // Login with username method 
  Future<String?> signInWithUsername({
    required String username,
    required String password,
  }) async {
    try {
      
      final querySnapshot = await _firestore
          .collection('users')
          .where('username', isEqualTo: username)
          .limit(1)
          .get();
      
      // Check if user exists
      if (querySnapshot.docs.isEmpty) {
        return 'No user found with this username';
      }
      
      // Get the email from the found user document
      final userDoc = querySnapshot.docs.first;
      final email = userDoc['email'] as String;
      
      // Use the email to sign in with Firebase Auth
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      return null; 
    } catch (e) {
      return e.toString(); 
    }
  }

  Future<String?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return null; 
    } catch (e) {
      return e.toString(); 
    }
  }

  Future<String?> resetPassword({
    required String email,
  }) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return null;
    } catch (e) {
      return e.toString(); 
    }
  }

  Future<String?> findEmailByUsername(String username) async {
    try {
      final querySnapshot = await _firestore
          .collection('users')
          .where('username', isEqualTo: username)
          .limit(1)
          .get();
      
      if (querySnapshot.docs.isEmpty) {
        return null;
      }
      
      return querySnapshot.docs.first['email'] as String;
    } catch (e) {
      return null;
    }
  }
  
  Future<UserModel?> getCurrentUser() async {
    User? user = _auth.currentUser;
    if (user != null) {
      DocumentSnapshot doc = await _firestore.collection('users').doc(user.uid).get();
      
      if (doc.exists) {
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
    }
    return null;
  }

  
  Future<void> signOut() async {
    await _auth.signOut();
  }
}
