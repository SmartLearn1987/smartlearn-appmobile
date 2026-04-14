import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:smart_learn/core/error/failures.dart';
import 'package:smart_learn/core/usecase/usecase.dart';
import 'package:smart_learn/features/subjects/domain/entities/curriculum_entity.dart';
import 'package:smart_learn/features/subjects/domain/repositories/subjects_repository.dart';
import 'package:smart_learn/features/subjects/domain/usecases/params/update_curriculum_params.dart';

@lazySingleton
class UpdateCurriculumUseCase
    extends UseCase<CurriculumEntity, UpdateCurriculumParams> {
  final SubjectsRepository repository;

  UpdateCurriculumUseCase(this.repository);

  @override
  Future<Either<Failure, CurriculumEntity>> call(
    UpdateCurriculumParams params,
  ) =>
      repository.updateCurriculum(params);
}
