import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:smart_learn/core/error/failures.dart';
import 'package:smart_learn/core/usecase/usecase.dart';
import 'package:smart_learn/features/exam/domain/entities/exam_detail_entity.dart';
import 'package:smart_learn/features/exam/domain/repositories/exam_repository.dart';

@lazySingleton
class GetExamDetailUseCase extends UseCase<ExamDetailEntity, String> {
  final ExamRepository repository;

  GetExamDetailUseCase(this.repository);

  @override
  Future<Either<Failure, ExamDetailEntity>> call(String params) =>
      repository.getExamDetail(params);
}
