import 'package:submee/models/user.dart';

class AuthResponse {
  AuthResponse({required this.token, required this.user});

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      token: json['token'],
      user: User.fromJson(json['user']),
    );
  }
  final String token;
  final User user;
}
