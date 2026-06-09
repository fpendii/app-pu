import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class PusatBantuanPage extends StatelessWidget {
  const PusatBantuanPage({super.key});

  // 🔹 Fungsi buka WhatsApp
  Future<void> _openWhatsApp() async {
    final url = Uri.parse("https://wa.me/6282177724040?text=Halo%20Admin,%20saya%20butuh%20bantuan");
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw Exception("Tidak bisa membuka WhatsApp");
    }
  }

  // 🔹 Fungsi kirim Email
  Future<void> _sendEmail() async {
    final url = Uri.parse("mailto: sdadpuprp@gmail.com?subject=Bantuan Aplikasi&body=Halo Admin, saya mengalami kendala...");
    if (!await launchUrl(url)) {
      throw Exception("Tidak bisa membuka Email");
    }
  }

  // // 🔹 Fungsi Telepon
  // Future<void> _makeCall() async {
  //   final url = Uri.parse("tel:081234567890");
  //   if (!await launchUrl(url)) {
  //     throw Exception("Tidak bisa melakukan panggilan");
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Pusat Bantuan"),
        backgroundColor: const Color(0xFFFFD700),
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Butuh Bantuan Lebih Lanjut?",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              "Tim kami siap membantu Anda jika mengalami kendala dalam penggunaan aplikasi E-Lapor PU.",
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 30),

            // 🔥 WHATSAPP
            _buildContactCard(
              icon: Icons.chat_bubble_outline,
              title: "Chat via WhatsApp",
              subtitle: "Konsultasi cepat via pesan teks",
              color: Colors.green,
              onTap: _openWhatsApp,
            ),

            // 🔥 EMAIL
            _buildContactCard(
              icon: Icons.email_outlined,
              title: "Kirim Email",
              subtitle: "sdadpuprp@gmail.com",
              color: Colors.blue,
              onTap: _sendEmail,
            ),

            // 🔥 TELEPON
            // _buildContactCard(
            //   icon: Icons.phone_in_talk_outlined,
            //   title: "Call Center",
            //   subtitle: "Layanan telepon darurat 24 jam",
            //   color: Colors.red,
            //   onTap: _makeCall,
            // ),

            const SizedBox(height: 40),
            const Center(
              child: Text(
                "Jam Operasional Kantor:\nSenin - Jumat | 08.00 - 16.00 WIB",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 15),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.1),
          child: Icon(icon, color: color),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 13)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 14),
        onTap: onTap,
      ),
    );
  }
}