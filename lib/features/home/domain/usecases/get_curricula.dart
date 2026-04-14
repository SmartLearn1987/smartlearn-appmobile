import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:smart_learn/core/error/failures.dart';
import 'package:smart_learn/core/usecase/usecase.dart';
import 'package:smart_learn/features/home/domain/entities/curriculum_entity.dart';
import 'package:smart_learn/features/home/domain/repositories/home_repository.dart';

@lazySingleton
class GetCurriculaUseCase extends UseCase<List<CurriculumEntity>, NoParams> {
  final HomeRepository repository;

  GetCurriculaUseCase(this.repository);

  @override
  Future<Either<Failure, List<CurriculumEntity>>> call(NoParams params) {
    return repository.getCurricula();
  }
}
