import 'package:dartz/dartz.dart';
import 'package:smart_learn/core/error/failures.dart';
import 'package:smart_learn/features/exam/domain/entities/exam_detail_entity.dart';
import 'package:smart_learn/features/exam/domain/entities/exam_entity.dart';

abstract class ExamRepository {
  Future<Either<Failure, List<ExamEntity>>> getExams({
    String? tab,
    String? search,
  });
  Future<Either<Failure, ExamDetailEntity>> getExamDetail(String id);
  Future<Either<Failure, void>> createExam(Map<String, dynamic> body);
  Future<Either<Failure, void>> updateExam(
    String id,
    Map<String, dynamic> body,
  );
  Future<Either<Failure, void>> deleteExam(String id);
  Future<Either<Failure, void>> submitExamResult({
    required String examId,
    required double score,
    required int timeTaken,
  });
}
