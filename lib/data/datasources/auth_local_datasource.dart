import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/auth_response_model.dart';
import '../models/user_model.dart';

class AuthLocalDatasource {
  static const String _authKey = 'auth_data';
  static const String _userKey = 'user_data';

  /// Simpan data auth (user + token)
  Future<void> saveAuth(AuthResponseModel auth) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_authKey, jsonEncode(auth.toJson()));
  }

  /// Ambil data auth
  Future<AuthResponseModel?> getAuth() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_authKey);
    if (data != null) {
      return AuthResponseModel.fromJson(jsonDecode(data));
    }
    return null;
  }

  /// Simpan data user saja
  Future<void> saveUser(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, jsonEncode(user.toJson()));
  }

  /// Ambil data user
  Future<UserModel?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_userKey);
    if (data != null) {
      return UserModel.fromJson(jsonDecode(data));
    }
    return null;
  }

  /// Hapus semua data auth
  Future<void> clearAuth() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_authKey);
    await prefs.remove(_userKey);
  }

  /// Cek apakah user sudah login
  Future<bool> isLoggedIn() async {
    final auth = await getAuth();
    return auth != null;
  }
}
