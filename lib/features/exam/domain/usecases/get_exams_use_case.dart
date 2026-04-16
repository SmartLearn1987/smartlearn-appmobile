import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:smart_learn/core/error/failures.dart';
import 'package:smart_learn/core/usecase/usecase.dart';
import 'package:smart_learn/features/exam/domain/entities/exam_entity.dart';
import 'package:smart_learn/features/exam/domain/repositories/exam_repository.dart';

@lazySingleton
class GetExamsUseCase extends UseCase<List<ExamEntity>, NoParams> {
  final ExamRepository repository;

  GetExamsUseCase(this.repository);

  @override
  Future<Either<Failure, List<ExamEntity>>> call(NoParams params) =>
      repository.getExams();
}
