import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'dart:convert';
class DetailRiwayatPage extends StatefulWidget {
  final Map<String, dynamic> data;

  const DetailRiwayatPage({super.key, required this.data});

  @override
  State<DetailRiwayatPage> createState() => _DetailRiwayatPageState();
}

class _DetailRiwayatPageState extends State<DetailRiwayatPage> {
  final TextEditingController _commentController = TextEditingController();
  final ApiService _apiService = ApiService();

  List<dynamic> _comments = [];
  List<dynamic> _reportImages = [];
  bool _isLoading = false;

  // List Status yang sama dengan versi Web Admin
  final List<Map<String, String>> _statusSteps = [
    {'key': 'Proposal', 'label': 'Proposal'},
    {'key': 'Verifikasi', 'label': 'Cek Lokasi'},
    {'key': 'Penetapan', 'label': 'Penetapan'},
    {'key': 'Pelaksanaan', 'label': 'Pelaksanaan'},
    {'key': 'Pemeriksaan', 'label': 'Pemeriksaan'},
    {'key': 'Selesai', 'label': 'Selesai'},
  ];

  @override
  void initState() {
    super.initState();
    _comments = widget.data['comments'] ?? [];
    _reportImages = widget.data['images'] ?? [];

    
  }

  Future<void> _sendComment() async {
    if (_commentController.text.trim().isEmpty) return;
    setState(() => _isLoading = true);

    try {
      int reportId = widget.data['id'];
      int userId = widget.data['user_id'];

      final response = await _apiService.postComment(
        reportId: reportId,
        userId: userId,
        pesan: _commentController.text.trim(),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        setState(() {
          _comments.add(response.data['data']);
          _commentController.clear();
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Komentar terkirim!")));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Detail Laporan",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFFFFD700),
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- STEPPER PROGRESS (BARU) ---
                  _buildProgressStepper(),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Slider Foto
                        _buildImageSlider(),
                        const SizedBox(height: 20),

                        // Box Analisis AI
                        if (widget.data['ai_analysis'] != null)
                          _buildAISection(),
                        const SizedBox(height: 15),

                        Text(
                          widget.data['judul'] ?? "Tanpa Judul",
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),

                        _buildStatusBadge(),

                        const Divider(height: 40),

                        _buildInfoRow(
                          Icons.location_on,
                          "Lokasi Kejadian",
                          widget.data['lokasi'] ?? "-",
                        ),
                        _buildInfoRow(
                          Icons.category,
                          "Kategori Kerusakan",
                          widget.data['kategori'] ?? "-",
                        ),
                        _buildInfoRow(
                          Icons.description,
                          "Deskripsi Lengkap",
                          widget.data['deskripsi'] ?? "-",
                        ),

                        const Divider(height: 40),

                        const Text(
                          "Tanggapan & Riwayat Progress",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 15),
                        _buildCommentList(),
                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          _buildCommentInput(),
        ],
      ),
    );
  }

  // --- WIDGET STEPPER PROGRESS ---
  Widget _buildProgressStepper() {
    String currentStatus = widget.data['status'] ?? '';

    // Mencari index status saat ini
    int currentIndex = _statusSteps.indexWhere(
      (element) => element['key'] == currentStatus,
    );
    // Jika status tidak ditemukan (misal: 'Ditolak'), kita set ke -1 atau handle khusus
    if (currentIndex == -1 && currentStatus.contains('Ditolak'))
      currentIndex = 0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            "ALUR PENGERJAAN",
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 15),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_statusSteps.length, (index) {
                bool isCompleted = index < currentIndex;
                bool isActive = index == currentIndex;
                bool isLast = index == _statusSteps.length - 1;

                Color color = isCompleted
                    ? Colors.green
                    : (isActive ? Colors.blue : Colors.grey.shade300);

                return Row(
                  children: [
                    // Circle & Label
                    Column(
                      children: [
                        Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                            boxShadow: isActive
                                ? [
                                    BoxShadow(
                                      color: Colors.blue.withOpacity(0.4),
                                      blurRadius: 8,
                                    ),
                                  ]
                                : [],
                          ),
                          child: Center(
                            child: isCompleted
                                ? const Icon(
                                    Icons.check,
                                    color: Colors.white,
                                    size: 16,
                                  )
                                : Text(
                                    "${index + 1}",
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _statusSteps[index]['label']!,
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: isActive
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: isActive
                                ? Colors.blue
                                : (isCompleted ? Colors.green : Colors.grey),
                          ),
                        ),
                      ],
                    ),
                    // Line Connector
                    if (!isLast)
                      Container(
                        width: 35,
                        height: 2,
                        margin: const EdgeInsets.only(bottom: 15),
                        color: isCompleted
                            ? Colors.green
                            : Colors.grey.shade300,
                      ),
                  ],
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  // --- WIDGET HELPER LAINNYA ---

  Widget _buildStatusBadge() {
    String status = widget.data['status'] ?? "Proses";
    Color color = (status == "Selesai")
        ? Colors.green
        : (status.contains("Ditolak") ? Colors.red : Colors.orange);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildImageSlider() {
    if (_reportImages.isEmpty) {
      return Container(
        height: 200,
        margin: const EdgeInsets.only(top: 20),
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(15),
        ),
        child: const Icon(
          Icons.image_not_supported,
          size: 50,
          color: Colors.grey,
        ),
      );
    }
    return Column(
      children: [
        const SizedBox(height: 20),
        SizedBox(
          height: 230,
          child: PageView.builder(
            itemCount: _reportImages.length,
            itemBuilder: (context, index) {
              String imageUrl = _reportImages[index]['full_url'] ?? "";
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    errorBuilder: (_, __, ___) => Container(
                      color: Colors.grey[300],
                      child: const Icon(Icons.broken_image),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "Geser untuk melihat ${_reportImages.length} foto",
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }

  Widget _buildAISection() {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.blue.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.auto_awesome, color: Colors.blue, size: 20),
              const SizedBox(width: 8),
              const Text(
                "Analisis AI Gemini",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
              const Spacer(),
              _buildSeverityChip(widget.data['ai_severity']),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            widget.data['ai_analysis'] ?? "",
            style: const TextStyle(fontSize: 14, height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildSeverityChip(String? severity) {
    Color color = (severity?.toLowerCase() == 'berat')
        ? Colors.red
        : (severity?.toLowerCase() == 'sedang' ? Colors.orange : Colors.green);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        severity?.toUpperCase() ?? "OK",
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFFFFD700), size: 22),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 15,
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

  Widget _buildCommentList() {
    
    if (_comments.isEmpty) {
      return const Center(
        child: Text(
          "Belum ada tanggapan resmi.",
          style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey),
        ),
      );
    }
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _comments.length,
      itemBuilder: (context, index) {
        final c = _comments[index];
        bool isAdmin =
            c['user']?['role'] == 'admin'; // Opsional jika ada pembedaan role

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isAdmin ? Colors.blue.shade50 : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isAdmin ? Colors.blue.shade100 : Colors.grey.shade200,
            ),
          ),
         child: Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          c['user']?['name'] ?? "User",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isAdmin ? Colors.blue : Colors.black87,
          ),
        ),
        if (isAdmin)
          const Icon(Icons.verified, color: Colors.blue, size: 16),
      ],
    ),
    const SizedBox(height: 5),

    Text(c['pesan'] ?? "", style: const TextStyle(fontSize: 14)),

    // 🔥 GAMBAR
    if (c['foto_progress'] != null &&
        c['foto_progress'].toString().isNotEmpty)
      Padding(
        padding: const EdgeInsets.only(top: 10),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Image.network(
            "${ApiService.imageBaseUrl}${c['foto_progress']}",
            height: 150,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
        ),
      ),
  ],
),
        );
      },
    );
  }

  Widget _buildCommentInput() {
    return Container(
      padding: const EdgeInsets.fromLTRB(15, 10, 15, 30),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _commentController,
              decoration: InputDecoration(
                hintText: "Tulis pesan/pertanyaan...",
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          _isLoading
              ? const SizedBox(
                  width: 30,
                  height: 30,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : CircleAvatar(
                  backgroundColor: const Color(0xFFFFD700),
                  radius: 24,
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.black, size: 20),
                    onPressed: _sendComment,
                  ),
                ),
        ],
      ),
    );
  }
}
