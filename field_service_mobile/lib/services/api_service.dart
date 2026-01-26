import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiService {
  final String baseUrl = 'http://10.0.2.2:8000'; 
  final storage = const FlutterSecureStorage();

  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: {
        'username': email,
        'password': password,
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      await storage.write(key: 'jwt_token', value: data['access_token']);
      return {'success': true, 'message': data['message']};
    } else {
      final errorData = json.decode(response.body);
      return {'success': false, 'message': errorData['detail'] ?? 'Login Gagal'};
    }
  }
}