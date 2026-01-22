import 'package:flutter/material.dart';

// --- HALAMAN NOTIFIKASI ---
class NotifikasiPage extends StatelessWidget {
  const NotifikasiPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Notifikasi")),
      body: ListView(
        children: const [
          ListTile(
            leading: Icon(Icons.info, color: Colors.blue),
            title: Text("Laporan Diterima"),
            subtitle: Text("Laporan 'Jalan Berlubang' Anda sedang diverifikasi."),
            trailing: Text("2j yang lalu", style: TextStyle(fontSize: 10)),
          ),
          Divider(),
        ],
      ),
    );
  }
}

// --- HALAMAN UBAH PASSWORD ---
class ChangePasswordPage extends StatelessWidget {
  const ChangePasswordPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Ubah Password")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const TextField(obscureText: true, decoration: InputDecoration(labelText: "Password Lama", border: OutlineInputBorder())),
            const SizedBox(height: 15),
            const TextField(obscureText: true, decoration: InputDecoration(labelText: "Password Baru", border: OutlineInputBorder())),
            const SizedBox(height: 15),
            const TextField(obscureText: true, decoration: InputDecoration(labelText: "Konfirmasi Password Baru", border: OutlineInputBorder())),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFFD700), minimumSize: const Size(double.infinity, 50)),
              child: const Text("SIMPAN PERUBAHAN", style: TextStyle(color: Colors.black)),
            )
          ],
        ),
      ),
    );
  }
}

// --- HALAMAN TENTANG APLIKASI ---
class AboutPage extends StatelessWidget {
  const AboutPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Tentang Aplikasi")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            const Text("E-LAPOR PU", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const Text("Versi 1.0.0", style: TextStyle(color: Colors.grey)),
            const Padding(
              padding: EdgeInsets.all(30),
              child: Text("Aplikasi ini digunakan untuk memudahkan masyarakat dalam melaporkan kerusakan infrastruktur di lingkungan sekitar secara real-time.", textAlign: TextAlign.center),
            ),
          ],
        ),
      ),
    );
  }
}