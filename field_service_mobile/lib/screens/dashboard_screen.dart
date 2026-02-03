// lib/screens/dashboard_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'login_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  
  void _handleLogout() {
    context.read<AuthProvider>().logout();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (route) => false,
    );
  }

  void _navigateToSettings() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Fitur Upload Foto & Profil akan hadir di sini!")),
    );
    // Nanti: Navigator.push(context, MaterialPageRoute(builder: (_) => ProfileScreen()));
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final displayName = user?.fullName ?? "Teknisi";
    final displayRole = user?.roleId == 1 ? "Administrator" : "Field Technician";

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("Dashboard", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF1E3C72),
        foregroundColor: Colors.white,
        elevation: 0,
        // --- UBAH BAGIAN ACTIONS INI ---
        actions: [
          // Ganti tombol Logout biasa dengan Popup Menu
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'settings') {
                _navigateToSettings();
              } else if (value == 'logout') {
                _handleLogout();
              }
            },
            icon: const Icon(Icons.account_circle, size: 30), // Ikon Profil
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'header',
                enabled: false, // Tidak bisa diklik, cuma info
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Akun Saya", style: TextStyle(fontWeight: FontWeight.bold)),
                    Divider(),
                  ],
                ),
              ),
              const PopupMenuItem<String>(
                value: 'settings',
                child: Row(
                  children: [
                    Icon(Icons.settings, color: Colors.grey),
                    SizedBox(width: 8),
                    Text('Pengaturan & Foto'),
                  ],
                ),
              ),
              const PopupMenuItem<String>(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Keluar', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
        ],
        // -------------------------------
      ),
      body: Column(
        children: [
          _buildHeader(displayName, displayRole),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  _buildMenuCard(
                    icon: Icons.inventory_2_outlined,
                    label: "Stok Barang",
                    color: Colors.blue,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Menuju Halaman List Barang...")),
                      );
                    },
                  ),
                  _buildMenuCard(
                    icon: Icons.assignment_add,
                    label: "Laporan Baru",
                    color: Colors.orange,
                    onTap: () {},
                  ),
                  _buildMenuCard(
                    icon: Icons.location_on_outlined, // Icon Lokasi
                    label: "Status Lokasi", // Tombol Cek Lokasi
                    color: Colors.redAccent,
                    onTap: () {
                       // Nanti logic kirim lokasi
                    },
                  ),
                  _buildMenuCard(
                    icon: Icons.history_edu,
                    label: "Riwayat",
                    color: Colors.purple,
                    onTap: () {},
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ... (Widget _buildHeader dan _buildMenuCard Tetap Sama) ...
  Widget _buildHeader(String name, String role) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 10, 24, 30),
      decoration: const BoxDecoration(
        color: Color(0xFF1E3C72),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 30,
            backgroundColor: Colors.white24,
            child: Icon(Icons.person, size: 36, color: Colors.white),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Halo, $name", 
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              Text(
                role, 
                style: const TextStyle(color: Colors.white70),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildMenuCard({required IconData icon, required String label, required Color color, required VoidCallback onTap}) {
    return Material(
      color: Colors.grey[50],
      borderRadius: BorderRadius.circular(16),
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
              child: Icon(icon, size: 32, color: color),
            ),
            const SizedBox(height: 12),
            Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87)),
          ],
        ),
      ),
    );
  }
}