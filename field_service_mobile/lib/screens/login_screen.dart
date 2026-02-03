import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'dashboard_screen.dart'; // Pastikan file ini sudah dibuat sesuai panduan sebelumnya

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Controller untuk menangkap input teks
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  
  // Service untuk komunikasi ke API
  final ApiService _apiService = ApiService();
  
  // State untuk Loading dan Password Visibility
  bool _isLoading = false;
  bool _isPasswordVisible = false;

  // Konfigurasi Warna
  final Color _primaryColor = const Color(0xFF1E3C72); 
  final Color _accentColor = const Color(0xFF2A5298);

  // --- FUNGSI LOGIN UTAMA (SUDAH DIPERBAIKI) ---
  void _handleLogin() async {
    // 1. Validasi Input Kosong
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      _showCustomSnackBar('Email dan Password wajib diisi', isError: true);
      return;
    }

    // 2. Tampilkan Loading
    setState(() => _isLoading = true);
    
    // 3. Panggil API Login (Tunggu sampai selesai)
    final result = await _apiService.login(
      _emailController.text,
      _passwordController.text,
    );

    // Cek apakah layar masih aktif sebelum update UI (Mencegah error async)
    if (!mounted) return;

    // 4. Matikan Loading
    setState(() => _isLoading = false);

    // 5. Cek Hasil Login
    if (result['success']) {
      // A. JIKA SUKSES
      _showCustomSnackBar(result['message'], isError: false);
      
      // Beri jeda 1 detik agar user membaca pesan sukses
      await Future.delayed(const Duration(seconds: 1)); 

      if (!mounted) return;
      
      // Pindah ke Dashboard & Hapus halaman Login dari stack (agar tidak bisa back)
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const DashboardScreen()),
      );
      
    } else {
      // B. JIKA GAGAL
      _showCustomSnackBar(result['message'], isError: true);
    }
  }

  // Helper untuk menampilkan SnackBar kustom
  void _showCustomSnackBar(String message, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(isError ? Icons.error_outline : Icons.check_circle_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message, style: const TextStyle(fontWeight: FontWeight.w600))),
          ],
        ),
        backgroundColor: isError ? const Color(0xFFD32F2F) : const Color(0xFF388E3C),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SingleChildScrollView(
        child: SizedBox(
          height: size.height,
          child: Stack(
            children: [
              // 1. Header Background dengan Curve
              ClipPath(
                clipper: HeaderClipper(),
                child: Container(
                  height: size.height * 0.45,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [_primaryColor, _accentColor],
                    ),
                  ),
                ),
              ),

              // 2. Konten Utama
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    children: [
                      SizedBox(height: size.height * 0.05),
                      
                      // Bagian Logo & Judul
                      _buildBrandHeader(),
                      
                      const Spacer(flex: 2),
                      
                      // Bagian Form Input
                      _buildLoginForm(),
                      
                      const Spacer(flex: 3),
                      
                      // Footer
                      Text(
                        'Version 1.0.0 • Field Service Pro',
                        style: TextStyle(color: Colors.grey[400], fontSize: 12),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBrandHeader() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.settings_suggest_rounded, size: 64, color: Colors.white),
        ),
        const SizedBox(height: 16),
        const Text(
          'Field Service Pro',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Sign in to manage your tasks',
          style: TextStyle(
            fontSize: 16,
            color: Colors.white.withOpacity(0.8),
          ),
        ),
      ],
    );
  }

  Widget _buildLoginForm() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Welcome Back',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: _primaryColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Please enter your details.',
            style: TextStyle(color: Colors.grey[600]),
          ),
          const SizedBox(height: 32),

          // Input Email
          _buildTextField(
            controller: _emailController,
            label: 'Email Address',
            icon: Icons.email_outlined,
            inputType: TextInputType.emailAddress,
          ),
          
          const SizedBox(height: 20),
          
          // Input Password
          _buildTextField(
            controller: _passwordController,
            label: 'Password',
            icon: Icons.lock_outline,
            isPassword: true,
          ),

          const SizedBox(height: 32),

          // Tombol Login
          SizedBox(
            height: 56,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _handleLogin,
              style: ElevatedButton.styleFrom(
                backgroundColor: _primaryColor,
                foregroundColor: Colors.white,
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 24, 
                      width: 24, 
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5)
                    )
                  : const Text(
                      'LOGIN',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isPassword = false,
    TextInputType inputType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword && !_isPasswordVisible,
      keyboardType: inputType,
      style: const TextStyle(fontWeight: FontWeight.w500),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.grey[600]),
        prefixIcon: Icon(icon, color: Colors.grey[400]),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                  color: Colors.grey[400],
                ),
                onPressed: () {
                  setState(() {
                    _isPasswordVisible = !_isPasswordVisible;
                  });
                },
              )
            : null,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: _primaryColor, width: 2),
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
        contentPadding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      ),
    );
  }
}

// Clipper untuk membuat lengkungan di header
class HeaderClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0, size.height - 50);
    
    var firstControlPoint = Offset(size.width / 4, size.height);
    var firstEndPoint = Offset(size.width / 2.25, size.height - 30);
    path.quadraticBezierTo(
        firstControlPoint.dx, firstControlPoint.dy, firstEndPoint.dx, firstEndPoint.dy);

    var secondControlPoint = Offset(size.width - (size.width / 3.25), size.height - 65);
    var secondEndPoint = Offset(size.width, size.height - 40);
    path.quadraticBezierTo(
        secondControlPoint.dx, secondControlPoint.dy, secondEndPoint.dx, secondEndPoint.dy);

    path.lineTo(size.width, size.height - 40);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}