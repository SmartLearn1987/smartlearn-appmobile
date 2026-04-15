import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:retrofit/retrofit.dart';
import 'package:smart_learn/features/quizlet/data/models/quizlet_detail_model.dart';
import 'package:smart_learn/features/quizlet/data/models/quizlet_model.dart';

part 'quizlet_remote_datasource.g.dart';

@RestApi()
@lazySingleton
abstract class QuizletRemoteDatasource {
  @factoryMethod
  factory QuizletRemoteDatasource(Dio dio) = _QuizletRemoteDatasource;

  @GET('/quizlets')
  Future<List<QuizletModel>> getQuizlets();

  @GET('/quizlets/{id}')
  Future<QuizletDetailModel> getQuizletDetail(@Path('id') String id);
}
