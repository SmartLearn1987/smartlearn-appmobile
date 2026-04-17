import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';

import 'package:smart_learn/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:smart_learn/features/auth/presentation/bloc/auth_bloc.dart';

@injectable
class AuthInterceptor extends QueuedInterceptor {
  final AuthLocalDatasource _localDatasource;
  final Dio _refreshDio;

  /// [AuthBloc] is resolved lazily via GetIt to break the circular dependency:
  /// AuthInterceptor → AuthBloc → UseCases → Dio → AuthInterceptor.
  AuthBloc get _authBloc => GetIt.instance<AuthBloc>();

  AuthInterceptor(
    this._localDatasource,
    @Named('refreshDio') this._refreshDio,
  );

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
    if (err.response?.statusCode == 401 && _isTokenExpiredError(err)) {
      try {
        await _refreshTokens();

        // Retry the original request with new tokens
        final newToken = await _localDatasource.getSessionToken();
        final userId = await _localDatasource.getUserId();
        err.requestOptions.headers['x-session-token'] = newToken;
        err.requestOptions.headers['x-user-id'] = userId;

        final response = await _refreshDio.fetch(err.requestOptions);
        handler.resolve(response);
        return;
      } catch (_) {
        // Refresh failed → force logout
        await _localDatasource.clearTokens();
        _authBloc.add(const AuthForceLogout());
        handler.reject(err);
        return;
      }
    }

    handler.next(err);
  }

  bool _isTokenExpiredError(DioException err) {
    final data = err.response?.data;
    return data is Map<String, dynamic> && data['error'] == 'TOKEN_EXPIRED';
  }

  Future<void> _refreshTokens() async {
    final refreshToken = await _localDatasource.getRefreshToken();
    final userId = await _localDatasource.getUserId();

    if (refreshToken == null || userId == null) {
      throw Exception('No refresh token or userId available');
    }

    final response = await _refreshDio.post(
      '/refresh-token',
      data: {
        'userId': userId,
        'refreshToken': refreshToken,
      },
    );

    final newSessionToken = response.data['sessionToken'] as String;
    final newRefreshToken = response.data['refreshToken'] as String;
    final newExpiresAt = response.data['accessTokenExpiresAt'] as String;

    await _localDatasource.saveSessionToken(newSessionToken);
    await _localDatasource.saveRefreshToken(newRefreshToken);
    await _localDatasource.saveAccessTokenExpiresAt(newExpiresAt);
  }
}
