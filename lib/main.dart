import 'package:flutter/material.dart';
// import 'pages/dashboard_page.dart';
import 'pages/login_page.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'dart:io'; // Tambahkan import ini untuk HttpOverrides

// 1. Tambahkan class MyHttpOverrides di luar fungsi main
class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..userAgent = 'AplikasiELaporPU_TanahLaut_v1_0';
    // User-agent di atas memberitahu server OSM siapa yang memanggil datanya
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Aktifkan HttpOverrides sebelum runApp
  HttpOverrides.global = MyHttpOverrides();

  await initializeDateFormatting('id_ID', null);
  runApp(const ElaporApp());
}

class ElaporApp extends StatelessWidget {
  const ElaporApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'E-Lapor PU',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFFFD700),
          primary: const Color(0xFFFFD700),
          onPrimary: Colors.black,
          secondary: const Color(0xFF1A1A1A),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFFFD700),
          foregroundColor: Colors.black,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.black,
          ),
        ),
      ),
      home: const LoginPage(),
    );
  }
}
