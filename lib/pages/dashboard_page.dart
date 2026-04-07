import 'package:flutter/material.dart';
import '../services/api_service.dart'; // Pastikan path sesuai

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

  // Daftar halaman utama
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
          'E-LAPOR DINAS PU',
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
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomAppBar(
        padding: const EdgeInsets.symmetric(vertical: 8),
        color: Colors.white,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildTabItem(
              icon: Icons.dashboard_rounded,
              label: "Beranda",
              index: 0,
            ),
            _buildTabItem(
              icon: Icons.history_rounded,
              label: "Riwayat",
              index: 1,
            ),
            
            // TOMBOL LAPOR (Pusat Aksi)
            _buildLaporButton(),

            _buildTabItem(
              icon: Icons.menu_book_rounded,
              label: "Panduan",
              index: 2,
            ),
            _buildTabItem(
              icon: Icons.person_rounded,
              label: "Profil",
              index: 3,
            ),
          ],
        ),
      ),
    );
  }

  // Widget Tombol Lapor di Tengah Bottom Bar
  Widget _buildLaporButton() {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const FormLaporPage()),
        );
      },
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
              Icons.campaign_rounded, // Ikon pengaduan yang lebih tepat
              color: Color(0xFFFFD700),
              size: 24,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            "Lapor",
            style: TextStyle(
              color: Colors.black,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabItem({
    required IconData icon,
    required String label,
    required int index,
  }) {
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

// --- KONTEN DASHBOARD ---
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
      final response = await _apiService.getDashboardStats();
      if (response.statusCode == 200) {
        return ReportStats.fromJson(response.data);
      } else {
        throw Exception("Gagal memuat statistik");
      }
    } catch (e) {
      throw Exception("Terjadi kesalahan koneksi");
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
            // Banner Kuning
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 35),
              decoration: const BoxDecoration(
                color: Color(0xFFFFD700),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Selamat Datang,", style: TextStyle(fontSize: 16)),
                  const Text(
                    "Masyarakat Peduli Infrastruktur",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),

                  // Area Statistik
                  FutureBuilder<ReportStats>(
                    future: _statsFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(color: Colors.black),
                        );
                      } else if (snapshot.hasError) {
                        return Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.black12,
                            borderRadius: BorderRadius.circular(10)
                          ),
                          child: const Text("Gagal mengambil data statistik", style: TextStyle(fontSize: 12)),
                        );
                      }

                      final data = snapshot.data!;
                      return Container(
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _StatItem(label: "Aduan", value: "${data.total}"),
                            _StatItem(label: "Proses", value: "${data.proses}"),
                            _StatItem(label: "Selesai", value: "${data.selesai}"),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            // Bagian Informasi
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.campaign_rounded, color: Colors.orange),
                      SizedBox(width: 8),
                      Text(
                        "Informasi Terkini",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  _buildNewsCard(
                    "Perbaikan jalan lingkar kota sedang dalam tahap pengaspalan.",
                  ),
                  _buildNewsCard(
                    "Update: Laporan jembatan rusak di Desa Makmur telah diterima.",
                  ),
                  _buildNewsCard(
                    "Dinas PU menghimbau warga waspada lubang jalan saat hujan.",
                  ),
                  // Spasi bawah ekstra agar tidak tertutup bottom bar yang melayang
                  const SizedBox(height: 120), 
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNewsCard(String text) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: Colors.blue, size: 20),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 13))),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label, value;
  const _StatItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}