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
        username: params.username,
        avatarUrl: params.avatarUrl,
      );
}

class UpdateProfileParams extends Equatable {
  final String? name;
  final String? username;
  final String? avatarUrl;

  const UpdateProfileParams({this.name, this.username, this.avatarUrl});

  @override
  List<Object?> get props => [name, username, avatarUrl];
}
