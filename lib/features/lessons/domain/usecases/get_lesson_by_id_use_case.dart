import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:smart_learn/core/error/failures.dart';
import 'package:smart_learn/core/usecase/usecase.dart';
import 'package:smart_learn/features/lessons/domain/entities/lesson_entity.dart';
import 'package:smart_learn/features/lessons/domain/repositories/lessons_repository.dart';

@lazySingleton
class GetLessonByIdUseCase extends UseCase<LessonEntity, String> {
  final LessonsRepository repository;

  GetLessonByIdUseCase(this.repository);

  @override
  Future<Either<Failure, LessonEntity>> call(String params) =>
      repository.getLessonById(params);
}
