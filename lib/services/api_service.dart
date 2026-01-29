import 'package:dio/dio.dart';
import 'dart:io';

class ApiService {
  // GANTI DENGAN IP LAPTOP KAMU (Cek via ipconfig di CMD)
  static const String baseUrl = "http://192.168.100.2:8000/api";
  
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        "Accept": "application/json",
      },
    ),
  );

  // FUNGSI REGISTRASI
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
      // Dio menggunakan FormData untuk kirim file + teks
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
      // Jika terjadi error dari server
      return e.response ?? Response(requestOptions: RequestOptions(), statusCode: 500);
    }
  }

  // FUNGSI LOGIN
  Future<Response> login(String email, String password) async {
    try {
      return await _dio.post("/login", data: {
        "email": email,
        "password": password,
      });
    } on DioException catch (e) {
      return e.response ?? Response(requestOptions: RequestOptions(), statusCode: 500);
    }
  }

  Future<Response> createReport({
    required int userId,
    required String kategori,
    required String judul,
    required String lokasi,
    required String deskripsi,
    required File foto,
    }) async {
    try {
        FormData formData = FormData.fromMap({
        "user_id": userId,
        "kategori": kategori,
        "judul": judul,
        "lokasi": lokasi,
        "deskripsi": deskripsi,
        "foto_kerusakan": await MultipartFile.fromFile(
            foto.path,
            filename: foto.path.split('/').last,
        ),
        });

        return await _dio.post("/reports", data: formData);
    } on DioException catch (e) {
        return e.response ?? Response(requestOptions: RequestOptions(), statusCode: 500);
    }
  }

  Future<Response> getReports(int userId) async {
    try {
        return await _dio.get("/reports", queryParameters: {"user_id": userId});
    } on DioException catch (e) {
        return e.response ?? Response(requestOptions: RequestOptions(), statusCode: 500);
    }
  }

  Future<Response> postComment({
    required int reportId,
    required int userId,
    required String pesan,
    }) async {
    try {
        return await _dio.post("/comments", data: {
        "report_id": reportId,
        "user_id": userId,
        "pesan": pesan,
        });
    } on DioException catch (e) {
        return e.response ?? Response(requestOptions: RequestOptions(), statusCode: 500);
    }
 }
}