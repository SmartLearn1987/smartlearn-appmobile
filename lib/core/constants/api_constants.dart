class ApiConstants {
  ApiConstants._();

  static const String baseUrl =
      'https://smart-learn-rlw-production.up.railway.app/api';
  static const String baseImageUrl =
      'https://smart-learn-rlw-production.up.railway.app';
  static const String baseApiKey =
      'smart-learn-secret-key-VYWgmEI3UTFUSeCaylYhtKQMHxjVooKQ';
  static const Duration connectTimeout = Duration(minutes: 5);
  static const Duration receiveTimeout = Duration(minutes: 5);

  /// Trả về URL đầy đủ cho ảnh từ API.
  /// Nếu path đã là URL đầy đủ (http/https), trả về nguyên.
  /// Nếu là path tương đối (ví dụ `/uploads/abc.jpg`), thêm baseImageUrl.
  static String fullImageUrl(String path) {
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return path;
    }
    return '$baseImageUrl$path';
  }
}
