class Variables {
  // Ganti dengan IP address komputer kamu
  // Untuk Android Emulator: 10.0.2.2
  // Untuk iOS Simulator: localhost
  // Untuk Device fisik: IP address komputer (misal: 192.168.1.100)
  static const String baseUrl = 'http://192.168.1.4:8000';

  static const String baseUrlApi = '$baseUrl/api';

  // Auth endpoints
  static const String register = '$baseUrlApi/register';
  static const String login = '$baseUrlApi/login';
  static const String logout = '$baseUrlApi/logout';
  static const String profile = '$baseUrlApi/profile';

  // Story endpoints
  static const String stories = '$baseUrlApi/stories';
  static const String myStories = '$baseUrlApi/my-stories';

  static String storyById(int id) => '$baseUrlApi/stories/$id';
}
