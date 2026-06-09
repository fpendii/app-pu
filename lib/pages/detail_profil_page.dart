import 'package:flutter/material.dart';
import 'edit_profil_page.dart';
import 'package:elapor_pu/services/api_service.dart';

class DetailProfilPage extends StatelessWidget {
  final Map<String, dynamic> userData;

  const DetailProfilPage({super.key, required this.userData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Detail Akun", style: TextStyle(color: Colors.black)),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditProfilPage(userData: userData),
                ),
              );
            },
          ),
        ],
        backgroundColor: const Color(0xFFFFD700),
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 0,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // STATUS VERIFIKASI CARD
            _buildStatusCard(userData['verifikasi'] ?? 'menunggu'),
            const SizedBox(height: 25),

            _buildSectionTitle("Informasi Identitas"),
            _buildDetailItem(
              "NIK",
              userData['nik'] ?? "-",
              Icons.badge_outlined,
            ),
            _buildDetailItem(
              "Nama Lengkap",
              userData['name'] ?? "-",
              Icons.person_outline,
            ),
            _buildDetailItem(
              "Jenis Kelamin",
              userData['jenis_kelamin'] ?? "-",
              Icons.wc_rounded,
            ),

            const Divider(height: 40),

            _buildSectionTitle("Kontak & Pekerjaan"),
            _buildDetailItem(
              "Email",
              userData['email'] ?? "-",
              Icons.email_outlined,
            ),
            _buildDetailItem(
              "Nomor WhatsApp",
              userData['nomor_wa'] ?? "-",
              Icons.phone_android,
            ),
            _buildDetailItem(
              "Pekerjaan",
              userData['pekerjaan'] ?? "-",
              Icons.work_outline,
            ),
            _buildDetailItem(
              "Alamat",
              userData['alamat'] ?? "-",
              Icons.location_on_outlined,
            ),

            const Divider(height: 40),

            _buildSectionTitle("Dokumen KTP"),
            const SizedBox(height: 10),
            _buildFotoKtp(userData['foto_ktp']),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.orange,
        ),
      ),
    );
  }

  Widget _buildDetailItem(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 22, color: Colors.grey[600]),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCard(String status) {
    Color color;
    IconData icon;
    String text;

    switch (status) {
      case 'acc':
        color = Colors.green;
        icon = Icons.check_circle_rounded;
        text = "Akun Terverifikasi";
        break;
      case 'tidak-acc':
        color = Colors.red;
        icon = Icons.cancel_rounded;
        text = "Verifikasi Ditolak";
        break;
      default:
        color = Colors.orange;
        icon = Icons.pending_rounded;
        text = "Menunggu Verifikasi";
    }

    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 12),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFotoKtp(String? url) {
    return Container(
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: url != null && url.isNotEmpty
          ? ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Image.network(
                // 1. UBAH DI SINI: Gabungkan Base URL langsung dengan path dari backend
                "${ApiService.imageBaseUrl}$url", 
                // Atau jika tidak pakai ApiService, tulis hardcode seperti ini:
                // "https://api.anda.com/$url",
                
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    const Center(child: Text("Gagal memuat gambar KTP")),
              ),
            )
          : const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.image_not_supported_outlined,
                    size: 40,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 10),
                  Text(
                    "Foto KTP tidak tersedia",
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
    );
  }
}
