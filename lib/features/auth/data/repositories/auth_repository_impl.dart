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
        'education_level': ?educationLevel,
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
    required String userId,
    String? displayName,
    String? email,
    String? avatarUrl,
    required String role,
    required bool isActive,
    String? educationLevel,
    String? plan,
    DateTime? planStartDate,
    DateTime? planEndDate,
  }) async {
    try {
      // Mirrors `smartlearn/src/lib/auth.ts` `updateUser` JSON body.
      final body = <String, dynamic>{
        'display_name': ?displayName,
        'role': role,
        'email': ?email,
        'education_level': ?educationLevel,
        'avatar_url': ?avatarUrl,
        'is_active': isActive,
        'plan': ?plan,
        if (planStartDate != null)
          'plan_start_date': planStartDate.toUtc().toIso8601String(),
        if (planEndDate != null)
          'plan_end_date': planEndDate.toUtc().toIso8601String(),
      };

      final userModel = await _remoteDatasource.updateUser(userId, body);
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
      await _remoteDatasource.changePassword(userId, {'password': newPassword});
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
      final res = await _remoteDatasource.uploadFile(file);
      return Right(res.url);
    } on DioException catch (e) {
      return Left(ServerFailure(message: extractDioErrorMessage(e)));
    } catch (e) {
      return Left(ServerFailure(message: 'Đã xảy ra lỗi không xác định'));
    }
  }
}
