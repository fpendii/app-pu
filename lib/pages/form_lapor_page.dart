import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import '../widgets/loading_dialog.dart';
import '../services/api_service.dart';
import 'pilih_lokasi_page.dart';

class FormLaporPage extends StatefulWidget {
  const FormLaporPage({super.key});

  @override
  State<FormLaporPage> createState() => _FormLaporPageState();
}

class _FormLaporPageState extends State<FormLaporPage> {
  // --- VARIABEL & CONTROLLER ---
  final List<File> _images = [];
  final _picker = ImagePicker();

  final _judulController = TextEditingController();
  final _lokasiController = TextEditingController();
  final _deskripsiController = TextEditingController();
  final _kategoriLainnyaController = TextEditingController();

  String? _selectedJenisUsulan;
  // String? _selectedPrioritas;
  String? _selectedParent;
  String? _selectedSub;

  // --- DATA MASTER ---
  final List<String> _jenisUsulanData = [
    'Proposal Kepala Desa',
    'Proposal Kelompok Tani/P3A',
    'Usulan Petugas O&P',
    'Usulan Dinas/SKPD Yang Mendukung Program Lainnya',
    'Laporan Masyarakat',
  ];

  // final List<String> _prioritasData = ['Rendah', 'Sedang', 'Tinggi', 'Darurat'];

  final Map<String, List<String>> _kategoriData = {
    'Irigasi Permukaan': [
      'Bangunan Utama/Bendung',
      'Saluran Primer',
      'Saluran Sekunder',
      'Bangunan Pembagi',
      'Bangunan Pelengkap',
      'Saluran dan Bangunan Pembuang',
    ],
    'Irigasi Rawa': [
      'Saluran Primer',
      'Saluran Sekunder',
      'Pintu Air',
      'Bangunan Pelengkap',
      'Saluran dan Bangunan Pembuang',
    ],
    'Sungai': [
      'Tanggul',
      'Badan Sungai',
      'Bangunan Pengendali Banjir',
      'Drainase Makro',
    ],
    'Pantai': [
      'Breakwater',
      'Seawalls',
      'Revetments',
      'Groins',
      'Jetty',
      'Beach Norishment',
      'Terumbu Buatan',
    ],
    'Lainnya': [],
  };

  void _bukaPeta() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const PilihLokasiPage(),
      ), // Pastikan class PilihLokasiPage sudah dibuat
    );

    if (result != null) {
      setState(() {
        // Mengisi controller lokasi otomatis dengan alamat dari peta
        _lokasiController.text = result['alamat'];

        // Tips: Jika API Anda butuh koordinat terpisah,
        // Anda bisa simpan ke variabel double lat, long;
      });
    }
  }

  // --- HELPER UI ---
  // Color _getPriorityColor(String priority) {
  //   switch (priority) {
  //     case 'Darurat':
  //       return Colors.red;
  //     case 'Tinggi':
  //       return Colors.orange;
  //     case 'Sedang':
  //       return Colors.blue;
  //     default:
  //       return Colors.green;
  //   }
  // }

  // --- FUNGSI PICKER FOTO ---
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
              title: Text(
                "Pilih Sumber Foto",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
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
        final List<XFile> pickedFiles = await _picker.pickMultiImage(
          imageQuality: 25,
        );
        if (pickedFiles.isNotEmpty) {
          for (var xFile in pickedFiles) {
            if (_images.length < 5) {
              setState(() => _images.add(File(xFile.path)));
            }
          }
        }
      } else {
        final XFile? pickedFile = await _picker.pickImage(
          source: source,
          imageQuality: 25,
        );
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

  // --- FUNGSI KIRIM ---
  void _handleKirimLaporan() async {
    String finalKategori = "";
    if (_selectedParent == 'Lainnya') {
      finalKategori = _kategoriLainnyaController.text;
    } else {
      finalKategori = "${_selectedParent} - ${_selectedSub}";
    }

    // Validasi Semua Field
    if (_images.isEmpty ||
        _selectedJenisUsulan == null ||
        _selectedParent == null ||
        (_selectedParent != 'Lainnya' && _selectedSub == null) ||
        _judulController.text.isEmpty ||
        _lokasiController.text.isEmpty) {
      _showSnackBar(
        "Harap lengkapi semua data dan lampirkan foto!",
        Colors.orange,
      );
      return;
    }

    LoadingDialog.show(context);

    try {
      final prefs = await SharedPreferences.getInstance();
      int userId = prefs.getInt('user_id') ?? 0;

      final response = await ApiService().createReport(
        userId: userId,
        jenisUsulan: _selectedJenisUsulan!,
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
          if (mounted) Navigator.pop(context);
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
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message), backgroundColor: color));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Buat Laporan Aduan",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: const Color(0xFFFFD700),
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- AREA FOTO ---
            const Text(
              "Foto Kerusakan (Maks 5)",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 110,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _images.length + 1,
                itemBuilder: (context, index) {
                  if (index == _images.length) {
                    return _buildAddPhotoButton();
                  }
                  return _buildImagePreview(index);
                },
              ),
            ),

            const SizedBox(height: 25),

            // --- JENIS USULAN ---
            _buildLabel("Jenis Usulan"),
            _buildDropdown(
              value: _selectedJenisUsulan,
              hint: "Pilih Jenis Usulan",
              icon: Icons.assignment_outlined,
              items: _jenisUsulanData,
              onChanged: (v) => setState(() => _selectedJenisUsulan = v),
            ),

            const SizedBox(height: 20),

            // --- KATEGORI ---
            _buildLabel("Kategori Utama"),
            _buildDropdown(
              value: _selectedParent,
              hint: "Pilih Kategori",
              icon: Icons.category_outlined,
              items: _kategoriData.keys.toList(),
              onChanged: (v) => setState(() {
                _selectedParent = v;
                _selectedSub = null;
              }),
            ),

            if (_selectedParent != null && _selectedParent != 'Lainnya') ...[
              const SizedBox(height: 20),
              _buildLabel("Detail Bagian ($_selectedParent)"),
              _buildDropdown(
                value: _selectedSub,
                hint: "Pilih Detail Bagian",
                icon: Icons.account_tree_outlined,
                items: _kategoriData[_selectedParent]!,
                onChanged: (v) => setState(() => _selectedSub = v),
              ),
            ],

            if (_selectedParent == 'Lainnya') ...[
              const SizedBox(height: 20),
              _buildLabel("Sebutkan Kategori"),
              _buildTextField(
                _kategoriLainnyaController,
                "Ketik kategori di sini...",
                icon: Icons.edit_note,
              ),
            ],

            const SizedBox(height: 20),

            // --- JUDUL & LOKASI ---
            _buildLabel("Judul Laporan"),
            _buildTextField(_judulController, "Contoh: Kerusakan Bendung A"),

            const SizedBox(height: 20),
            _buildLabel("Lokasi / Alamat"),
            GestureDetector(
              onTap: _bukaPeta, // Klik area ini untuk buka peta
              child: AbsorbPointer(
                // Agar keyboard tidak muncul saat diklik
                child: _buildTextField(
                  _lokasiController,
                  "Ketuk untuk memilih lokasi dari peta...",
                  icon: Icons.map_outlined, // Ubah icon agar lebih relevan
                ),
              ),
            ),

            const SizedBox(height: 20),
            _buildLabel("Deskripsi Tambahan (Opsional)"),
            _buildTextField(
              _deskripsiController,
              "Detail tambahan...",
              maxLines: 3,
            ),

            const SizedBox(height: 40),

            // --- TOMBOL KIRIM ---
            ElevatedButton(
              onPressed: _handleKirimLaporan,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFD700),
                minimumSize: const Size(double.infinity, 60),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                "KIRIM LAPORAN SEKARANG",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  fontSize: 16,
                ),
              ),
            ),
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }

  // --- REUSABLE COMPONENTS ---
  Widget _buildLabel(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold)),
  );

  Widget _buildTextField(
    TextEditingController controller,
    String hint, {
    IconData? icon,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: icon != null ? Icon(icon) : null,
        border: const OutlineInputBorder(),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }

  Widget _buildDropdown({
    required String? value,
    required String hint,
    required IconData icon,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      hint: Text(hint),
      isExpanded: true,
      decoration: InputDecoration(
        border: const OutlineInputBorder(),
        prefixIcon: Icon(icon),
        filled: true,
        fillColor: Colors.white,
      ),
      items: items
          .map((e) => DropdownMenuItem(value: e, child: Text(e)))
          .toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildAddPhotoButton() => GestureDetector(
    onTap: _showPickerOptions,
    child: Container(
      width: 100,
      margin: const EdgeInsets.only(right: 10, top: 5, bottom: 5),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: const Color(0xFFFFD700), width: 2),
      ),
      child: const Icon(Icons.add_a_photo, color: Color(0xFFFFD700)),
    ),
  );

  Widget _buildImagePreview(int index) => Stack(
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
        top: 0,
        right: 5,
        child: GestureDetector(
          onTap: () => setState(() => _images.removeAt(index)),
          child: const CircleAvatar(
            radius: 12,
            backgroundColor: Colors.red,
            child: Icon(Icons.close, size: 16, color: Colors.white),
          ),
        ),
      ),
    ],
  );
}
