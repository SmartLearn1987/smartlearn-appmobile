import 'package:smart_learn/core/config/app_flavor.dart';

class ApiConstants {
  ApiConstants._();

  static String get baseUrl => AppFlavorConfig.apiBaseUrl;
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
}
