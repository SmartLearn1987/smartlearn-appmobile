import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:smart_learn/core/error/failures.dart';
import 'package:smart_learn/core/usecase/usecase.dart';
import 'package:smart_learn/features/lessons/domain/entities/lesson_entity.dart';
import 'package:smart_learn/features/lessons/domain/repositories/lessons_repository.dart';
import 'package:smart_learn/features/lessons/domain/usecases/params/create_lesson_params.dart';

@lazySingleton
class CreateLessonUseCase extends UseCase<LessonEntity, CreateLessonParams> {
  final LessonsRepository repository;

  CreateLessonUseCase(this.repository);

  @override
  Future<Either<Failure, LessonEntity>> call(CreateLessonParams params) =>
      repository.createLesson(params.data);
}
