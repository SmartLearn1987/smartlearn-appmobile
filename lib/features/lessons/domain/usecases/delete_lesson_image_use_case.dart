import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:smart_learn/core/error/failures.dart';
import 'package:smart_learn/core/usecase/usecase.dart';
import 'package:smart_learn/features/lessons/domain/repositories/lessons_repository.dart';
import 'package:smart_learn/features/lessons/domain/usecases/params/delete_image_params.dart';

@lazySingleton
class DeleteLessonImageUseCase extends UseCase<void, DeleteImageParams> {
  final LessonsRepository repository;

  DeleteLessonImageUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(DeleteImageParams params) =>
      repository.deleteImage(params.lessonId, params.imageId);
}
