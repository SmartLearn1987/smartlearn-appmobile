class ApiConstants {
  ApiConstants._();

  static const String baseUrl =
      'https://hopeful-connection-production.up.railway.app/api';
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
}
