import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:smart_learn/core/error/failures.dart';
import 'package:smart_learn/core/usecase/usecase.dart';
import 'package:smart_learn/features/lessons/domain/entities/lesson_image.dart';
import 'package:smart_learn/features/lessons/domain/repositories/lessons_repository.dart';

@lazySingleton
class GetLessonImagesUseCase extends UseCase<List<LessonImage>, String> {
  final LessonsRepository repository;

  GetLessonImagesUseCase(this.repository);

  @override
  Future<Either<Failure, List<LessonImage>>> call(String params) =>
      repository.getLessonImages(params);
}
