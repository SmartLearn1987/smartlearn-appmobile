import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:smart_learn/core/error/failures.dart';
import 'package:smart_learn/core/usecase/usecase.dart';
import 'package:smart_learn/features/home/domain/entities/dictation_entity.dart';
import 'package:smart_learn/features/home/domain/repositories/home_repository.dart';

class DictationParams extends Equatable {
  final String? level;
  final String? language;

  const DictationParams({this.level, this.language});

  @override
  List<Object?> get props => [level, language];
}

@lazySingleton
class GetRandomDictationUseCase
    extends UseCase<DictationEntity, DictationParams> {
  final HomeRepository repository;

  GetRandomDictationUseCase(this.repository);

  @override
  Future<Either<Failure, DictationEntity>> call(DictationParams params) {
    return repository.getRandomDictation(
      level: params.level,
      language: params.language,
    );
  }
}
