import 'package:dartz/dartz.dart';
import 'package:smart_learn/core/error/failures.dart';
import 'package:smart_learn/features/quizlet/domain/entities/quizlet_detail_entity.dart';
import 'package:smart_learn/features/quizlet/domain/entities/quizlet_entity.dart';

abstract class QuizletRepository {
  Future<Either<Failure, List<QuizletEntity>>> getQuizlets();
  Future<Either<Failure, QuizletDetailEntity>> getQuizletDetail(String id);
}
