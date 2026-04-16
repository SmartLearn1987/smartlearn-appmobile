import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:smart_learn/core/error/failures.dart';
import 'package:smart_learn/features/auth/domain/entities/user_entity.dart';

abstract class AuthRepository {
  Future<Either<Failure, (UserEntity, String)>> login(
    String username,
    String password,
  );

  Future<Either<Failure, void>> register({
    required String username,
    required String email,
    required String password,
    String? educationLevel,
  });

  Future<Either<Failure, void>> logout();

  Future<Either<Failure, UserEntity>> getProfile();

  Future<Either<Failure, UserEntity>> updateProfile({
    String? name,
    String? username,
    String? avatarUrl,
  });

  Future<Either<Failure, void>> forgotPassword(String email);

  Future<Either<Failure, void>> changePassword(
    String userId,
    String newPassword,
  );

  Future<Either<Failure, String>> uploadFile(File file);
}
