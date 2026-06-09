import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'register_page.dart';
import 'dashboard_page.dart';
import '../widgets/loading_dialog.dart';
import '../services/api_service.dart';
import 'forgot_password_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _isPasswordVisible = false;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // 1. FUNGSI UNTUK MENAMPILKAN MODAL HUBUNGI ADMIN
  // Sekarang menerima parameter 'phone' dari API
  void _showContactAdminModal(String status, String phone) {
    String title = status == 'menunggu'
        ? "Akun Belum Diverifikasi"
        : "Akun Ditolak";
    String description = status == 'menunggu'
        ? "Akun Anda sedang dalam antrean verifikasi Admin. Silahkan hubungi admin untuk mempercepat proses."
        : "Mohon maaf, pengajuan akun Anda ditolak oleh Admin. Hubungi admin untuk informasi lebih lanjut.";
    Color iconColor = status == 'menunggu' ? Colors.orange : Colors.red;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 25),
              Icon(
                status == 'menunggu'
                    ? Icons.timer_outlined
                    : Icons.cancel_outlined,
                size: 70,
                color: iconColor,
              ),
              const SizedBox(height: 20),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                description,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey, fontSize: 14),
              ),
              const SizedBox(height: 30),
              ElevatedButton.icon(
                onPressed: () async {
                  const String message =
                      "Halo Admin, mohon verifikasi akun saya untuk aplikasi E-Lapor PU.";

                  // URI dibuat secara dinamis berdasarkan nomor dari parameter 'phone'
                  final Uri whatsappUrl = Uri(
                    scheme: 'https',
                    host: 'wa.me',
                    path: phone,
                    queryParameters: {'text': message},
                  );

                  try {
                    await launchUrl(
                      whatsappUrl,
                      mode: LaunchMode.externalApplication,
                    );
                  } catch (e) {
                    _showSnackBar("Gagal membuka WhatsApp", Colors.red);
                  }
                },
                icon: const Icon(Icons.chat, color: Colors.white),
                label: const Text(
                  "Hubungi Admin via WhatsApp",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  minimumSize: const Size(double.infinity, 55),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  "Tutup",
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // 2. FUNGSI HANDLE LOGIN
  void _handleLogin() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      _showSnackBar("Email dan Password tidak boleh kosong", Colors.orange);
      return;
    }

    LoadingDialog.show(context);

    try {
      final response = await ApiService().login(
        _emailController.text,
        _passwordController.text,
      );

      if (!mounted) return;
      LoadingDialog.hide(context);

      if (response.statusCode == 200) {
        final userData = response.data['data'];

        // --- AMBIL STATUS VERIFIKASI & KONTAK ADMIN DARI API ---
        String statusVerifikasi = userData['verifikasi'];
        String adminPhone = "6282177724040";  

        if (statusVerifikasi != 'acc') {
          _showContactAdminModal(statusVerifikasi, adminPhone);
          return;
        }

        // JIKA SUDAH 'acc', SIMPAN SESIno
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt('user_id', userData['id']);
        await prefs.setString('user_name', userData['name']);
        await prefs.setString('user_role', userData['role']);
        await prefs.setBool('is_login', true);

        _showSnackBar("Selamat Datang, ${userData['name']}!", Colors.green);

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const DashboardPage()),
        );
      } else {
        String msg = response.data['message'] ?? "Login Gagal";
        _showSnackBar(msg, Colors.red);
      }
    } catch (e) {
      if (mounted) LoadingDialog.hide(context);
      _showSnackBar(
        "Koneksi gagal ke server. Periksa jaringan Anda!",
        Colors.red,
      );
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            // HEADER UI
            Container(
              height: 300,
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Color(0xFFFFD700),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(80),
                ),
              ),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image(
                    image: AssetImage("assets/images/logo_soc.png"),
                    height: 100,
                  ),
                  SizedBox(height: 10),
                  Text(
                    "SOC",
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  Text("Layanan Aspirasi & Pengaduan Online"),
                ],
              ),
            ),

            // FORM LOGIN
            Padding(
              padding: const EdgeInsets.all(30),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: "Email",
                      prefixIcon: Icon(Icons.email_outlined),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _passwordController,
                    obscureText: !_isPasswordVisible,
                    decoration: InputDecoration(
                      labelText: "Password",
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isPasswordVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                        onPressed: () => setState(
                          () => _isPasswordVisible = !_isPasswordVisible,
                        ),
                      ),
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Align(
  alignment: Alignment.centerRight,
  child: TextButton(
    onPressed: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const ForgotPasswordPage(),
        ),
      );
    },
    child: const Text("Lupa Password?"),
  ),

                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _handleLogin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFD700),
                      minimumSize: const Size(double.infinity, 55),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      "MASUK",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Belum punya akun?"),
                      TextButton(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const RegisterPage(),
                          ),
                        ),
                        child: const Text(
                          "Daftar Sekarang",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
