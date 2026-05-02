import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:smart_learn/core/error/failures.dart';
import 'package:smart_learn/core/usecase/usecase.dart';
import 'package:smart_learn/features/auth/domain/repositories/auth_repository.dart';

@injectable
class DeleteAccountUseCase extends UseCase<void, DeleteAccountParams> {
  final AuthRepository _repository;

  DeleteAccountUseCase(this._repository);

  @override
  Future<Either<Failure, void>> call(DeleteAccountParams params) =>
      _repository.deleteAccount(
        userId: params.userId,
        reason: params.reason,
      );
}

class DeleteAccountParams extends Equatable {
  final String userId;
  final String reason;

  const DeleteAccountParams({
    required this.userId,
    required this.reason,
  });

  @override
  List<Object?> get props => [userId, reason];
}
