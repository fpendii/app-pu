import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import 'detail_riwayat_page.dart';

class RiwayatPage extends StatefulWidget {
  const RiwayatPage({super.key});

  @override
  State<RiwayatPage> createState() => _RiwayatPageState();
}

class _RiwayatPageState extends State<RiwayatPage> {
  List _allReports = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      int userId = prefs.getInt('user_id') ?? 0;

      final response = await ApiService().getReports(userId);
      if (response.statusCode == 200) {
        setState(() {
          _allReports = response.data['data'];
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Gagal mengambil data dari server")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Riwayat Aduan"),
          bottom: const TabBar(
            tabs: [
              Tab(text: "Semua"),
              Tab(text: "Proses"),
              Tab(text: "Selesai"),
            ],
            indicatorColor: Colors.black,
            labelColor: Colors.black,
          ),
          actions: [
            IconButton(onPressed: _fetchData, icon: const Icon(Icons.refresh))
          ],
        ),
        body: _isLoading 
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFFFD700)))
          : TabBarView(
              children: [
                _buildListRiwayat(),
                _buildListRiwayat(filterStatus: "Proses"),
                _buildListRiwayat(filterStatus: "Selesai"),
              ],
            ),
      ),
    );
  }

  Widget _buildListRiwayat({String? filterStatus}) {
    // Memfilter data dari API
    final filteredData = filterStatus == null 
        ? _allReports 
        : _allReports.where((item) => item['status'] == filterStatus).toList();

    if (filteredData.isEmpty) {
      return const Center(child: Text("Tidak ada laporan"));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(10),
      itemCount: filteredData.length,
      itemBuilder: (context, index) {
        final item = filteredData[index];
        return Card(
          elevation: 2,
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: ListTile(
            contentPadding: const EdgeInsets.all(15),
            leading: CircleAvatar(
              backgroundColor: item['status'] == "Selesai" ? Colors.green[100] : Colors.orange[100],
              child: Icon(
                item['status'] == "Selesai" ? Icons.check_circle : Icons.pending_actions,
                color: item['status'] == "Selesai" ? Colors.green : Colors.orange,
              ),
            ),
            title: Text(item['judul'] ?? "Tanpa Judul", style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 5),
                Text("Lokasi: ${item['lokasi']}"),
                Text("Kategori: ${item['kategori']}"),
              ],
            ),
            trailing: const Icon(Icons.arrow_forward_ios, size: 14),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DetailRiwayatPage(data: item),
                ),
              );
            },
          ),
        );
      },
    );
  }
}