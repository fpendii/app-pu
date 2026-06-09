import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Pastikan sudah install package ini
import '../services/api_service.dart';

// Halaman-halaman tujuan navigasi
import 'form_lapor_page.dart';
import 'riwayat_page.dart';
import 'profile_page.dart';
import 'panduan_page.dart';

// Model Data Statistik
class ReportStats {
  final int total;
  final int proses;
  final int selesai;

  ReportStats({
    required this.total,
    required this.proses,
    required this.selesai,
  });

  factory ReportStats.fromJson(Map<String, dynamic> json) {
    // Menyesuaikan dengan struktur response { "status": "success", "total": 0, ... }
    return ReportStats(
      total: json['total'] ?? 0,
      proses: json['proses'] ?? 0,
      selesai: json['selesai'] ?? 0,
    );
  }
}

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const MainDashboardContent(),
    const RiwayatPage(),
    const PanduanPage(),
    const ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      appBar: AppBar(
        title: const Text(
          'SOC - SDA on call',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Colors.black,
          ),
        ),
        backgroundColor: const Color(0xFFFFD700),
        elevation: 0,
        centerTitle: true,
      ),
      body: IndexedStack(index: _selectedIndex, children: _pages),
      bottomNavigationBar: BottomAppBar(
        padding: const EdgeInsets.symmetric(vertical: 8),
        color: Colors.white,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildTabItem(icon: Icons.dashboard_rounded, label: "Beranda", index: 0),
            _buildTabItem(icon: Icons.history_rounded, label: "Riwayat", index: 1),
            _buildLaporButton(),
            _buildTabItem(icon: Icons.menu_book_rounded, label: "Panduan", index: 2),
            _buildTabItem(icon: Icons.person_rounded, label: "Profil", index: 3),
          ],
        ),
      ),
    );
  }

  Widget _buildLaporButton() {
    return InkWell(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const FormLaporPage()),
      ).then((_) => setState(() {})), // Refresh saat kembali dari form lapor
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(
              color: Colors.black,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.campaign_rounded,
              color: Color(0xFFFFD700),
              size: 24,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            "Lapor",
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildTabItem({required IconData icon, required String label, required int index}) {
    bool isSelected = _selectedIndex == index;
    return InkWell(
      onTap: () => setState(() => _selectedIndex = index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isSelected ? Colors.orange[800] : Colors.grey[400],
            size: 26,
          ),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.orange[800] : Colors.grey[400],
              fontSize: 10,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}

class MainDashboardContent extends StatefulWidget {
  const MainDashboardContent({super.key});

  @override
  State<MainDashboardContent> createState() => _MainDashboardContentState();
}

class _MainDashboardContentState extends State<MainDashboardContent> {
  final ApiService _apiService = ApiService();
  late Future<ReportStats> _statsFuture;

  @override
  void initState() {
    super.initState();
    _statsFuture = _fetchStats();
  }

  Future<ReportStats> _fetchStats() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      // Pastikan key 'user_id' sama dengan yang Anda gunakan di Auth/Login
      final int? userId = prefs.getInt('user_id');

      if (userId == null) {
        throw Exception("Sesi berakhir, silakan login kembali");
      }

      final response = await _apiService.getDashboardStats(userId);

      if (response.statusCode == 200) {
        return ReportStats.fromJson(response.data);
      } else {
        throw Exception("Gagal memuat statistik");
      }
    } catch (e) {
      debugPrint("FETCH STATS ERROR: $e");
      throw Exception("Koneksi bermasalah");
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        setState(() {
          _statsFuture = _fetchStats();
        });
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(25, 20, 25, 50),
              decoration: const BoxDecoration(
                color: Color(0xFFFFD700),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(40),
                  bottomRight: Radius.circular(40),
                ),
              ),
              child: Column(
                children: [
                  const Text("Selamat Datang,", style: TextStyle(fontSize: 14, color: Colors.black54)),
                  const Text("Masyarakat Peduli", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 30),
                  FutureBuilder<ReportStats>(
                    future: _statsFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator(color: Colors.black));
                      }
                      
                      if (snapshot.hasError) {
                        return Text("Error: ${snapshot.error}", style: const TextStyle(color: Colors.red, fontSize: 12));
                      }

                      final data = snapshot.data ?? ReportStats(total: 0, proses: 0, selesai: 0);
                      
                      return Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: const [
                            BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 5)),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _StatBox(label: "Aduan", value: "${data.total}", color: Colors.blue),
                            _verticalDivider(),
                            _StatBox(label: "Proses", value: "${data.proses}", color: Colors.orange),
                            _verticalDivider(),
                            _StatBox(label: "Selesai", value: "${data.selesai}", color: Colors.green),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 60),
            Icon(Icons.touch_app_outlined, size: 60, color: Colors.grey[200]),
            const SizedBox(height: 15),
            const Text(
              "Ketuk tombol hitam di bawah\nuntuk mulai melapor",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
            const SizedBox(height: 120),
          ],
        ),
      ),
    );
  }

  Widget _verticalDivider() => Container(height: 30, width: 1, color: Colors.grey[200]);
}

class _StatBox extends StatelessWidget {
  final String label, value;
  final Color color;
  const _StatBox({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.black54)),
      ],
    );
  }
}