import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';

import 'package:smart_learn/core/error/exceptions.dart';

const _sessionTokenKey = 'session_token';
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

  Future<void> clearTokens() async {
    try {
      await _storage.delete(key: _sessionTokenKey);
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
