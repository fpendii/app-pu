import 'package:flutter/material.dart';

class PanduanPage extends StatelessWidget {
  const PanduanPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Panduan Penggunaan"),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildExpansionPanduan(
            title: "Cara Membuat Laporan Aduan",
            icon: Icons.edit_document,
            content: [
              "Klik menu Lapor pada bagian bawah aplikasi.",
              "Tambahkan foto kerusakan maksimal 5 foto dengan menekan ikon kamera.",
              "Pilih Jenis Usulan sesuai laporan yang akan disampaikan.",
              "Pilih Kategori Utama sesuai jenis kerusakan atau permasalahan.",
              "Isi Judul Laporan secara singkat dan jelas.",
              "Contoh: Kerusakan Bendung A.",
              "Masukkan Nomor Pelapor (WhatsApp) yang aktif.",
              "Tentukan Lokasi / Alamat dengan memilih titik lokasi pada peta.",
              "Tambahkan Deskripsi Tambahan apabila diperlukan.",
              "Klik tombol Kirim Laporan Sekarang untuk mengirim aduan.",
            ],
          ),

          _buildExpansionPanduan(
            title: "Ketentuan Laporan",
            icon: Icons.rule,
            content: [
              "Foto yang dikirim harus jelas dan sesuai kondisi di lapangan.",
              "Lokasi laporan wajib sesuai titik kerusakan.",
              "Nomor WhatsApp harus aktif untuk proses konfirmasi.",
              "Laporan harus berkaitan dengan kewenangan Dinas Pekerjaan Umum / SDA.",
            ],
          ),

          _buildExpansionPanduan(
            title: "Proses Tindak Lanjut",
            icon: Icons.assignment_turned_in,
            content: [
              "Laporan akan masuk ke sistem admin SDA On Call.",
              "Tim akan melakukan verifikasi data dan lokasi laporan.",
              "Jika laporan valid, petugas akan melakukan peninjauan lapangan.",
              "Status laporan dapat dipantau melalui menu Riwayat.",
            ],
          ),

          _buildExpansionPanduan(
            title: "Estimasi Penanganan",
            icon: Icons.access_time,
            content: [
              "Setelah laporan diverifikasi, tim Dinas PU akan menindaklanjuti laporan sesuai tingkat prioritas dan kondisi lapangan."
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildExpansionPanduan({
    required String title,
    required IconData icon,
    required List<String> content,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ExpansionTile(
        leading: Icon(
          icon,
          color: const Color(0xFFFFD700),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: List.generate(
                content.length,
                (index) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${index + 1}. ",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          content[index],
                          style: const TextStyle(height: 1.5),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}