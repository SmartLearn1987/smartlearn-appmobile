import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:smart_learn/core/error/failures.dart';
import 'package:smart_learn/core/usecase/usecase.dart';
import 'package:smart_learn/features/lessons/domain/entities/lesson_entity.dart';
import 'package:smart_learn/features/lessons/domain/repositories/lessons_repository.dart';

@lazySingleton
class GetLessonsUseCase extends UseCase<List<LessonEntity>, String> {
  final LessonsRepository repository;

  GetLessonsUseCase(this.repository);

  @override
  Future<Either<Failure, List<LessonEntity>>> call(String params) =>
      repository.getLessons(params);
}
