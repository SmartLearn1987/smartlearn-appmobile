import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:smart_learn/core/error/failures.dart';
import 'package:smart_learn/core/usecase/usecase.dart';
import 'package:smart_learn/features/auth/domain/entities/user_entity.dart';
import 'package:smart_learn/features/auth/domain/repositories/auth_repository.dart';

@injectable
class GetProfileUseCase extends UseCase<UserEntity, NoParams> {
  final AuthRepository _repository;

  GetProfileUseCase(this._repository);

  @override
  Future<Either<Failure, UserEntity>> call(NoParams params) =>
      _repository.getProfile();
}
