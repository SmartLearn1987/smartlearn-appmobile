import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import 'package:smart_learn/features/auth/data/datasources/auth_local_datasource.dart';

@injectable
class AuthInterceptor extends QueuedInterceptor {
  final AuthLocalDatasource _localDatasource;

  AuthInterceptor(this._localDatasource);

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final sessionToken = await _localDatasource.getSessionToken();
    final userId = await _localDatasource.getUserId();

    if (sessionToken != null) {
      options.headers['x-session-token'] = sessionToken;
    }
    if (userId != null) {
      options.headers['x-user-id'] = userId;
    }

    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      // Session expired — clear stored data.
      await _localDatasource.clearTokens();
    }
    handler.next(err);
  }
}
