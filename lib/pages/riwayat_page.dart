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
      length: 4,
      child: Scaffold(
        backgroundColor: const Color(
          0xFFF8F9FA,
        ), // Warna background aplikasi yang lebih soft
        appBar: AppBar(
          title: const Text(
            "Riwayat Aduan",
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
          ),
          backgroundColor: const Color(0xFFFFD700),
          elevation: 0,
          centerTitle: true,
          actions: [
            IconButton(
              onPressed: _fetchData,
              icon: const Icon(Icons.refresh_rounded, color: Colors.black),
            ),
          ],
          // --- PENYUSUNAN TAB BAR YANG LEBIH RAPI ---
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(50),
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(color: Color(0xFFFFD700)),
              child: TabBar(
                isScrollable: true,
                physics: const BouncingScrollPhysics(),
                labelColor: Colors.black,
                unselectedLabelColor: Colors.black.withOpacity(0.5),
                labelStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
                unselectedLabelStyle: const TextStyle(
                  fontWeight: FontWeight.normal,
                  fontSize: 14,
                ),
                indicatorSize: TabBarIndicatorSize.label,
                // Indikator garis hitam yang lebih tebal dan membulat
                indicator: const UnderlineTabIndicator(
                  borderSide: BorderSide(width: 4, color: Colors.black),
                  insets: EdgeInsets.symmetric(horizontal: 16),
                ),
                tabs: const [
                  Tab(text: "Semua"),
                  Tab(text: "Proposal"),
                  Tab(text: "Proses"),
                  Tab(text: "Selesai"),
                ],
              ),
            ),
          ),
        ),
        body: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: Color(0xFFFFD700)),
              )
            : TabBarView(
                children: [
                  _buildListRiwayat(),
                  _buildListRiwayat(filterGroup: "Proposal"),
                  _buildListRiwayat(filterGroup: "Proses"),
                  _buildListRiwayat(filterGroup: "Selesai"),
                ],
              ),
      ),
    );
  }

  Widget _buildListRiwayat({String? filterGroup}) {
    final filteredData = _allReports.where((item) {
      String status = item['status'] ?? "";
      if (filterGroup == "Proposal") return status == "Proposal";
      if (filterGroup == "Proses") {
        return [
          "Verifikasi",
          "Penetapan",
          "Pelaksanaan",
          "Pemeriksaan",
        ].contains(status);
      }
      if (filterGroup == "Selesai") return status == "Selesai";
      return true;
    }).toList();

    if (filteredData.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_rounded, size: 80, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              "Belum ada data laporan",
              style: TextStyle(color: Colors.grey[500], fontSize: 16),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _fetchData,
      child: ListView.builder(
        padding: const EdgeInsets.only(
          top: 15,
          left: 15,
          right: 15,
          bottom: 100,
        ),
        itemCount: filteredData.length,
        itemBuilder: (context, index) {
          final item = filteredData[index];
          String status = item['status'] ?? "Proposal";

          // Mapping warna status agar lebih konsisten
          final Map<String, Color> statusColors = {
            'Proposal': Colors.blueGrey,
            'Verifikasi': Colors.orange,
            'Penetapan': Colors.amber,
            'Pelaksanaan': Colors.blue,
            'Pemeriksaan': Colors.indigo,
            'Selesai': Colors.green,
          };

          Color currentStatusColor = statusColors[status] ?? Colors.grey;

          return Container(
            margin: const EdgeInsets.only(bottom: 15),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DetailRiwayatPage(data: item),
                    ),
                  );
                },
                child: IntrinsicHeight(
                  child: Row(
                    children: [
                      // Indikator warna di samping kiri
                      Container(width: 6, color: currentStatusColor),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    status.toUpperCase(),
                                    style: TextStyle(
                                      color: currentStatusColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 11,
                                      letterSpacing: 1.1,
                                    ),
                                  ),
                                  Text(
                                    item['created_at'] != null
                                        ? item['created_at'].toString().split(
                                            'T',
                                          )[0]
                                        : "",
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                item['judul'] ?? "Tanpa Judul",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Colors.black87,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.location_on_outlined,
                                    size: 14,
                                    color: Colors.grey,
                                  ),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      item['lokasi'] ?? "Lokasi...",
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: Colors.grey,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const Icon(
                        Icons.chevron_right_rounded,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 8),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
