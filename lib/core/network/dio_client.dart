import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:logger/logger.dart';

import 'package:smart_learn/core/constants/api_constants.dart';
import 'package:smart_learn/core/network/auth_interceptor.dart';

@module
abstract class DioModule {
  @lazySingleton
  Dio dio(AuthInterceptor authInterceptor) {
    final dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: ApiConstants.connectTimeout,
        receiveTimeout: ApiConstants.receiveTimeout,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'x-api-key': ApiConstants.baseApiKey,
        },
      ),
    );

    dio.interceptors.add(authInterceptor);

    dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
      ),
    );

    return dio;
  }

  /// Dio instance riêng cho refresh token.
  /// KHÔNG có AuthInterceptor để tránh vòng lặp vô hạn khi gọi /refresh-token.
  @Named('refreshDio')
  @lazySingleton
  Dio refreshDio() {
    return Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        headers: {
          'Content-Type': 'application/json',
          'x-api-key': ApiConstants.baseApiKey,
        },
      ),
    );
  }
}
