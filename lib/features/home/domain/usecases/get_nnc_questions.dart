import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:smart_learn/core/error/failures.dart';
import 'package:smart_learn/core/usecase/usecase.dart';
import 'package:smart_learn/features/home/domain/entities/nnc_question_entity.dart';
import 'package:smart_learn/features/home/domain/repositories/home_repository.dart';

class NNCParams extends Equatable {
  final String? level;
  final int? limit;

  const NNCParams({this.level, this.limit});

  @override
  List<Object?> get props => [level, limit];
}

@lazySingleton
class GetNNCQuestionsUseCase
    extends UseCase<List<NNCQuestionEntity>, NNCParams> {
  final HomeRepository repository;

  GetNNCQuestionsUseCase(this.repository);

  @override
  Future<Either<Failure, List<NNCQuestionEntity>>> call(
    NNCParams params,
  ) {
    return repository.getNNCQuestions(
      level: params.level,
      limit: params.limit,
    );
  }
}
