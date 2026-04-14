import 'dart:io';

import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:retrofit/retrofit.dart';
import 'package:smart_learn/features/home/data/models/subject_model.dart';
import 'package:smart_learn/features/subjects/data/models/curriculum_model.dart';
import 'package:smart_learn/features/subjects/data/models/upload_response_model.dart';

part 'subjects_remote_datasource.g.dart';

@RestApi()
@lazySingleton
abstract class SubjectsRemoteDatasource {
  @factoryMethod
  factory SubjectsRemoteDatasource(Dio dio) = _SubjectsRemoteDatasource;

  @GET('/subjects')
  Future<List<SubjectModel>> getSubjects();

  @GET('/subjects/{id}')
  Future<SubjectModel> getSubjectById(@Path('id') String id);

  @GET('/curricula')
  Future<List<CurriculumModel>> getCurricula(
    @Query('subject_id') String? subjectId,
  );

  @POST('/curricula')
  Future<CurriculumModel> createCurriculum(@Body() FormData data);

  @PUT('/curricula/{id}')
  Future<CurriculumModel> updateCurriculum(
    @Path('id') String id,
    @Body() Map<String, dynamic> data,
  );

  @DELETE('/curricula/{id}')
  Future<void> deleteCurriculum(@Path('id') String id);

  @POST('/upload')
  @MultiPart()
  Future<UploadResponseModel> uploadImage(@Part() File file);
}
