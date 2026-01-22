import 'package:flutter/material.dart';
import 'pages/dashboard_page.dart';
import 'pages/login_page.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID', null); // Tambahkan ini
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
        // Identitas Warna Dinas PU
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFFFD700),
          primary: const Color(0xFFFFD700),
          onPrimary: Colors.black,
          secondary: const Color(0xFF1A1A1A), // Hitam untuk kontras
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFFFD700),
          foregroundColor: Colors.black,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.black),
        ),
      ),
      home: const LoginPage(),
    );
  }
}