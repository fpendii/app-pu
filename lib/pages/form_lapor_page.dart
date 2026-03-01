import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import '../widgets/loading_dialog.dart';
import '../services/api_service.dart';

class FormLaporPage extends StatefulWidget {
  const FormLaporPage({super.key});

  @override
  State<FormLaporPage> createState() => _FormLaporPageState();
}

class _FormLaporPageState extends State<FormLaporPage> {
  // Variabel untuk menampung banyak foto
  final List<File> _images = [];
  final _picker = ImagePicker();

  // Controller
  final _judulController = TextEditingController();
  final _lokasiController = TextEditingController();
  final _deskripsiController = TextEditingController();
  final _kategoriLainnyaController = TextEditingController();

  // Variabel untuk Dropdown
  String? _selectedJenisUsulan; // <--- Variabel Baru
  String? _selectedParent;
  String? _selectedSub;

  // Data Jenis Usulan
  final List<String> _jenisUsulanData = [
    'Proposal Kepala Desa',
    'Proposal Kelompok Tani/P3A',
    'Usulan Petugas O&P',
    'Usulan Dinas/SKPD Yang Mendukung Program Lainnya',
    'Laporan Masyarakat',
  ];

  // Struktur Data Kategori
  final Map<String, List<String>> _kategoriData = {
    'Irigasi Permukaan': [
      'Bangunan Utama/Bendung',
      'Saluran Primer',
      'Saluran Sekunder',
      'Bangunan Pembagi',
      'Bangunan Pelengkap',
      'Saluran dan Bangunan Pembuang'
    ],
    'Irigasi Rawa': [
      'Saluran Primer',
      'Saluran Sekunder',
      'Pintu Air',
      'Bangunan Pelengkap',
      'Saluran dan Bangunan Pembuang'
    ],
    'Sungai': [
      'Tanggul',
      'Badan Sungai',
      'Bangunan Pengendali Banjir',
      'Drainase Makro'
    ],
    'Pantai': [
      'Breakwater',
      'Seawalls',
      'Revetments',
      'Groins',
      'Jetty',
      'Beach Norishment',
      'Terumbu Buatan'
    ],
    'Lainnya': []
  };

  // --- FUNGSI PILIH SUMBER FOTO ---
  void _showPickerOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            const ListTile(
              title: Text("Pilih Sumber Foto", style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: Colors.blue),
              title: const Text("Ambil dari Galeri"),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Colors.red),
              title: const Text("Ambil dari Kamera"),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      if (source == ImageSource.gallery) {
        final List<XFile> pickedFiles = await _picker.pickMultiImage(imageQuality: 25);
        if (pickedFiles.isNotEmpty) {
          for (var xFile in pickedFiles) {
            final file = File(xFile.path);
            if (await file.exists()) {
              setState(() {
                if (_images.length < 5) _images.add(file);
              });
            }
          }
        }
      } else {
        final XFile? pickedFile = await _picker.pickImage(source: source, imageQuality: 25);
        if (pickedFile != null) {
          setState(() {
            if (_images.length < 5) _images.add(File(pickedFile.path));
          });
        }
      }
    } catch (e) {
      debugPrint("Gagal mengambil gambar: $e");
    }
  }

  void _removeImage(int index) {
    setState(() => _images.removeAt(index));
  }

  // --- FUNGSI KIRIM ---
  void _handleKirimLaporan() async {
    String finalKategori = "";
    if (_selectedParent == 'Lainnya') {
      finalKategori = _kategoriLainnyaController.text;
    } else {
      finalKategori = "${_selectedParent} - ${_selectedSub}";
    }

    // Validasi Field (Termasuk Jenis Usulan)
    if (_images.isEmpty ||
        _selectedJenisUsulan == null ||
        _judulController.text.isEmpty ||
        _selectedParent == null ||
        (_selectedParent != 'Lainnya' && _selectedSub == null) ||
        _lokasiController.text.isEmpty) {
      _showSnackBar("Harap lengkapi Foto, Jenis Usulan, Kategori, Judul, dan Lokasi!", Colors.orange);
      return;
    }

    LoadingDialog.show(context);

    try {
      final prefs = await SharedPreferences.getInstance();
      int userId = prefs.getInt('user_id') ?? 0;

      final response = await ApiService().createReport(
        userId: userId,
        jenisUsulan: _selectedJenisUsulan!, // <--- Data baru dikirim ke API
        kategori: finalKategori,
        judul: _judulController.text,
        lokasi: _lokasiController.text,
        deskripsi: _deskripsiController.text,
        foto: _images,
      );

      if (!mounted) return;
      LoadingDialog.hide(context);

      if (response.statusCode == 201 || response.statusCode == 200) {
        _showSnackBar("Laporan berhasil terkirim!", Colors.green);
        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) Navigator.of(context).pop();
        });
      } else {
        _showSnackBar("Gagal: ${response.data['message']}", Colors.red);
      }
    } catch (e) {
      if (mounted) {
        LoadingDialog.hide(context);
        _showSnackBar("Terjadi kesalahan sistem", Colors.red);
      }
    }
  }

  void _showSnackBar(String message, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: color, duration: const Duration(milliseconds: 1500))
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Buat Laporan Aduan", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: const Color(0xFFFFD700),
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Foto Kerusakan (Maks 5)", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),

            // AREA PREVIEW MULTIPLE IMAGES
            SizedBox(
              height: 120,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _images.length + 1,
                itemBuilder: (context, index) {
                  if (index == _images.length) {
                    return GestureDetector(
                      onTap: _showPickerOptions,
                      child: Container(
                        width: 100,
                        margin: const EdgeInsets.only(right: 10, top: 5, bottom: 5),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(color: const Color(0xFFFFD700), width: 2),
                        ),
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_a_photo, color: Color(0xFFFFD700), size: 30),
                            Text("Tambah", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    );
                  }

                  return Stack(
                    children: [
                      Container(
                        width: 100,
                        margin: const EdgeInsets.only(right: 10, top: 5, bottom: 5),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          image: DecorationImage(
                            image: FileImage(_images[index]),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Positioned(
                        right: 0, top: 0,
                        child: GestureDetector(
                          onTap: () => _removeImage(index),
                          child: Container(
                            decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                            child: const Icon(Icons.close, color: Colors.white, size: 20),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),

            const SizedBox(height: 25),

            // --- INPUT BARU: JENIS USULAN ---
            const Text("Jenis Usulan", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _selectedJenisUsulan,
              hint: const Text("Pilih Jenis Usulan"),
              isExpanded: true,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
                prefixIcon: Icon(Icons.assignment, color: Colors.blueGrey),
              ),
              items: _jenisUsulanData.map((String value) => DropdownMenuItem(value: value, child: Text(value))).toList(),
              onChanged: (newValue) => setState(() => _selectedJenisUsulan = newValue),
            ),

            const SizedBox(height: 20),

            // --- KATEGORI UTAMA ---
            const Text("Kategori Utama", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _selectedParent,
              hint: const Text("Pilih Kategori Utama"),
              isExpanded: true,
              decoration: const InputDecoration(
                border: OutlineInputBorder(), 
                filled: true, 
                fillColor: Colors.white,
                prefixIcon: Icon(Icons.category, color: Colors.blueGrey),
              ),
              items: _kategoriData.keys.map((String value) => DropdownMenuItem(value: value, child: Text(value))).toList(),
              onChanged: (newValue) => setState(() { _selectedParent = newValue; _selectedSub = null; }),
            ),

            // --- SUB KATEGORI ---
            if (_selectedParent != null && _selectedParent != 'Lainnya') ...[
              const SizedBox(height: 20),
              Text("Detail Bagian ($_selectedParent)", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blueGrey)),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedSub,
                hint: const Text("Pilih Detail Bagian/Bangunan"),
                isExpanded: true,
                decoration: const InputDecoration(border: OutlineInputBorder(), filled: true, fillColor: Colors.white),
                items: _kategoriData[_selectedParent]!.map((String value) => DropdownMenuItem(value: value, child: Text(value))).toList(),
                onChanged: (newValue) => setState(() => _selectedSub = newValue),
              ),
            ],

            // --- INPUT LAINNYA ---
            if (_selectedParent == 'Lainnya') ...[
              const SizedBox(height: 20),
              TextField(
                controller: _kategoriLainnyaController,
                decoration: const InputDecoration(labelText: "Sebutkan Kategori", border: OutlineInputBorder(), prefixIcon: Icon(Icons.edit_note)),
              ),
            ],

            const SizedBox(height: 20),
            const Text("Judul Laporan", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(controller: _judulController, decoration: const InputDecoration(hintText: "Contoh: Pintu Air Berkarat", border: OutlineInputBorder())),

            const SizedBox(height: 20),
            const Text("Lokasi / Alamat Kejadian", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(controller: _lokasiController, decoration: const InputDecoration(hintText: "Nama lokasi atau patokan", prefixIcon: Icon(Icons.location_on, color: Colors.red), border: OutlineInputBorder())),

            const SizedBox(height: 20),
            const Text("Deskripsi Tambahan (Opsional)", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(controller: _deskripsiController, maxLines: 3, decoration: const InputDecoration(hintText: "Jelaskan detail kerusakan di sini...", border: OutlineInputBorder())),
            
            const SizedBox(height: 35),

            // --- TOMBOL KIRIM ---
            ElevatedButton(
              onPressed: _handleKirimLaporan,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFD700),
                minimumSize: const Size(double.infinity, 55),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text("KIRIM LAPORAN SEKARANG", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 16)),
            ),
            const SizedBox(height: 40), 
          ],
        ),
      ),
    );
  }
}