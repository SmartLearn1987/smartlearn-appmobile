import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:retrofit/retrofit.dart';
import 'package:smart_learn/features/exam/data/models/exam_detail_model.dart';
import 'package:smart_learn/features/exam/data/models/exam_model.dart';

part 'exam_remote_datasource.g.dart';

@RestApi()
@lazySingleton
abstract class ExamRemoteDatasource {
  @factoryMethod
  factory ExamRemoteDatasource(Dio dio) = _ExamRemoteDatasource;

  @GET('/exams')
  Future<List<ExamModel>> getExams({
    @Query('tab') String? tab,
    @Query('search') String? search,
  });

  @GET('/exams/{id}')
  Future<ExamDetailModel> getExamDetail(@Path('id') String id);

  @POST('/exams')
  Future<void> createExam(@Body() Map<String, dynamic> body);

  @PUT('/exams/{id}')
  Future<void> updateExam(
    @Path('id') String id,
    @Body() Map<String, dynamic> body,
  );

  @DELETE('/exams/{id}')
  Future<void> deleteExam(@Path('id') String id);

  @POST('/exams/{id}/results')
  Future<void> submitExamResult(
    @Path('id') String id,
    @Body() Map<String, dynamic> body,
  );
}
