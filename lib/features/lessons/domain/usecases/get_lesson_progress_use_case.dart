import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:smart_learn/core/error/failures.dart';
import 'package:smart_learn/core/usecase/usecase.dart';
import 'package:smart_learn/features/lessons/domain/entities/lesson_progress.dart';
import 'package:smart_learn/features/lessons/domain/repositories/lessons_repository.dart';

@lazySingleton
class GetLessonProgressUseCase extends UseCase<List<LessonProgress>, String> {
  final LessonsRepository repository;

  GetLessonProgressUseCase(this.repository);

  @override
  Future<Either<Failure, List<LessonProgress>>> call(String params) =>
      repository.getProgress(params);
}
