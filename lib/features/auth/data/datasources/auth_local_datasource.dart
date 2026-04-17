import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';

import 'package:smart_learn/core/error/exceptions.dart';

const _sessionTokenKey = 'session_token';
const _refreshTokenKey = 'refresh_token';
const _accessTokenExpiresAtKey = 'access_token_expires_at';
const _userIdKey = 'user_id';

@lazySingleton
class AuthLocalDatasource {
  final FlutterSecureStorage _storage;

  const AuthLocalDatasource(this._storage);

  Future<void> saveSessionToken(String token) async {
    try {
      await _storage.write(key: _sessionTokenKey, value: token);
    } catch (e) {
      throw CacheException(message: 'Failed to save session token: $e');
    }
  }

  Future<String?> getSessionToken() async {
    try {
      return await _storage.read(key: _sessionTokenKey);
    } catch (e) {
      throw CacheException(message: 'Failed to read session token: $e');
    }
  }

  Future<void> saveUserId(String userId) async {
    try {
      await _storage.write(key: _userIdKey, value: userId);
    } catch (e) {
      throw CacheException(message: 'Failed to save user id: $e');
    }
  }

  Future<String?> getUserId() async {
    try {
      return await _storage.read(key: _userIdKey);
    } catch (e) {
      throw CacheException(message: 'Failed to read user id: $e');
    }
  }

  Future<void> saveRefreshToken(String token) async {
    try {
      await _storage.write(key: _refreshTokenKey, value: token);
    } catch (e) {
      throw CacheException(message: 'Failed to save refresh token: $e');
    }
  }

  Future<String?> getRefreshToken() async {
    try {
      return await _storage.read(key: _refreshTokenKey);
    } catch (e) {
      throw CacheException(message: 'Failed to read refresh token: $e');
    }
  }

  Future<void> saveAccessTokenExpiresAt(String expiresAt) async {
    try {
      await _storage.write(key: _accessTokenExpiresAtKey, value: expiresAt);
    } catch (e) {
      throw CacheException(
        message: 'Failed to save access token expires at: $e',
      );
    }
  }

  Future<String?> getAccessTokenExpiresAt() async {
    try {
      return await _storage.read(key: _accessTokenExpiresAtKey);
    } catch (e) {
      throw CacheException(
        message: 'Failed to read access token expires at: $e',
      );
    }
  }

  Future<void> clearTokens() async {
    try {
      await _storage.delete(key: _sessionTokenKey);
      await _storage.delete(key: _refreshTokenKey);
      await _storage.delete(key: _accessTokenExpiresAtKey);
      await _storage.delete(key: _userIdKey);
    } catch (e) {
      throw CacheException(message: 'Failed to clear session data: $e');
    }
  }

  Future<bool> hasTokens() async {
    try {
      final token = await _storage.read(key: _sessionTokenKey);
      return token != null;
    } catch (e) {
      throw CacheException(message: 'Failed to check session token: $e');
    }
  }
}
