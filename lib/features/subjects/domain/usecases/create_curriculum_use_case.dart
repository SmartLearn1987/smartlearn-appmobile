import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:smart_learn/core/error/failures.dart';
import 'package:smart_learn/core/usecase/usecase.dart';
import 'package:smart_learn/features/subjects/domain/entities/curriculum_entity.dart';
import 'package:smart_learn/features/subjects/domain/repositories/subjects_repository.dart';
import 'package:smart_learn/features/subjects/domain/usecases/params/create_curriculum_params.dart';

@lazySingleton
class CreateCurriculumUseCase
    extends UseCase<CurriculumEntity, CreateCurriculumParams> {
  final SubjectsRepository repository;

  CreateCurriculumUseCase(this.repository);

  @override
  Future<Either<Failure, CurriculumEntity>> call(
    CreateCurriculumParams params,
  ) =>
      repository.createCurriculum(params);
}
