import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:smart_learn/core/error/failures.dart';
import 'package:smart_learn/core/usecase/usecase.dart';
import 'package:smart_learn/features/auth/domain/repositories/auth_repository.dart';

@injectable
class RegisterUseCase extends UseCase<void, RegisterParams> {
  final AuthRepository _repository;

  RegisterUseCase(this._repository);

  @override
  Future<Either<Failure, void>> call(RegisterParams params) =>
      _repository.register(
        username: params.username,
        email: params.email,
        password: params.password,
        educationLevel: params.educationLevel,
      );
}

class RegisterParams extends Equatable {
  final String username;
  final String email;
  final String password;
  final String? educationLevel;

  const RegisterParams({
    required this.username,
    required this.email,
    required this.password,
    this.educationLevel,
  });

  @override
  List<Object?> get props => [username, email, password, educationLevel];
}
