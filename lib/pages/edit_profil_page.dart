import 'package:flutter/material.dart';
import '../services/api_service.dart';

class EditProfilPage extends StatefulWidget {
  final Map<String, dynamic> userData;

  const EditProfilPage({super.key, required this.userData});

  @override
  State<EditProfilPage> createState() => _EditProfilPageState();
}

class _EditProfilPageState extends State<EditProfilPage> {
  final _formKey = GlobalKey<FormState>();
  final ApiService _apiService = ApiService();

  // Controller untuk setiap field
  late TextEditingController _nameController;
  late TextEditingController _nikController;
  late TextEditingController _waController;
  late TextEditingController _alamatController;
  late TextEditingController _pekerjaanController;
  late TextEditingController _passController;

  bool _isLoading = false;
  bool _isPasswordVisible = false;
  String _jk = "Laki-laki";

  @override
  void initState() {
    super.initState();
    // Mengisi controller dengan data yang sudah ada dari database
    _nameController = TextEditingController(text: widget.userData['name']);
    _nikController = TextEditingController(text: widget.userData['nik']);
    _waController = TextEditingController(text: widget.userData['nomor_wa']);
    _alamatController = TextEditingController(text: widget.userData['alamat']);
    _pekerjaanController = TextEditingController(
      text: widget.userData['pekerjaan'],
    );
    _passController = TextEditingController();
    _jk = widget.userData['jenis_kelamin'] ?? "Laki-laki";
  }

  @override
  void dispose() {
    _nameController.dispose();
    _nikController.dispose();
    _waController.dispose();
    _alamatController.dispose();
    _pekerjaanController.dispose();
    _passController.dispose();
    super.dispose();
  }

  Future<void> _updateProfil() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // Menyiapkan data untuk dikirim ke API
      Map<String, dynamic> data = {
        "name": _nameController.text,
        "nik": _nikController.text,
        "nomor_wa": _waController.text,
        "alamat": _alamatController.text,
        "pekerjaan": _pekerjaanController.text,
        "jenis_kelamin": _jk,
      };

      // Hanya tambahkan password jika user mengisinya
      if (_passController.text.isNotEmpty) {
        data["password"] = _passController.text;
      }

      // Ganti 'updateProfile' dengan nama fungsi di api_service.dart Anda
      final response = await _apiService.updateProfile(
        widget.userData['id'],
        data,
      );

      if (response.statusCode == 200) {
        if (!mounted) return;
        Navigator.pop(
          context,
          true,
        ); // Kembali ke halaman sebelumnya dengan tanda sukses
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Profil berhasil diperbarui!")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Terjadi kesalahan: $e")));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Profil", style: TextStyle(color: Colors.black)),
        backgroundColor: const Color(0xFFFFD700),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Informasi Pribadi",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 20),

              _buildTextField(_nameController, "Nama Lengkap", Icons.person),
              const SizedBox(height: 15),

              _buildTextField(_nikController, "NIK", Icons.badge),
              const SizedBox(height: 15),

              _buildTextField(_waController, "Nomor WhatsApp", Icons.phone),
              const SizedBox(height: 15),

              _buildTextField(_pekerjaanController, "Pekerjaan", Icons.work),
              const SizedBox(height: 15),

              // Dropdown Jenis Kelamin
              DropdownButtonFormField<String>(
                value: _jk,
                decoration: const InputDecoration(
                  labelText: "Jenis Kelamin",
                  prefixIcon: Icon(Icons.wc),
                  border: OutlineInputBorder(),
                ),
                items: ["Laki-laki", "Perempuan"]
                    .map(
                      (label) =>
                          DropdownMenuItem(value: label, child: Text(label)),
                    )
                    .toList(),
                onChanged: (value) {
                  setState(() => _jk = value!);
                },
              ),
              const SizedBox(height: 15),

              _buildTextField(
                _alamatController,
                "Alamat Lengkap",
                Icons.map,
                maxLines: 3,
              ),

              const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Divider(),
              ),

              const Text(
                "Keamanan Akun",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 10),
              const Text(
                "Kosongkan password jika tidak ingin mengubahnya.",
                style: TextStyle(color: Colors.red, fontSize: 12),
              ),
              const SizedBox(height: 10),

              // Field Password dengan Icon Mata
              _buildTextField(
                _passController,
                "Password Baru",
                Icons.lock,
                isPass: true,
              ),

              const SizedBox(height: 40),

              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFD700),
                  minimumSize: const Size(double.infinity, 55),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: _isLoading ? null : _updateProfil,
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.black)
                    : const Text(
                        "SIMPAN PERUBAHAN",
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // Widget Helper untuk mempermudah pembuatan TextField
  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon, {
    bool isPass = false,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isPass ? !_isPasswordVisible : false,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: const OutlineInputBorder(),
        // Logic Icon Mata
        suffixIcon: isPass
            ? IconButton(
                icon: Icon(
                  _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                  color: Colors.grey,
                ),
                onPressed: () {
                  setState(() {
                    _isPasswordVisible = !_isPasswordVisible;
                  });
                },
              )
            : null,
      ),
      validator: (value) {
        if (!isPass && (value == null || value.isEmpty)) {
          return "$label tidak boleh kosong";
        }
        return null;
      },
    );
  }
}
