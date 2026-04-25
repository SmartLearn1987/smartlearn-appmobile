import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:smart_learn/core/error/failures.dart';
import 'package:smart_learn/core/usecase/usecase.dart';
import 'package:smart_learn/features/quizlet/domain/repositories/quizlet_repository.dart';
import 'package:smart_learn/features/quizlet/domain/usecases/params/create_quizlet_params.dart';

@lazySingleton
class CreateQuizletUseCase extends UseCase<void, CreateQuizletParams> {
  final QuizletRepository repository;

  CreateQuizletUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(CreateQuizletParams params) =>
      repository.createQuizlet(params);
}
