import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:smart_learn/core/error/failures.dart';
import 'package:smart_learn/core/usecase/usecase.dart';
import 'package:smart_learn/features/lessons/domain/repositories/lessons_repository.dart';

@lazySingleton
class DeleteLessonUseCase extends UseCase<void, String> {
  final LessonsRepository repository;

  DeleteLessonUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(String params) =>
      repository.deleteLesson(params);
}
