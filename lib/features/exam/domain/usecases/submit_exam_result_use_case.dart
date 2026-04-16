import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:smart_learn/core/error/failures.dart';
import 'package:smart_learn/core/usecase/usecase.dart';
import 'package:smart_learn/features/exam/domain/repositories/exam_repository.dart';

@lazySingleton
class SubmitExamResultUseCase extends UseCase<void, SubmitExamResultParams> {
  final ExamRepository repository;

  SubmitExamResultUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(SubmitExamResultParams params) =>
      repository.submitExamResult(
        examId: params.examId,
        score: params.score,
        timeTaken: params.timeTaken,
      );
}

class SubmitExamResultParams {
  final String examId;
  final double score;
  final int timeTaken;

  const SubmitExamResultParams({
    required this.examId,
    required this.score,
    required this.timeTaken,
  });
}
