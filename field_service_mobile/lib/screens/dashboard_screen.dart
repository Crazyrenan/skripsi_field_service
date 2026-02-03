import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'login_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  // Fungsi Logout
  Future<void> _logout(BuildContext context) async {
    const storage = FlutterSecureStorage();
    await storage.deleteAll(); // Hapus Token
    
    if (context.mounted) {
      Navigator.pushReplacement(
        context, 
        MaterialPageRoute(builder: (context) => const LoginScreen())
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Field Service Dashboard'),
        backgroundColor: const Color(0xFF1E3C72),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.verified_user_outlined, size: 80, color: Colors.green),
            const SizedBox(height: 20),
            const Text(
              'Halo, Teknisi Budi!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text('Status: Online & Terautentikasi'),
            const SizedBox(height: 40),
            ElevatedButton.icon(
              onPressed: () {
                // Nanti kita arahkan ke halaman Laporan (Fase 2 & 3)
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Fitur Laporan akan segera hadir!'))
                );
              },
              icon: const Icon(Icons.add_task),
              label: const Text('Buat Laporan Baru'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}