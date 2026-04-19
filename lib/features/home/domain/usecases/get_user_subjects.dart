import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:smart_learn/core/error/failures.dart';
import 'package:smart_learn/core/usecase/usecase.dart';
import 'package:smart_learn/features/home/domain/entities/subject_entity.dart';
import 'package:smart_learn/features/home/domain/repositories/home_repository.dart';

@lazySingleton
class GetUserSubjectsUseCase extends UseCase<List<SubjectEntity>, NoParams> {
  final HomeRepository repository;

  GetUserSubjectsUseCase(this.repository);

  @override
  Future<Either<Failure, List<SubjectEntity>>> call(NoParams params) {
    return repository.getUserSubjects();
  }
}
