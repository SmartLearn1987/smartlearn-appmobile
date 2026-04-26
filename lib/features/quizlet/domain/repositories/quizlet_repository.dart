import 'package:dartz/dartz.dart';
import 'package:smart_learn/core/error/failures.dart';
import 'package:smart_learn/features/quizlet/domain/entities/quizlet_detail_entity.dart';
import 'package:smart_learn/features/quizlet/domain/entities/quizlet_entity.dart';
import 'package:smart_learn/features/quizlet/domain/usecases/params/create_quizlet_params.dart';
import 'package:smart_learn/features/quizlet/domain/usecases/params/update_quizlet_params.dart';

abstract class QuizletRepository {
  Future<Either<Failure, List<QuizletEntity>>> getQuizlets({
    required String tab,
  });
  Future<Either<Failure, QuizletDetailEntity>> getQuizletDetail(String id);
  Future<Either<Failure, void>> createQuizlet(CreateQuizletParams params);
  Future<Either<Failure, void>> updateQuizlet(UpdateQuizletParams params);
  Future<Either<Failure, void>> deleteQuizlet(String id);
}
