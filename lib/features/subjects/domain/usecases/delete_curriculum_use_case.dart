import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:smart_learn/core/error/failures.dart';
import 'package:smart_learn/core/usecase/usecase.dart';
import 'package:smart_learn/features/subjects/domain/repositories/subjects_repository.dart';

@lazySingleton
class DeleteCurriculumUseCase extends UseCase<void, String> {
  final SubjectsRepository repository;

  DeleteCurriculumUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(String params) =>
      repository.deleteCurriculum(params);
}
