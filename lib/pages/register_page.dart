import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:dio/dio.dart';
import '../services/api_service.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  // File & Picker
  File? _imageKtp;
  final _picker = ImagePicker();

  // Controllers
  final _nikController = TextEditingController();
  final _namaController = TextEditingController();
  final _emailController = TextEditingController();
  final _waController = TextEditingController();
  final _alamatController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // State Variables
  String? _jenisKelamin;
  String? _selectedPekerjaan;
  bool _isPasswordVisible = false;
  bool _isConfirmVisible = false;

  // Penampung Error dari Laravel
  Map<String, dynamic> _errors = {};

  final List<String> _pekerjaanList = [
    'Pegawai Negeri (ASN)',
    'Karyawan Swasta',
    'Wiraswasta',
    'Pelajar/Mahasiswa',
    'Buruh',
    'Ibu Rumah Tangga',
    'Lainnya',
  ];

  Future<void> _getKtpImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 50, // Kompresi 50% untuk menghindari limit server
      );

      if (pickedFile != null) {
        final file = File(pickedFile.path);
        if (await file.exists()) {
          setState(() {
            _imageKtp = file;
            _errors.remove('foto_ktp');
          });
        }
      }
    } catch (e) {
      _showSnackBar("Gagal mengambil gambar: $e", Colors.red);
    }
  }

  void _handleRegister() async {
    setState(() => _errors = {});

    // 1. Validasi Awal (Client Side)
    if (_imageKtp == null) {
      _showSnackBar("Mohon unggah foto KTP terlebih dahulu", Colors.orange);
      return;
    }

    // Cek apakah file benar-benar ada di storage (Mencegah PathNotFoundException)
    if (!await _imageKtp!.exists()) {
      _showSnackBar(
        "File foto hilang dari cache. Silakan ambil foto ulang.",
        Colors.red,
      );
      setState(() => _imageKtp = null);
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      _showSnackBar("Konfirmasi password tidak cocok!", Colors.red);
      return;
    }

    // 2. Tampilkan Loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(color: Color(0xFFFFD700)),
      ),
    );

    try {
      final response = await ApiService().register(
        nik: _nikController.text,
        name: _namaController.text,
        email: _emailController.text,
        password: _passwordController.text,
        jenisKelamin: _jenisKelamin ?? "",
        pekerjaan: _selectedPekerjaan ?? "",
        alamat: _alamatController.text,
        nomorWa: _waController.text,
        fotoKtp: _imageKtp!,
      );

      if (!mounted) return;
      Navigator.pop(context); // Tutup Loading

      // 3. Handling Response
      if (response.statusCode == 201) {
        _showSnackBar("Registrasi Berhasil! Silakan Login.", Colors.green);
        Navigator.pop(context);
      } else if (response.statusCode == 422) {
        setState(() {
          _errors = response.data['errors'] ?? {};
        });
        _showSnackBar(
          response.data['message'] ?? "Validasi Gagal",
          Colors.orange,
        );
      } else {
        // Ambil pesan dari server jika ada, jika tidak pakai pesan default
        String errorMsg =
            response.data?['message'] ??
            "Terjadi kesalahan server (${response.statusCode})";
        _showSnackBar(errorMsg, Colors.red);
      }
    } catch (e) {
      if (mounted) Navigator.pop(context);

      String pesanError = "Terjadi kesalahan.";

      if (e is DioException) {
        if (e.type == DioExceptionType.connectionTimeout ||
            e.type == DioExceptionType.sendTimeout) {
          pesanError =
              "Waktu upload habis. Pastikan ukuran foto tidak terlalu besar atau koneksi stabil.";
        } else if (e.type == DioExceptionType.connectionError) {
          pesanError =
              "Tidak dapat terhubung ke server. Pastikan server aktif dan IP benar.";
        } else if (e.response?.statusCode == 413) {
          pesanError = "Ukuran file foto terlalu besar untuk diterima server.";
        } else {
          pesanError = "Masalah jaringan: ${e.message}";
        }
      } else if (e is PathNotFoundException) {
        pesanError =
            "File foto tidak dapat ditemukan di sistem. Silakan ambil ulang.";
      } else {
        pesanError = "Error: $e";
      }

      _showSnackBar(pesanError, Colors.red);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Daftar Akun Baru",
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(25),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Unggah Foto KTP",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            _buildKtpPicker(),
            if (_errors['foto_ktp'] != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  _errors['foto_ktp'][0],
                  style: const TextStyle(color: Colors.red, fontSize: 12),
                ),
              ),

            const SizedBox(height: 30),
            const Text(
              "Data Identitas",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const Divider(),

            _buildTextField(
              _nikController,
              "NIK (16 Digit)",
              Icons.credit_card,
              "nik",
              keyboardType: TextInputType.number,
            ),
            _buildTextField(
              _namaController,
              "Nama Lengkap",
              Icons.person_outline,
              "name",
            ),

            const SizedBox(height: 15),
            const Text(
              "Jenis Kelamin",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Row(
              children: [
                _buildRadioGender("Laki-laki"),
                _buildRadioGender("Perempuan"),
              ],
            ),
            if (_errors['jenis_kelamin'] != null)
              Text(
                _errors['jenis_kelamin'][0],
                style: const TextStyle(color: Colors.red, fontSize: 12),
              ),

            const SizedBox(height: 15),
            const Text(
              "Pekerjaan",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            _buildDropdownPekerjaan(),

            const SizedBox(height: 20),
            const Text(
              "Kontak & Alamat",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const Divider(),

            _buildTextField(
              _emailController,
              "Email",
              Icons.email_outlined,
              "email",
              keyboardType: TextInputType.emailAddress,
            ),
            _buildTextField(
              _waController,
              "Nomor WhatsApp",
              Icons.phone_android,
              "nomor_wa",
              keyboardType: TextInputType.phone,
            ),
            _buildTextField(
              _alamatController,
              "Alamat Lengkap",
              Icons.home_outlined,
              "alamat",
              maxLines: 3,
            ),

            const SizedBox(height: 20),
            const Text(
              "Keamanan",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const Divider(),

            _buildPasswordField(
              _passwordController,
              "Password",
              "password",
              _isPasswordVisible,
              (v) => setState(() => _isPasswordVisible = v),
            ),
            const SizedBox(height: 15),
            _buildPasswordField(
              _confirmPasswordController,
              "Konfirmasi Password",
              "confirm",
              _isConfirmVisible,
              (v) => setState(() => _isConfirmVisible = v),
            ),

            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: _handleRegister,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFD700),
                minimumSize: const Size(double.infinity, 60),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                "DAFTAR SEKARANG",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // --- UI COMPONENTS ---

  Widget _buildKtpPicker() {
    return GestureDetector(
      onTap: _getKtpImage,
      child: Container(
        height: 180,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: _errors['foto_ktp'] != null
                ? Colors.red
                : const Color(0xFFFFD700),
            width: 2,
          ),
          image: _imageKtp != null
              ? DecorationImage(image: FileImage(_imageKtp!), fit: BoxFit.cover)
              : null,
        ),
        child: _imageKtp == null
            ? const Icon(Icons.add_a_photo, size: 50, color: Colors.grey)
            : null,
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController ctrl,
    String label,
    IconData icon,
    String key, {
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(top: 15),
      child: TextField(
        controller: ctrl,
        keyboardType: keyboardType,
        maxLines: maxLines,
        onChanged: (_) => setState(() => _errors.remove(key)),
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: const OutlineInputBorder(),
          errorText: _errors[key] != null ? _errors[key][0] : null,
        ),
      ),
    );
  }

  Widget _buildPasswordField(
    TextEditingController ctrl,
    String label,
    String key,
    bool visible,
    Function(bool) toggle,
  ) {
    return TextField(
      controller: ctrl,
      obscureText: !visible,
      onChanged: (_) => setState(() => _errors.remove(key)),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(Icons.lock_outline),
        border: const OutlineInputBorder(),
        errorText: _errors[key] != null ? _errors[key][0] : null,
        suffixIcon: IconButton(
          icon: Icon(visible ? Icons.visibility : Icons.visibility_off),
          onPressed: () => toggle(!visible),
        ),
      ),
    );
  }

  Widget _buildRadioGender(String title) {
    return Expanded(
      child: RadioListTile<String>(
        title: Text(title, style: const TextStyle(fontSize: 13)),
        value: title,
        contentPadding: EdgeInsets.zero,
        groupValue: _jenisKelamin,
        onChanged: (val) => setState(() {
          _jenisKelamin = val;
          _errors.remove('jenis_kelamin');
        }),
      ),
    );
  }

  Widget _buildDropdownPekerjaan() {
    return DropdownButtonFormField<String>(
      value: _selectedPekerjaan,
      hint: const Text("Pilih Pekerjaan"),
      items: _pekerjaanList
          .map((e) => DropdownMenuItem(value: e, child: Text(e)))
          .toList(),
      onChanged: (val) => setState(() {
        _selectedPekerjaan = val;
        _errors.remove('pekerjaan');
      }),
      decoration: InputDecoration(
        border: const OutlineInputBorder(),
        errorText: _errors['pekerjaan'] != null
            ? _errors['pekerjaan'][0]
            : null,
      ),
    );
  }

  void _showSnackBar(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
