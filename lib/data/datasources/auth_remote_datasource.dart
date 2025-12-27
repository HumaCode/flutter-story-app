import 'package:dartz/dartz.dart';
import '../../core/constants/variables.dart';
import '../../core/utils/api_handler.dart';
import '../models/auth_response_model.dart';
import '../models/user_model.dart';

class AuthRemoteDatasource {
  /// Register user baru
  Future<Either<String, AuthResponseModel>> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final result = await ApiHandler.post(
      Variables.register,
      body: {'name': name, 'email': email, 'password': password},
    );

    return result.fold(
      (error) {
        // Print error jika request gagal
        print('Register error: $error');
        return Left(error);
      },
      (data) {
        // Print data mentah yang diterima dari server
        print('Register raw data: $data');

        try {
          final authResponse = AuthResponseModel.fromJson(data);
          // Simpan token
          ApiHandler.saveToken(authResponse.token);
          return Right(authResponse);
        } catch (e, stack) {
          print('Register JSON parse error: $e');
          print(stack);
          return Left('Gagal parsing response register');
        }
      },
    );
  }

  /// Login user
  Future<Either<String, AuthResponseModel>> login({
    required String email,
    required String password,
  }) async {
    final result = await ApiHandler.post(
      Variables.login,
      body: {'email': email, 'password': password},
    );

    return result.fold((error) => Left(error), (data) {
      final authResponse = AuthResponseModel.fromJson(data);
      // Simpan token
      ApiHandler.saveToken(authResponse.token);
      return Right(authResponse);
    });
  }

  /// Logout user
  Future<Either<String, String>> logout() async {
    final result = await ApiHandler.post(Variables.logout);

    // Hapus token terlepas dari hasil
    await ApiHandler.removeToken();

    return result.fold(
      (error) => const Right('Logout berhasil'),
      (data) => Right(data['message'] ?? 'Logout berhasil'),
    );
  }

  /// Get profile user
  Future<Either<String, UserModel>> getProfile() async {
    final result = await ApiHandler.get(Variables.profile);

    return result.fold(
      (error) => Left(error),
      (data) => Right(UserModel.fromJson(data)),
    );
  }

  /// Cek apakah user sudah login
  Future<bool> isLoggedIn() async {
    return ApiHandler.isLoggedIn();
  }
}
