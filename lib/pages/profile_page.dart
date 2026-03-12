import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import 'login_page.dart';
// Import halaman tujuan menu jika ada
// import 'notifikasi_page.dart';
// import 'change_password_page.dart';
import 'pusat_bantuan_page.dart';
import 'panduan_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final ApiService _apiService = ApiService();

  Future<Map<String, dynamic>> _fetchUserData() async {
    final prefs = await SharedPreferences.getInstance();
    int userId = prefs.getInt('user_id') ?? 1;

    final response = await _apiService.getUserProfile(userId);

    if (response.statusCode == 200) {
      return response.data['data'];
    } else {
      throw Exception("Gagal mengambil data profil");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Profil Pengguna",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
        backgroundColor: const Color(0xFFFFD700),
        elevation: 0,
        centerTitle: true,
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _fetchUserData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.black),
            );
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          final user = snapshot.data!;

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                // HEADER PROFIL
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 40),
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
                        child: Icon(
                          Icons.person,
                          size: 60,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 15),
                      Text(
                        user['name'] ?? "-",
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        user['email'] ?? "-",
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // BAGIAN INFO STATIS (WA & ALAMAT)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      _buildInfoTile(
                        Icons.phone_iphone_rounded,
                        "Nomor WhatsApp",
                        user['nomor_wa'] ?? "-",
                      ),
                      _buildInfoTile(
                        Icons.location_on_outlined,
                        "Alamat",
                        user['alamat'] ?? "-",
                      ),
                      _buildInfoTile(
                        Icons.work_outline_rounded,
                        "Pekerjaan",
                        user['pekerjaan'] ?? "Masyarakat",
                      ),

                      const Divider(height: 40, thickness: 1),

                      // MENU PENGATURAN (Sesuai permintaan, tidak dihilangkan)
                      // _buildMenuTile(
                      //   Icons.notifications_none_rounded,
                      //   "Notifikasi",
                      //   () {
                      //     Navigator.push(context, MaterialPageRoute(builder: (context) => const NotifikasiPage()));
                      //   },
                      // ),
                      // _buildMenuTile(
                      //   Icons.lock_outline_rounded,
                      //   "Ubah Password",
                      //   () {
                      //     // Navigator.push(context, MaterialPageRoute(builder: (context) => const ChangePasswordPage()));
                      //   },
                      // ),
                      _buildMenuTile(
                        Icons.help_outline_rounded,
                        "Pusat Bantuan",
                        () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const PusatBantuanPage(),
                            ),
                          );
                        },
                      ),
                      _buildMenuTile(Icons.info_outline_rounded, "Panduan", () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const PanduanPage(),
                          ),
                        );
                      }),

                      const SizedBox(height: 10),

                      _buildMenuTile(
                        Icons.logout_rounded,
                        "Keluar",
                        () => _confirmLogout(context),
                        color: Colors.red,
                      ),

                      // --- BOTTOM PADDING AGAR TIDAK KETUTUP BOTTOM BAR ---
                      const SizedBox(height: 120),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoTile(IconData icon, String label, String value) {
    return ListTile(
      leading: Icon(icon, color: Colors.orange[800]),
      title: Text(
        label,
        style: const TextStyle(fontSize: 11, color: Colors.grey),
      ),
      subtitle: Text(
        value,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
    );
  }

  Widget _buildMenuTile(
    IconData icon,
    String title,
    VoidCallback onTap, {
    Color color = Colors.black87,
  }) {
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: color),
      title: Text(
        title,
        style: TextStyle(color: color, fontWeight: FontWeight.w500),
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios,
        size: 14,
        color: Colors.grey,
      ),
    );
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Keluar Akun"),
        content: const Text("Apakah Anda yakin ingin keluar?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _logout(context);
            },
            child: const Text("Keluar", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
      (route) => false,
    );
  }
}
