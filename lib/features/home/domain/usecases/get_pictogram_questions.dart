import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:smart_learn/core/error/failures.dart';
import 'package:smart_learn/core/usecase/usecase.dart';
import 'package:smart_learn/features/home/domain/entities/pictogram_entity.dart';
import 'package:smart_learn/features/home/domain/repositories/home_repository.dart';

class PictogramParams extends Equatable {
  final String? level;
  final int? limit;

  const PictogramParams({this.level, this.limit});

  @override
  List<Object?> get props => [level, limit];
}

@lazySingleton
class GetPictogramQuestionsUseCase
    extends UseCase<List<PictogramEntity>, PictogramParams> {
  final HomeRepository repository;

  GetPictogramQuestionsUseCase(this.repository);

  @override
  Future<Either<Failure, List<PictogramEntity>>> call(
    PictogramParams params,
  ) {
    return repository.getPictogramQuestions(
      level: params.level,
      limit: params.limit,
    );
  }
}
