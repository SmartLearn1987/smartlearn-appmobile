import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:smart_learn/core/error/exceptions.dart';
import 'package:smart_learn/core/error/failures.dart';
import 'package:smart_learn/features/quizlet/data/datasources/quizlet_remote_datasource.dart';
import 'package:smart_learn/features/quizlet/domain/entities/quizlet_detail_entity.dart';
import 'package:smart_learn/features/quizlet/domain/entities/quizlet_entity.dart';
import 'package:smart_learn/features/quizlet/domain/repositories/quizlet_repository.dart';

@LazySingleton(as: QuizletRepository)
class QuizletRepositoryImpl implements QuizletRepository {
  final QuizletRemoteDatasource remoteDatasource;

  QuizletRepositoryImpl(this.remoteDatasource);

  @override
  Future<Either<Failure, List<QuizletEntity>>> getQuizlets() async {
    try {
      final result = await remoteDatasource.getQuizlets();
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, QuizletDetailEntity>> getQuizletDetail(
    String id,
  ) async {
    try {
      final result = await remoteDatasource.getQuizletDetail(id);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
