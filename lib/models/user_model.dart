//import 'package:cloud_firestore/cloud_firestore.dart';

enum UserType {
  client,
  farmer,
}

class UserModel {
  final String uid;
  final String email;
  final String firstName;
  final String lastName;
  final String username;
  final String phone;
  final UserType userType;

  UserModel({
    required this.uid,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.username,
    required this.phone,
    required this.userType,
  });
}
