import 'package:dio/dio.dart';

import 'error_messages.dart';

/// Trích xuất error message từ [DioException] theo format API: `{"error": "..."}`.
///
/// Tự động dịch sang tiếng Việt nếu có bản dịch trong [error_messages.dart].
/// Fallback: `response.data['message']` → message mặc định.
String extractDioErrorMessage(DioException e) {
  // Network error — không có response
  if (e.type == DioExceptionType.connectionTimeout ||
      e.type == DioExceptionType.sendTimeout ||
      e.type == DioExceptionType.receiveTimeout) {
    return 'Yêu cầu đã hết thời gian chờ';
  }

  if (e.type == DioExceptionType.connectionError) {
    return 'Không thể kết nối đến máy chủ';
  }

  final data = e.response?.data;
  if (data is Map<String, dynamic>) {
    final error = data['error'];
    if (error is String && error.isNotEmpty) {
      return translateErrorMessage(error);
    }
    final message = data['message'];
    if (message is String && message.isNotEmpty) {
      return translateErrorMessage(message);
    }
  }

  return 'Đã xảy ra lỗi không xác định';
}
