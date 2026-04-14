import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:smart_learn/core/error/failures.dart';
import 'package:smart_learn/core/usecase/usecase.dart';
import 'package:smart_learn/features/subjects/domain/entities/curriculum_entity.dart';
import 'package:smart_learn/features/subjects/domain/repositories/subjects_repository.dart';

@lazySingleton
class GetCurriculaBySubjectUseCase
    extends UseCase<List<CurriculumEntity>, String> {
  final SubjectsRepository repository;

  GetCurriculaBySubjectUseCase(this.repository);

  @override
  Future<Either<Failure, List<CurriculumEntity>>> call(String params) =>
      repository.getCurriculaBySubject(params);
}
