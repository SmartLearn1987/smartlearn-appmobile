import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:retrofit/retrofit.dart';
import 'package:smart_learn/features/home/data/models/curriculum_model.dart';
import 'package:smart_learn/features/home/data/models/dictation_model.dart';
import 'package:smart_learn/features/home/data/models/pictogram_model.dart';
import 'package:smart_learn/features/home/data/models/subject_model.dart';

part 'home_remote_datasource.g.dart';

@RestApi()
@lazySingleton
abstract class HomeRemoteDatasource {
  @factoryMethod
  factory HomeRemoteDatasource(Dio dio) = _HomeRemoteDatasource;

  @GET('/user-subjects')
  Future<List<SubjectModel>> getUserSubjects();

  @GET('/subjects')
  Future<List<SubjectModel>> getAllSubjects();

  @POST('/user-subjects')
  Future<void> saveUserSubjects(@Body() Map<String, dynamic> body);

  @GET('/curricula')
  Future<List<CurriculumModel>> getCurricula();

  @GET('/pictogram/play')
  Future<List<PictogramModel>> getPictogramQuestions(
    @Query('level') String? level,
    @Query('limit') int? limit,
  );

  @GET('/dictation/random')
  Future<DictationModel> getRandomDictation(
    @Query('level') String? level,
    @Query('language') String? language,
  );
}
