import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:smart_learn/core/error/failures.dart';
import 'package:smart_learn/core/usecase/usecase.dart';
import 'package:smart_learn/features/exam/domain/entities/exam_entity.dart';
import 'package:smart_learn/features/exam/domain/repositories/exam_repository.dart';
import 'package:equatable/equatable.dart';

@lazySingleton
class GetExamsUseCase extends UseCase<List<ExamEntity>, GetExamsParams> {
  final ExamRepository repository;

  GetExamsUseCase(this.repository);

  @override
  Future<Either<Failure, List<ExamEntity>>> call(GetExamsParams params) =>
      repository.getExams(tab: params.tab, search: params.search);
}

class GetExamsParams extends Equatable {
  final String? tab;
  final String? search;

  const GetExamsParams({this.tab, this.search});

  @override
  List<Object?> get props => [tab, search];
}
