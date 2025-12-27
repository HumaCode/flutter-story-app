import 'dart:convert';
import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiHandler {
  static const String _tokenKey = 'auth_token';

  // ═══════════════════════════════════════════════════════════════
  // TOKEN MANAGEMENT
  // ═══════════════════════════════════════════════════════════════

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  static Future<void> removeToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }

  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  // ═══════════════════════════════════════════════════════════════
  // HEADERS
  // ═══════════════════════════════════════════════════════════════

  static Future<Map<String, String>> _getHeaders({
    bool isMultipart = false,
  }) async {
    final token = await getToken();
    return {
      if (!isMultipart) 'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // ═══════════════════════════════════════════════════════════════
  // HTTP METHODS
  // ═══════════════════════════════════════════════════════════════

  /// GET Request
  static Future<Either<String, Map<String, dynamic>>> get(String url) async {
    try {
      final headers = await _getHeaders();
      final response = await http
          .get(Uri.parse(url), headers: headers)
          .timeout(const Duration(seconds: 30));

      return _handleResponse(response);
    } on SocketException {
      return const Left('Tidak ada koneksi internet');
    } on HttpException {
      return const Left('Terjadi kesalahan pada server');
    } catch (e) {
      return Left('Error: $e');
    }
  }

  /// POST Request
  static Future<Either<String, Map<String, dynamic>>> post(
    String url, {
    Map<String, dynamic>? body,
  }) async {
    try {
      final headers = await _getHeaders();
      final response = await http
          .post(
            Uri.parse(url),
            headers: headers,
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(const Duration(seconds: 30));

      return _handleResponse(response);
    } on SocketException {
      return const Left('Tidak ada koneksi internet');
    } on HttpException {
      return const Left('Terjadi kesalahan pada server');
    } catch (e) {
      return Left('Error: $e');
    }
  }

  /// POST Multipart (untuk upload file)
  static Future<Either<String, Map<String, dynamic>>> postMultipart(
    String url, {
    Map<String, String>? fields,
    File? file,
    String fileField = 'image',
  }) async {
    try {
      final headers = await _getHeaders(isMultipart: true);
      final request = http.MultipartRequest('POST', Uri.parse(url));
      request.headers.addAll(headers);

      if (fields != null) {
        request.fields.addAll(fields);
      }

      if (file != null) {
        request.files.add(
          await http.MultipartFile.fromPath(fileField, file.path),
        );
      }

      final streamedResponse = await request.send().timeout(
        const Duration(seconds: 60),
      );
      final response = await http.Response.fromStream(streamedResponse);

      return _handleResponse(response);
    } on SocketException {
      return const Left('Tidak ada koneksi internet');
    } on HttpException {
      return const Left('Terjadi kesalahan pada server');
    } catch (e) {
      return Left('Error: $e');
    }
  }

  /// PUT Request
  static Future<Either<String, Map<String, dynamic>>> put(
    String url, {
    Map<String, dynamic>? body,
  }) async {
    try {
      final headers = await _getHeaders();
      final response = await http
          .put(
            Uri.parse(url),
            headers: headers,
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(const Duration(seconds: 30));

      return _handleResponse(response);
    } on SocketException {
      return const Left('Tidak ada koneksi internet');
    } on HttpException {
      return const Left('Terjadi kesalahan pada server');
    } catch (e) {
      return Left('Error: $e');
    }
  }

  /// DELETE Request
  static Future<Either<String, Map<String, dynamic>>> delete(String url) async {
    try {
      final headers = await _getHeaders();
      final response = await http
          .delete(Uri.parse(url), headers: headers)
          .timeout(const Duration(seconds: 30));

      return _handleResponse(response);
    } on SocketException {
      return const Left('Tidak ada koneksi internet');
    } on HttpException {
      return const Left('Terjadi kesalahan pada server');
    } catch (e) {
      return Left('Error: $e');
    }
  }

  // ═══════════════════════════════════════════════════════════════
  // RESPONSE HANDLER
  // ═══════════════════════════════════════════════════════════════

  static Either<String, Map<String, dynamic>> _handleResponse(
    http.Response response,
  ) {
    try {
      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return Right(data);
      } else if (response.statusCode == 401) {
        removeToken();
        return Left(
          data['message'] ?? 'Sesi telah berakhir. Silakan login kembali.',
        );
      } else if (response.statusCode == 403) {
        return Left(data['message'] ?? 'Anda tidak memiliki akses');
      } else if (response.statusCode == 404) {
        return Left(data['message'] ?? 'Data tidak ditemukan');
      } else if (response.statusCode == 422) {
        // Validation error
        final errors = data['errors'] as Map<String, dynamic>?;
        if (errors != null && errors.isNotEmpty) {
          final firstError = errors.values.first;
          if (firstError is List && firstError.isNotEmpty) {
            return Left(firstError.first.toString());
          }
        }
        return Left(data['message'] ?? 'Validasi gagal');
      } else {
        return Left(data['message'] ?? 'Terjadi kesalahan');
      }
    } catch (e) {
      return Left('Error parsing response: $e');
    }
  }
}
