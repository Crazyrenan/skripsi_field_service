// File: lib/providers/auth_provider.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/user_model.dart'; // Pastikan path ini benar mengarah ke model di atas

class AuthProvider with ChangeNotifier {
  User? _user;
  bool _isLoading = false;
  final _storage = const FlutterSecureStorage();

  User? get user => _user;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _user != null;

  Future<bool> login(String email, String password) async {
    _setLoading(true);
    
    // Ganti 10.0.2.2 jika pakai HP Fisik
    const String baseUrl = 'http://10.0.2.2:8000'; 

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {'username': email, 'password': password},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        String token = data['access_token'];

        // Simpan token ke storage HP
        await _storage.write(key: 'jwt_token', value: token);
        
        // Simpan data user ke State
        _user = User.fromJson(data, token);
        
        _setLoading(false);
        return true; 
      } else {
        _setLoading(false);
        return false;
      }
    } catch (e) {
      print("Error Login: $e");
      _setLoading(false);
      return false;
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  Future<void> logout() async {
    await _storage.deleteAll();
    _user = null;
    notifyListeners();
  }
}