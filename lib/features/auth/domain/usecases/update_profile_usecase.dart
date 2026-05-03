import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:smart_learn/core/error/failures.dart';
import 'package:smart_learn/core/usecase/usecase.dart';
import 'package:smart_learn/features/auth/domain/entities/user_entity.dart';
import 'package:smart_learn/features/auth/domain/repositories/auth_repository.dart';

@injectable
class UpdateProfileUseCase extends UseCase<UserEntity, UpdateProfileParams> {
  final AuthRepository _repository;

  UpdateProfileUseCase(this._repository);

  @override
  Future<Either<Failure, UserEntity>> call(UpdateProfileParams params) =>
      _repository.updateProfile(
        userId: params.userId,
        displayName: params.displayName,
        email: params.email,
        avatarUrl: params.avatarUrl,
        role: params.role,
        isActive: params.isActive,
        educationLevel: params.educationLevel,
        plan: params.plan,
        planStartDate: params.planStartDate,
        planEndDate: params.planEndDate,
      );
}

class UpdateProfileParams extends Equatable {
  final String userId;
  final String? displayName;
  final String? email;
  final String? avatarUrl;
  final String role;
  final bool isActive;
  final String? educationLevel;
  final String? plan;
  final DateTime? planStartDate;
  final DateTime? planEndDate;

  const UpdateProfileParams({
    required this.userId,
    this.displayName,
    this.email,
    this.avatarUrl,
    required this.role,
    required this.isActive,
    this.educationLevel,
    this.plan,
    this.planStartDate,
    this.planEndDate,
  });

  @override
  List<Object?> get props => [
        userId,
        displayName,
        email,
        avatarUrl,
        role,
        isActive,
        educationLevel,
        plan,
        planStartDate,
        planEndDate,
      ];
}
