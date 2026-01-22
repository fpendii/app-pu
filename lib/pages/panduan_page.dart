import 'package:flutter/material.dart';

class PanduanPage extends StatelessWidget {
  const PanduanPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Panduan Penggunaan")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildExpansionPanduan(
            "Cara Melaporkan Kerusakan",
            "1. Buka menu Buat Laporan\n2. Foto kerusakan secara jelas\n3. Masukkan judul dan lokasi\n4. Klik Kirim Aduan",
          ),
          _buildExpansionPanduan(
            "Berapa lama proses perbaikan?",
            "Setelah laporan diverifikasi, tim Dinas PU akan meninjau lokasi dalam waktu maksimal 3x24 jam.",
          ),
          _buildExpansionPanduan(
            "Kriteria laporan yang diproses",
            "Laporan harus menyertakan foto asli, lokasi yang jelas, dan merupakan wewenang Dinas Pekerjaan Umum.",
          ),
        ],
      ),
    );
  }

  Widget _buildExpansionPanduan(String title, String content) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ExpansionTile(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        leading: const Icon(Icons.help_outline, color: Color(0xFFFFD700)),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(content, style: const TextStyle(height: 1.5)),
          )
        ],
      ),
    );
  }
}