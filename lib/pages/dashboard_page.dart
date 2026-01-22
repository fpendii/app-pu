import 'package:flutter/material.dart';
import 'form_lapor_page.dart';
import 'riwayat_page.dart';
import 'profile_page.dart';
import 'peta_page.dart';
import 'panduan_page.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('E-LAPOR DINAS PU'),
        actions: [
            IconButton(
            icon: const Icon(Icons.account_circle),
            onPressed: () {
                Navigator.push(
                    context,
                    PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) => const ProfilePage(),
                        transitionsBuilder: (context, animation, secondaryAnimation, child) {
                        return FadeTransition(opacity: animation, child: child);
                        },
                        transitionDuration: const Duration(milliseconds: 500),
                    ),
                );
            },
            ),
        ],
    ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header Banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
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
                  const Text("Masyarakat Peduli Infrastruktur", 
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),
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
            
            // Menu Utama
            Padding(
              padding: const EdgeInsets.all(20),
              child: GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 15,
                mainAxisSpacing: 15,
                children: [
                 _MenuCard(
                    icon: Icons.add_task, 
                    label: "Buat Laporan", 
                    color: Colors.orange, 
                    onTap: () {
                        // FUNGSI PINDAH HALAMAN
                        Navigator.push(
                        context, 
                        MaterialPageRoute(builder: (context) => const FormLaporPage())
                        );
                    },
                    ),
                  _MenuCard(
                icon: Icons.history, 
                label: "Riwayat", 
                color: Colors.blue, 
                onTap: () {
                    Navigator.push(
                    context, 
                    MaterialPageRoute(builder: (context) => const RiwayatPage())
                    );
                },
                ),
                //  _MenuCard(
                //     icon: Icons.map, 
                //     label: "Peta Kerusakan", 
                //     color: Colors.green, 
                //     onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const PetaPage())),
                //     ),
                    _MenuCard(
                    icon: Icons.info, 
                    label: "Panduan", 
                    color: Colors.purple, 
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const PanduanPage())),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Widget Komponen Kecil agar kode tidak panjang
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

class _MenuCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _MenuCard({required this.icon, required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 10, spreadRadius: 2)],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              backgroundColor: color.withOpacity(0.1),
              child: Icon(icon, color: color),
            ),
            const SizedBox(height: 10),
            Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}