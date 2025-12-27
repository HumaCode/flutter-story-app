import 'user_model.dart';

class AuthResponseModel {
  final bool status;
  final String message;
  final UserModel user;
  final String token;

  const AuthResponseModel({
    required this.status,
    required this.message,
    required this.user,
    required this.token,
  });

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;
    return AuthResponseModel(
      status: json['status'] as bool,
      message: json['message'] as String,
      user: UserModel.fromJson(data['user'] as Map<String, dynamic>),
      token: data['token'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'data': {'user': user.toJson(), 'token': token},
    };
  }
}
