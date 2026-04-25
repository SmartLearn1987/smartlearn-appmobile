import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:smart_learn/core/error/failures.dart';
import 'package:smart_learn/core/usecase/usecase.dart';
import 'package:smart_learn/features/quizlet/domain/repositories/quizlet_repository.dart';
import 'package:smart_learn/features/quizlet/domain/usecases/params/update_quizlet_params.dart';

@lazySingleton
class UpdateQuizletUseCase extends UseCase<void, UpdateQuizletParams> {
  final QuizletRepository repository;

  UpdateQuizletUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(UpdateQuizletParams params) =>
      repository.updateQuizlet(params);
}
