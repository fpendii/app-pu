import 'package:dio/dio.dart';
import 'dart:io';

class ApiService {
  // GANTI DENGAN IP LAPTOP KAMU
  static const String baseUrl = "https://staging-soc.batuah.id/api";
  static const String imageBaseUrl = "https://staging-soc.batuah.id/storage/";
  


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
      // Jika server sempat memberikan respon (misal 400, 413, 500)
      if (e.response != null) {
        return e.response!;
      }
      // Jika tidak ada respon (Timeout/Koneksi Putus), lempar kembali errornya
      rethrow;
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
    required String deskripsi,
    required List<File> foto,
    required String nomerPelapor,
  }) async {
    try {
      FormData formData = FormData.fromMap({
        "user_id": userId,
        'jenis_usulan': jenisUsulan,
        "kategori": kategori,
        "judul": judul,
        "lokasi": lokasi,
        "deskripsi": deskripsi,
        'nomer_pelapor': nomerPelapor,
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
  Future<Response> getDashboardStats(int userId) async {
  try {
    // Kirim userId sebagai query parameter agar dibaca oleh $request->query('user_id') di Laravel
    return await _dio.get("/dashboard-stats", queryParameters: {"user_id": userId});
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
  } // Di dalam class ApiService

  Future<Response> updateProfile(int userId, Map<String, dynamic> data) async {
    try {
      // Sesuaikan URL dengan endpoint API Laravel Anda
      // Gunakan 'PUT' atau 'POST' sesuai dengan Route di backend
      final response = await _dio.put(
        '/users/$userId',
        data: data,
        options: Options(
          headers: {
            'Accept': 'application/json',
            // Jika menggunakan Bearer Token, tambahkan di sini:
            // 'Authorization': 'Bearer $token',
          },
        ),
      );
      return response;
    } on DioException catch (e) {
      // Melemparkan error agar bisa ditangkap oleh try-catch di UI
      throw Exception(
        e.response?.data['message'] ?? "Gagal memperbarui profil",
      );
    }
  }

  Future<Response> forgotPassword(String email) async {
  try {
    final response = await _dio.post(
      '$baseUrl/forgot-password',
      data: {'email': email},
      options: Options(
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ),
    );
    return response;
  } catch (e) {
    rethrow;
  }
}
}
