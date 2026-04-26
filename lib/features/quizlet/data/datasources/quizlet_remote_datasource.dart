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
  Future<List<QuizletModel>> getQuizlets(@Query('tab') String tab);

  @GET('/quizlets/{id}')
  Future<QuizletDetailModel> getQuizletDetail(@Path('id') String id);

  @POST('/quizlets')
  Future<void> createQuizlet(@Body() Map<String, dynamic> body);

  @PUT('/quizlets/{id}')
  Future<void> updateQuizlet(
    @Path('id') String id,
    @Body() Map<String, dynamic> body,
  );

  @DELETE('/quizlets/{id}')
  Future<void> deleteQuizlet(@Path('id') String id);
}
