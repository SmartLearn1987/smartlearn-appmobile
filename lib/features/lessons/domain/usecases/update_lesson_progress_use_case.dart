import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:smart_learn/core/error/failures.dart';
import 'package:smart_learn/core/usecase/usecase.dart';
import 'package:smart_learn/features/lessons/domain/entities/lesson_progress.dart';
import 'package:smart_learn/features/lessons/domain/repositories/lessons_repository.dart';
import 'package:smart_learn/features/lessons/domain/usecases/params/update_progress_params.dart';

@lazySingleton
class UpdateLessonProgressUseCase
    extends UseCase<LessonProgress, UpdateProgressParams> {
  final LessonsRepository repository;

  UpdateLessonProgressUseCase(this.repository);

  @override
  Future<Either<Failure, LessonProgress>> call(
    UpdateProgressParams params,
  ) =>
      repository.updateProgress(params.lessonId, params.data);
}
