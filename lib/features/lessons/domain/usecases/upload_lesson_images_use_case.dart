import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:smart_learn/core/error/failures.dart';
import 'package:smart_learn/core/usecase/usecase.dart';
import 'package:smart_learn/features/lessons/domain/entities/lesson_image.dart';
import 'package:smart_learn/features/lessons/domain/repositories/lessons_repository.dart';
import 'package:smart_learn/features/lessons/domain/usecases/params/upload_images_params.dart';

@lazySingleton
class UploadLessonImagesUseCase
    extends UseCase<List<LessonImage>, UploadImagesParams> {
  final LessonsRepository repository;

  UploadLessonImagesUseCase(this.repository);

  @override
  Future<Either<Failure, List<LessonImage>>> call(
    UploadImagesParams params,
  ) =>
      repository.uploadImages(params.lessonId, params.images);
}
