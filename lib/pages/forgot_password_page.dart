import 'package:flutter/material.dart';
import '../widgets/loading_dialog.dart';    
import '../services/api_service.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final TextEditingController _emailController = TextEditingController();

  void _handleResetPassword() async {
  String email = _emailController.text.trim();

  if (email.isEmpty) {
    _showSnackBar("Silakan masukkan email Anda", Colors.orange);
    return;
  }

  LoadingDialog.show(context);

  try {
    // Memanggil API Laravel
    final response = await ApiService().forgotPassword(email);

    if (!mounted) return;
    LoadingDialog.hide(context);

    if (response.statusCode == 200) {
      // Munculkan dialog sukses sesuai yang kita buat sebelumnya
      _showSuccessDialog(email); 
    }
  } catch (e) {
    if (mounted) LoadingDialog.hide(context);
    
    // Logika menangani error 404 (email tidak ada) atau 422 (format salah)
    _showSnackBar("Email tidak terdaftar atau terjadi kesalahan.", Colors.red);
  }
}

  // Fungsi pembantu untuk SnackBar
  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: color),
    );
  }

  // Fungsi pembantu untuk Dialog Sukses
  void _showSuccessDialog(String email) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text("Email Terkirim"),
        content: Text("Instruksi reset password telah dikirim ke $email."),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Tutup dialog
              Navigator.pop(context); // Kembali ke Login
            },
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Lupa Password", style: TextStyle(color: Colors.black)),
        backgroundColor: const Color(0xFFFFD700),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Atur Ulang Kata Sandi",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              "Masukkan email yang terdaftar. Kami akan mengirimkan tautan untuk mengatur ulang kata sandi Anda.",
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
            const SizedBox(height: 30),
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: "Email",
                prefixIcon: Icon(Icons.email_outlined),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _handleResetPassword,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFD700),
                minimumSize: const Size(double.infinity, 55),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                "KIRIM",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}