// File: lib/models/user_model.dart
class User {
  final int id;
  final String email;
  final String fullName;
  final int roleId;
  final String? token;

  User({
    required this.id,
    required this.email,
    required this.fullName,
    required this.roleId,
    this.token,
  });

  factory User.fromJson(Map<String, dynamic> json, String token) {
    return User(
      // Sesuaikan key ini dengan JSON response backend Anda
      id: json['user']['id'],
      email: json['user']['email'],
      fullName: json['user']['full_name'],
      roleId: json['user']['role_id'],
      token: token,
    );
  }
}