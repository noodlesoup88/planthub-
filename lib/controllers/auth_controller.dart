import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';
import '../screens/homepage.dart';
import '../screens/dashboard.dart';

class AuthController {
  final AuthService _authService = AuthService();

  // Sign up controller
  Future<void> handleSignup({
    required BuildContext context,
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String username,
    required String phone,
    required UserType userType,
  }) async {
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    // Try to sign up
    String? error = await _authService.signUp(
      email: email,
      password: password,
      firstName: firstName,
      lastName: lastName,
      username: username,
      phone: phone,
      userType: userType,
    );

    // Close loading dialog
    Navigator.pop(context);

    if (error == null) {
      _navigateBasedOnUserType(context, userType);
    } else {
      _showErrorMessage(context, error);
    }
  }

  // login controller
  Future<void> handleLogin({
    required BuildContext context,
    required String username,
    required String password,
  }) async {
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    String? error = await _authService.signInWithUsername(
      username: username,
      password: password,
    );

    if (error == null) {
      UserModel? user = await _authService.getCurrentUser();
      
      // Close loading dialog
      Navigator.pop(context);

      if (user != null) {
        _navigateBasedOnUserType(context, user.userType);
      } else {
        _showErrorMessage(context, 'Failed to get user data');
      }
    } else {
      // Close loading dialog
      Navigator.pop(context);
      _showErrorMessage(context, error);
    }
  }

  // reset password controller
  Future<void> handleResetPassword({
    required BuildContext context,
    required String usernameOrEmail,
  }) async {
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    String email = usernameOrEmail;
    if (!usernameOrEmail.contains('@')) {
      // It's a username, find the email
      String? foundEmail = await _authService.findEmailByUsername(usernameOrEmail);
      if (foundEmail == null) {
        // Close loading dialog
        Navigator.pop(context);
        _showErrorMessage(context, 'No user found with this username');
        return;
      }
      email = foundEmail;
    }
    
    String? error = await _authService.resetPassword(email: email);
    
    // Close loading dialog
    Navigator.pop(context);
    
    if (error == null) {
      _showSuccessMessage(context, 'Password reset email sent! Check your inbox.');
    } else {
      _showErrorMessage(context, error);
    }
  }

  // next screen depending on user type
  void _navigateBasedOnUserType(BuildContext context, UserType userType) {
    if (userType == UserType.client) {
      // Client goes to Homepage
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const Homepage()),
      );
    } else {
      // Farmer goes to Dashboard
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const Dashboard()),
      );
    }
  }

  void _showErrorMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showSuccessMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }
}
