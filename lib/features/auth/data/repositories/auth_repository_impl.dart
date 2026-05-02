import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/error_utils.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_datasource.dart';
import '../datasources/auth_remote_datasource.dart';

@LazySingleton(as: AuthRepository)
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDatasource _remoteDatasource;
  final AuthLocalDatasource _localDatasource;

  const AuthRepositoryImpl(this._remoteDatasource, this._localDatasource);

  @override
  Future<Either<Failure, (UserEntity, String)>> login(
    String username,
    String password,
  ) async {
    try {
      final response = await _remoteDatasource.login({
        'username': username,
        'password': password,
      });

      await _localDatasource.saveSessionToken(response.sessionToken);
      await _localDatasource.saveRefreshToken(response.refreshToken);
      await _localDatasource.saveAccessTokenExpiresAt(
        response.accessTokenExpiresAt,
      );
      await _localDatasource.saveUserId(response.user.id);

      return Right((response.user, response.sessionToken));
    } on DioException catch (e) {
      return Left(ServerFailure(message: extractDioErrorMessage(e)));
    } catch (e) {
      return Left(ServerFailure(message: 'Đã xảy ra lỗi không xác định'));
    }
  }

  @override
  Future<Either<Failure, void>> register({
    required String username,
    required String email,
    required String password,
    String? educationLevel,
  }) async {
    try {
      await _remoteDatasource.register({
        'username': username,
        'email': email,
        'password': password,
        if (educationLevel != null) 'education_level': educationLevel,
      });

      return const Right(null);
    } on DioException catch (e) {
      return Left(ServerFailure(message: extractDioErrorMessage(e)));
    } catch (e) {
      return Left(ServerFailure(message: 'Đã xảy ra lỗi không xác định'));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await _localDatasource.clearTokens();
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> getProfile() async {
    try {
      final userModel = await _remoteDatasource.getProfile();
      return Right(userModel);
    } on DioException catch (e) {
      return Left(ServerFailure(message: extractDioErrorMessage(e)));
    } catch (e) {
      return Left(ServerFailure(message: 'Đã xảy ra lỗi không xác định'));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> updateProfile({
    String? name,
    String? username,
    String? avatarUrl,
  }) async {
    try {
      final body = <String, dynamic>{
        if (name != null) 'name': name,
        if (username != null) 'username': username,
        if (avatarUrl != null) 'avatar_url': avatarUrl,
      };

      final userModel = await _remoteDatasource.updateProfile(body);
      return Right(userModel);
    } on DioException catch (e) {
      return Left(ServerFailure(message: extractDioErrorMessage(e)));
    } catch (e) {
      return Left(ServerFailure(message: 'Đã xảy ra lỗi không xác định'));
    }
  }

  @override
  Future<Either<Failure, void>> forgotPassword(String email) async {
    try {
      await _remoteDatasource.forgotPassword({'email': email});
      return const Right(null);
    } on DioException catch (e) {
      return Left(ServerFailure(message: extractDioErrorMessage(e)));
    } catch (e) {
      return Left(ServerFailure(message: 'Đã xảy ra lỗi không xác định'));
    }
  }

  @override
  Future<Either<Failure, void>> changePassword(
    String userId,
    String newPassword,
  ) async {
    try {
      await _remoteDatasource.changePassword(userId, {
        'new_password': newPassword,
      });
      return const Right(null);
    } on DioException catch (e) {
      return Left(ServerFailure(message: extractDioErrorMessage(e)));
    } catch (e) {
      return Left(ServerFailure(message: 'Đã xảy ra lỗi không xác định'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteAccount({
    required String userId,
    required String reason,
  }) async {
    try {
      await _remoteDatasource.deleteAccount(userId, {'reason': reason});
      await _localDatasource.clearTokens();
      return const Right(null);
    } on DioException catch (e) {
      return Left(ServerFailure(message: extractDioErrorMessage(e)));
    } catch (e) {
      return Left(ServerFailure(message: 'Đã xảy ra lỗi không xác định'));
    }
  }

  @override
  Future<Either<Failure, String>> uploadFile(File file) async {
    try {
      final url = await _remoteDatasource.uploadFile(file);
      return Right(url);
    } on DioException catch (e) {
      return Left(ServerFailure(message: extractDioErrorMessage(e)));
    } catch (e) {
      return Left(ServerFailure(message: 'Đã xảy ra lỗi không xác định'));
    }
  }

}
