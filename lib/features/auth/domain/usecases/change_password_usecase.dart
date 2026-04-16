import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:smart_learn/core/error/failures.dart';
import 'package:smart_learn/core/usecase/usecase.dart';
import 'package:smart_learn/features/auth/domain/repositories/auth_repository.dart';

@injectable
class ChangePasswordUseCase extends UseCase<void, ChangePasswordParams> {
  final AuthRepository _repository;

  ChangePasswordUseCase(this._repository);

  @override
  Future<Either<Failure, void>> call(ChangePasswordParams params) =>
      _repository.changePassword(params.userId, params.newPassword);
}

class ChangePasswordParams extends Equatable {
  final String userId;
  final String newPassword;

  const ChangePasswordParams({
    required this.userId,
    required this.newPassword,
  });

  @override
  List<Object?> get props => [userId, newPassword];
}
