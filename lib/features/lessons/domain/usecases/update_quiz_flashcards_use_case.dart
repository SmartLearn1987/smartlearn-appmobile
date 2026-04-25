import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:smart_learn/core/error/failures.dart';
import 'package:smart_learn/core/usecase/usecase.dart';
import 'package:smart_learn/features/lessons/domain/repositories/lessons_repository.dart';
import 'package:smart_learn/features/lessons/domain/usecases/params/update_quiz_flashcards_params.dart';

@lazySingleton
class UpdateQuizFlashcardsUseCase
    extends UseCase<void, UpdateQuizFlashcardsParams> {
  final LessonsRepository repository;

  UpdateQuizFlashcardsUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(UpdateQuizFlashcardsParams params) =>
      repository.updateQuizFlashcards(params.lessonId, params.data);
}
