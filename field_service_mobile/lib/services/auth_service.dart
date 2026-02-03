import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  // 10.0.2.2 adalah localhost untuk Android Emulator
  static const String baseUrl = 'http://10.0.2.2:8000'; 

  // Mengembalikan Map agar bisa kirim pesan error ke UI
  Future<Map<String, dynamic>> login(String email, String password) async {
    final url = Uri.parse('$baseUrl/login'); 

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email, // Pastikan backend pakai 'email' atau 'username'
          'password': password,
        }),
      );

      print('Status Code: ${response.statusCode}'); // Untuk Debugging
      print('Response: ${response.body}'); // Untuk Debugging

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        // Ambil token (sesuaikan key dengan backend, biasanya 'access_token' atau 'token')
        String token = data['access_token']; 

        // Simpan token ke memori
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', token);
        
        // Simpan data user jika perlu (opsional)
        // await prefs.setString('user_email', email);

        return {
          'success': true,
          'message': 'Login Berhasil!',
          'data': data
        };
      } else {
        // Jika password salah atau user tidak ditemukan
        return {
          'success': false,
          'message': data['message'] ?? 'Login gagal, periksa email/password.'
        };
      }
    } catch (e) {
      print('Error Auth: $e');
      return {
        'success': false,
        'message': 'Gagal terhubung ke server. Cek koneksi internet.'
      };
    }
  }

  // Fungsi tambahan: Cek apakah user sudah login
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey('token');
  }

  // Fungsi tambahan: Logout (Hapus token)
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Hapus semua data sesi
  }
  
  // Fungsi tambahan: Ambil token untuk request selanjutnya
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }
}