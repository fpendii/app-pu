import 'package:flutter/material.dart';
import 'settings_pages.dart';
import 'pusat_bantuan_page.dart';
import 'login_page.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profil Pengguna"),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // HEADER PROFIL
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 30),
              decoration: const BoxDecoration(
                color: Color(0xFFFFD700),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.person, size: 60, color: Colors.black),
                  ),
                  const SizedBox(height: 15),
                  const Text(
                    "Budi Setiawan",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const Text(
                    "budi.setiawan@email.com",
                    style: TextStyle(fontSize: 14, color: Colors.black54),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // MENU PENGATURAN
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  _buildProfileMenu(
                    icon: Icons.notifications,
                    title: "Notifikasi",
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const NotifikasiPage())),
                    ),
                    _buildProfileMenu(
                    icon: Icons.lock,
                    title: "Ubah Password",
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ChangePasswordPage())),
                    ),
                    _buildProfileMenu(
                    icon: Icons.help_center,
                    title: "Pusat Bantuan",
                    onTap: () => Navigator.push(
                        context, 
                        MaterialPageRoute(builder: (context) => const PusatBantuanPage())
                    ),
                    ),
                    _buildProfileMenu(
                    icon: Icons.info,
                    title: "Tentang Aplikasi",
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AboutPage())),
                    ),
                    _buildProfileMenu(
                    icon: Icons.logout,
                    title: "Keluar",
                    color: Colors.red,
                    onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text("Keluar Akun?"),
                            content: const Text("Apakah Anda yakin ingin keluar dari aplikasi?"),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context), 
                                child: const Text("Batal")
                              ),
                              TextButton(
                                onPressed: () {
                                  // 1. Tutup dialog konfirmasi
                                  Navigator.pop(context);

                                  // 2. Navigasi ke halaman login & hapus semua history halaman sebelumnya
                                  Navigator.pushAndRemoveUntil(
                                    context,
                                    MaterialPageRoute(builder: (context) => const LoginPage()),
                                    (route) => false, // Ini yang membuat user tidak bisa 'Back' lagi
                                  );

                                  // 3. Beri notifikasi singkat
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text("Berhasil keluar dari akun")),
                                  );
                                }, 
                                child: const Text("Keluar", style: TextStyle(color: Colors.red))
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget untuk List Menu Profil
  Widget _buildProfileMenu({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color color = Colors.black87,
  }) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(
        title,
        style: TextStyle(color: color, fontWeight: FontWeight.w500),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }
} 