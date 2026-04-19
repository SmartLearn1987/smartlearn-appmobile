import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:smart_learn/core/error/failures.dart';
import 'package:smart_learn/core/usecase/usecase.dart';
import 'package:smart_learn/features/home/domain/entities/vtv_question_entity.dart';
import 'package:smart_learn/features/home/domain/repositories/home_repository.dart';

class VTVParams extends Equatable {
  final String? level;
  final int? limit;

  const VTVParams({this.level, this.limit});

  @override
  List<Object?> get props => [level, limit];
}

@lazySingleton
class GetVTVQuestionsUseCase
    extends UseCase<List<VTVQuestionEntity>, VTVParams> {
  final HomeRepository repository;

  GetVTVQuestionsUseCase(this.repository);

  @override
  Future<Either<Failure, List<VTVQuestionEntity>>> call(
    VTVParams params,
  ) {
    return repository.getVTVQuestions(
      level: params.level,
      limit: params.limit,
    );
  }
}
