import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:smart_learn/core/error/failures.dart';
import 'package:smart_learn/core/usecase/usecase.dart';
import 'package:smart_learn/features/home/domain/entities/proverb_entity.dart';
import 'package:smart_learn/features/home/domain/repositories/home_repository.dart';

class ProverbParams extends Equatable {
  final String? level;
  final int? limit;

  const ProverbParams({this.level, this.limit});

  @override
  List<Object?> get props => [level, limit];
}

@lazySingleton
class GetProverbQuestionsUseCase
    extends UseCase<List<ProverbEntity>, ProverbParams> {
  final HomeRepository repository;

  GetProverbQuestionsUseCase(this.repository);

  @override
  Future<Either<Failure, List<ProverbEntity>>> call(
    ProverbParams params,
  ) {
    return repository.getProverbQuestions(
      level: params.level,
      limit: params.limit,
    );
  }
}
