class Variables {
  // Ganti dengan IP address komputer kamu
  // Untuk Android Emulator: 10.0.2.2
  // Untuk iOS Simulator: localhost
  // Untuk Device fisik: IP address komputer (misal: 192.168.1.100)
  static const String baseUrl = 'http://192.168.1.4:8000/api/';

  // Auth endpoints
  static const String register = '$baseUrl/register';
  static const String login = '$baseUrl/login';
  static const String logout = '$baseUrl/logout';
  static const String profile = '$baseUrl/profile';

  // Story endpoints
  static const String stories = '$baseUrl/stories';
  static const String myStories = '$baseUrl/my-stories';

  static String storyById(int id) => '$baseUrl/stories/$id';
}
