import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:dio/dio.dart';
import '../services/api_service.dart'; 
import '../constants/config.dart';

class DetailRiwayatPage extends StatefulWidget {
  final Map<String, dynamic> data;

  const DetailRiwayatPage({super.key, required this.data});

  @override
  State<DetailRiwayatPage> createState() => _DetailRiwayatPageState();
}

class _DetailRiwayatPageState extends State<DetailRiwayatPage> {
  final TextEditingController _commentController = TextEditingController();
  final ApiService _apiService = ApiService();
  
  late List<dynamic> _comments;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Inisialisasi daftar komentar dari data yang dikirim lewat constructor
    _comments = widget.data['comments'] ?? [];
  }

  // Fungsi untuk mengirim komentar
  Future<void> _sendComment() async {
    if (_commentController.text.trim().isEmpty) return;

    setState(() => _isLoading = true);

    try {
      // Ambil report_id dari data laporan
      int reportId = widget.data['id'];
      // Ambil user_id pelapor (dari data laporan)
      int userId = widget.data['user_id']; 

      // Panggil ApiService (Pastikan sudah buat fungsi postComment di ApiService)
      final response = await _apiService.postComment(
        reportId: reportId,
        userId: userId,
        pesan: _commentController.text.trim(),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        setState(() {
          // Tambahkan komentar baru yang dikembalikan dari server ke daftar
          _comments.add(response.data['data']);
          _commentController.clear(); // Bersihkan input
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Komentar terkirim!")),
        );
      } else {
        throw Exception("Gagal mengirim komentar");
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const String baseUrl = "http://192.168.100.2:8000/storage/";
    Color statusColor = widget.data['status'] == "Selesai" ? Colors.green : Colors.orange;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Detail Laporan"),
        backgroundColor: const Color(0xFFFFD700),
        foregroundColor: Colors.black,
      ),
      body: Column(
        children: [
          // Area Konten Utama (Scrollable)
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- Foto Utama ---
                  ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Image.network(
                      "$baseUrl${widget.data['foto_kerusakan']}",
                      height: 230, width: double.infinity, fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(height: 230, color: Colors.grey[300], child: const Icon(Icons.broken_image)),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // --- Status & Judul ---
                  _buildStatusBadge(statusColor),
                  const SizedBox(height: 15),
                  Text(widget.data['judul'] ?? "Tanpa Judul", style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  const Divider(height: 40),

                  // --- Info Detail ---
                  _buildInfoRow(Icons.location_on, "Lokasi", widget.data['lokasi'] ?? "-"),
                  _buildInfoRow(Icons.category, "Kategori", widget.data['kategori'] ?? "-"),
                  _buildInfoRow(Icons.description, "Deskripsi", widget.data['deskripsi'] ?? "-"),
                  
                  const Divider(height: 40),

                  // --- Daftar Komentar/Progress ---
                  const Text("Tanggapan & Progress", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 15),
                  _buildCommentList(baseUrl),
                ],
              ),
            ),
          ),

          // --- Input Box Komentar (Tetap di bawah) ---
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 5)],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    decoration: InputDecoration(
                      hintText: "Tulis komentar...",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(25)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                _isLoading 
                  ? const CircularProgressIndicator()
                  : CircleAvatar(
                      backgroundColor: const Color(0xFFFFD700),
                      child: IconButton(
                        icon: const Icon(Icons.send, color: Colors.black),
                        onPressed: _sendComment,
                      ),
                    ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Widget Badge Status
  Widget _buildStatusBadge(Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color),
      ),
      child: Text(widget.data['status'].toString().toUpperCase(), style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12)),
    );
  }

  // Widget Baris Info
  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFFFFD700), size: 20),
          const SizedBox(width: 15),
          Expanded(child: Text("$label: $value", style: const TextStyle(fontSize: 14))),
        ],
      ),
    );
  }

  // Widget List Komentar
  Widget _buildCommentList(String baseUrl) {
    if (_comments.isEmpty) {
      return const Text("Belum ada tanggapan.", style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey));
    }
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _comments.length,
      itemBuilder: (context, index) {
        final c = _comments[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(c['user']?['name'] ?? "User", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue, fontSize: 13)),
              const SizedBox(height: 5),
              Text(c['pesan'] ?? ""),
              if (c['foto_progress'] != null) 
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network("$baseUrl${c['foto_progress']}", height: 150, width: double.infinity, fit: BoxFit.cover),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}