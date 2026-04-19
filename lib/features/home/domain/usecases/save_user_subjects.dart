import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:smart_learn/core/error/failures.dart';
import 'package:smart_learn/core/usecase/usecase.dart';
import 'package:smart_learn/features/home/domain/repositories/home_repository.dart';

class SaveUserSubjectsParams extends Equatable {
  final List<String> subjectIds;

  const SaveUserSubjectsParams({required this.subjectIds});

  @override
  List<Object?> get props => [subjectIds];
}

@lazySingleton
class SaveUserSubjectsUseCase extends UseCase<void, SaveUserSubjectsParams> {
  final HomeRepository repository;

  SaveUserSubjectsUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(SaveUserSubjectsParams params) {
    return repository.saveUserSubjects(params.subjectIds);
  }
}
