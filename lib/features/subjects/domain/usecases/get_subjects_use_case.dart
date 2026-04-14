import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:smart_learn/core/error/failures.dart';
import 'package:smart_learn/core/usecase/usecase.dart';
import 'package:smart_learn/features/home/domain/entities/subject_entity.dart';
import 'package:smart_learn/features/subjects/domain/repositories/subjects_repository.dart';

@lazySingleton
class GetSubjectsUseCase extends UseCase<List<SubjectEntity>, NoParams> {
  final SubjectsRepository repository;

  GetSubjectsUseCase(this.repository);

  @override
  Future<Either<Failure, List<SubjectEntity>>> call(NoParams params) =>
      repository.getSubjects();
}
