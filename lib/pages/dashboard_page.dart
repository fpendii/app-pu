import 'package:flutter/material.dart';
import 'form_lapor_page.dart';
import 'riwayat_page.dart';
import 'profile_page.dart';
import 'panduan_page.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _selectedIndex = 0;

  // List halaman utama (Hanya untuk tab navigasi)
  final List<Widget> _pages = [
    const MainDashboardContent(), // Index 0
    const RiwayatPage(),          // Index 1
    const PanduanPage(),          // Index 2
    const ProfilePage(),          // Index 3 (Bisa dipindah ke sini atau tetap di AppBar)
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true, // Membuat efek notch pada bar terlihat elegan
      appBar: AppBar(
        title: const Text(
          'E-LAPOR DINAS PU',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black),
        ),
        backgroundColor: const Color(0xFFFFD700),
        elevation: 0,
        centerTitle: true,
      ),

      // Body menampilkan halaman berdasarkan tab yang dipilih
      body: Container(
        padding: const EdgeInsets.only(bottom: 80), // Mencegah konten tertutup bar
        child: _pages[_selectedIndex],
      ),

      // --- TOMBOL TENGAH (FLOATING ACTION BUTTON) ---
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        shape: const CircleBorder(),
        backgroundColor: Colors.black,
        elevation: 4,
        onPressed: () {
          // PAKAI PUSH: Supaya saat Navigator.pop di FormLaporPage dipanggil,
          // aplikasi kembali ke sini (Dashboard), bukan layar hitam.
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const FormLaporPage()),
          );
        },
        child: const Icon(Icons.add_a_photo_rounded, color: Color(0xFFFFD700), size: 28),
      ),

      // --- BOTTOM NAVIGATION BAR DENGAN LEKUKAN ---
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 10,
        color: Colors.white,
        clipBehavior: Clip.antiAlias,
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildTabItem(icon: Icons.dashboard_rounded, label: "Beranda", index: 0),
              _buildTabItem(icon: Icons.history_rounded, label: "Riwayat", index: 1),
              
              const SizedBox(width: 40), // Ruang kosong untuk lekukan FAB
              
              _buildTabItem(icon: Icons.menu_book_rounded, label: "Panduan", index: 2),
              _buildTabItem(icon: Icons.person_rounded, label: "Profil", index: 3),
            ],
          ),
        ),
      ),
    );
  }

  // Helper untuk membuat item tab
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

// --- ISI KONTEN DASHBOARD (BANNER & STATISTIK) ---
class MainDashboardContent extends StatelessWidget {
  const MainDashboardContent({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
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
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                // Kartu Statistik
                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _StatItem(label: "Aduan", value: "128"),
                      _StatItem(label: "Proses", value: "45"),
                      _StatItem(label: "Selesai", value: "83"),
                    ],
                  ),
                )
              ],
            ),
          ),

          // Area Berita / Info
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.campaign_rounded, color: Colors.orange),
                    SizedBox(width: 8),
                    Text("Informasi Terkini", 
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 15),
                _buildNewsCard("Perbaikan saluran drainase di Kec. Makmur selesai tepat waktu."),
                _buildNewsCard("Waspada curah hujan tinggi, laporkan potensi banjir segera."),
                _buildNewsCard("Dinas PU melakukan survei jalan rusak di lingkar luar kota."),
                const SizedBox(height: 20), // Spasi tambahan
              ],
            ),
          ),
        ],
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
          BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 10, spreadRadius: 1),
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
        Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}