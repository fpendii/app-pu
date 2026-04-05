import 'package:dio/dio.dart';
import 'dart:io';

class ApiService {
  // GANTI DENGAN IP LAPTOP KAMU
  static const String baseUrl = "http://10.64.246.1:8000/api";

  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {"Accept": "application/json"},
    ),
  );

  // FUNGSI REGISTRASI (Tetap)
  Future<Response> register({
    required String nik,
    required String name,
    required String email,
    required String password,
    required String jenisKelamin,
    required String pekerjaan,
    required String alamat,
    required String nomorWa,
    required File fotoKtp,
  }) async {
    try {
      FormData formData = FormData.fromMap({
        "nik": nik,
        "name": name,
        "email": email,
        "password": password,
        "jenis_kelamin": jenisKelamin,
        "pekerjaan": pekerjaan,
        "alamat": alamat,
        "nomor_wa": nomorWa,
        "foto_ktp": await MultipartFile.fromFile(
          fotoKtp.path,
          filename: fotoKtp.path.split('/').last,
        ),
      });

      return await _dio.post("/register", data: formData);
    } on DioException catch (e) {
      return e.response ??
          Response(requestOptions: RequestOptions(), statusCode: 500);
    }
  }

  // FUNGSI LOGIN (Tetap)
  Future<Response> login(String email, String password) async {
    try {
      return await _dio.post(
        "/login",
        data: {"email": email, "password": password},
      );
    } on DioException catch (e) {
      return e.response ??
          Response(requestOptions: RequestOptions(), statusCode: 500);
    }
  }

  // FUNGSI CREATE REPORT (Update: Mendukung Multiple Images)
  Future<Response> createReport({
    required int userId,
    required String jenisUsulan,
    required String kategori,
    required String judul,
    required String lokasi,
    required String prioritas,
    required String deskripsi,
    required List<File> foto,
  }) async {
    try {
      FormData formData = FormData.fromMap({
        "user_id": userId,
        'jenis_usulan': jenisUsulan,
        "kategori": kategori,
        "judul": judul,
        "lokasi": lokasi,
        'prioritas': prioritas,
        "deskripsi": deskripsi,
      });

      // Menambahkan banyak foto ke FormData
      for (File file in foto) {
        // PENTING: Cek apakah file benar-benar ada di storage
        if (await file.exists()) {
          String fileName = file.path.split('/').last;
          formData.files.add(
            MapEntry(
              "foto_kerusakan[]", // Pastikan pakai [] untuk array di Laravel
              await MultipartFile.fromFile(file.path, filename: fileName),
            ),
          );
        } else {
          print("DEBUG: File tidak ditemukan di path ${file.path}");
        }
      }

      return await _dio.post("/reports", data: formData);
    } on DioException catch (e) {
      print("DIO ERROR: ${e.response?.data ?? e.message}");
      return e.response ??
          Response(requestOptions: RequestOptions(), statusCode: 500);
    } catch (e) {
      print("GENERAL ERROR: $e");
      throw Exception("Gagal mengirim data");
    }
  }

  Future<Response> getReports(int userId) async {
    try {
      return await _dio.get("/reports", queryParameters: {"user_id": userId});
    } on DioException catch (e) {
      return e.response ??
          Response(requestOptions: RequestOptions(), statusCode: 500);
    }
  }

  Future<Response> postComment({
    required int reportId,
    required int userId,
    required String pesan,
  }) async {
    try {
      return await _dio.post(
        "/comments",
        data: {"report_id": reportId, "user_id": userId, "pesan": pesan},
      );
    } on DioException catch (e) {
      return e.response ??
          Response(requestOptions: RequestOptions(), statusCode: 500);
    }
  }

  // Tambahkan ini di dalam class ApiService
  Future<Response> getDashboardStats() async {
    try {
      return await _dio.get("/dashboard-stats");
    } on DioException catch (e) {
      return e.response ??
          Response(requestOptions: RequestOptions(), statusCode: 500);
    }
  }

  Future<Response> getUserProfile(int userId) async {
    try {
      return await _dio.get("/user-profile/$userId");
    } on DioException catch (e) {
      return e.response ??
          Response(requestOptions: RequestOptions(), statusCode: 500);
    }
  }
}
