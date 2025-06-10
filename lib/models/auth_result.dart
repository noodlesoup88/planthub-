import 'user_model.dart';

class AuthResult {
  final bool success;
  final UserModel? user;
  final String? token;
  final String? errorMessage;

  const AuthResult({
    required this.success,
    this.user,
    this.token,
    this.errorMessage,
  });

  factory AuthResult.success({
    required UserModel user,
    required String token,
  }) {
    return AuthResult(
      success: true,
      user: user,
      token: token,
    );
  }

  factory AuthResult.failure(String errorMessage) {
    return AuthResult(
      success: false,
      errorMessage: errorMessage,
    );
  }
}
