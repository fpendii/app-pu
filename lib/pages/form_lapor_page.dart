import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Tambahkan ini
import 'dart:io';
import '../widgets/loading_dialog.dart';
import '../services/api_service.dart'; // Import Service

class FormLaporPage extends StatefulWidget {
  const FormLaporPage({super.key});

  @override
  State<FormLaporPage> createState() => _FormLaporPageState();
}

class _FormLaporPageState extends State<FormLaporPage> {
  File? _image;
  final _picker = ImagePicker();
  
  // Controller
  final _judulController = TextEditingController();
  final _lokasiController = TextEditingController();
  final _deskripsiController = TextEditingController();
  final _kategoriLainnyaController = TextEditingController();

  String? _selectedKategori;
  final List<String> _kategoriList = [
    'Jalan Berlubang',
    'Jembatan Rusak',
    'Drainase Tersumbat',
    'Lampu Jalan Mati',
    'Lainnya'
  ];

  Future<void> _getImage() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 50,
    );

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  // FUNGSI KIRIM KE API
  void _handleKirimLaporan() async {
    // 1. Tentukan kategori akhir
    String finalKategori = _selectedKategori ?? "";
    if (finalKategori == 'Lainnya') {
      finalKategori = _kategoriLainnyaController.text;
    }

    // 2. Validasi Dasar
    if (_image == null || _judulController.text.isEmpty || finalKategori.isEmpty || _lokasiController.text.isEmpty) {
      _showSnackBar("Harap lengkapi Foto, Judul, Kategori, dan Lokasi!", Colors.orange);
      return;
    }

    LoadingDialog.show(context);

    try {
      // 3. Ambil user_id dari memori HP
      final prefs = await SharedPreferences.getInstance();
      int userId = prefs.getInt('user_id') ?? 0;

      // 4. Panggil ApiService
      final response = await ApiService().createReport(
        userId: userId,
        kategori: finalKategori,
        judul: _judulController.text,
        lokasi: _lokasiController.text,
        deskripsi: _deskripsiController.text,
        foto: _image!,
      );

      if (!mounted) return;
      LoadingDialog.hide(context);

      if (response.statusCode == 201) {
        _showSnackBar("Laporan berhasil terkirim!", Colors.green);
        Navigator.pop(context); // Kembali ke Dashboard
      } else {
        _showSnackBar("Gagal mengirim laporan: ${response.data['message']}", Colors.red);
      }
    } catch (e) {
      if (mounted) LoadingDialog.hide(context);
      _showSnackBar("Terjadi kesalahan koneksi", Colors.red);
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), backgroundColor: color));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Buat Laporan Aduan"),
        backgroundColor: const Color(0xFFFFD700),
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // AREA FOTO
            GestureDetector(
              onTap: _getImage,
              child: Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: const Color(0xFFFFD700), width: 2),
                  image: _image != null
                      ? DecorationImage(image: FileImage(_image!), fit: BoxFit.cover)
                      : null,
                ),
                child: _image == null
                    ? const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.camera_enhance, size: 50, color: Color(0xFFFFD700)),
                          Text("Klik untuk Foto Kerusakan", style: TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      )
                    : null,
              ),
            ),
            const SizedBox(height: 25),

            // DROPDOWN KATEGORI
            const Text("Kategori Kerusakan", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _selectedKategori,
              hint: const Text("Pilih Kategori"),
              decoration: const InputDecoration(border: OutlineInputBorder(), contentPadding: EdgeInsets.symmetric(horizontal: 12)),
              items: _kategoriList.map((String value) {
                return DropdownMenuItem<String>(value: value, child: Text(value));
              }).toList(),
              onChanged: (newValue) => setState(() => _selectedKategori = newValue),
            ),

            if (_selectedKategori == 'Lainnya') ...[
              const SizedBox(height: 15),
              TextField(
                controller: _kategoriLainnyaController,
                decoration: const InputDecoration(
                  hintText: "Sebutkan kategori lainnya...",
                  labelText: "Kategori Lainnya",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.edit_note),
                ),
              ),
            ],

            const SizedBox(height: 20),
            const Text("Judul Laporan", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: _judulController,
              decoration: const InputDecoration(hintText: "Contoh: Jembatan Retak", border: OutlineInputBorder()),
            ),
            const SizedBox(height: 20),

            const Text("Lokasi / Alamat Kejadian", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: _lokasiController,
              decoration: const InputDecoration(hintText: "Nama Jalan atau Patokan Lokasi", prefixIcon: Icon(Icons.map), border: OutlineInputBorder()),
            ),
            const SizedBox(height: 20),

            const Text("Deskripsi Tambahan", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: _deskripsiController,
              maxLines: 4,
              decoration: const InputDecoration(hintText: "Ceritakan detail kerusakan...", border: OutlineInputBorder()),
            ),
            const SizedBox(height: 30),

            ElevatedButton(
              onPressed: _handleKirimLaporan, // Gunakan fungsi API baru
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFD700),
                minimumSize: const Size(double.infinity, 55),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text("KIRIM LAPORAN ADUAN", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}