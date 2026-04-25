import 'dart:io';

import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:retrofit/retrofit.dart';
import 'package:smart_learn/features/lessons/data/models/lesson_image_model.dart';
import 'package:smart_learn/features/lessons/data/models/lesson_model.dart';
import 'package:smart_learn/features/lessons/data/models/lesson_progress_model.dart';

part 'lessons_remote_datasource.g.dart';

@RestApi()
@lazySingleton
abstract class LessonsRemoteDatasource {
  @factoryMethod
  factory LessonsRemoteDatasource(Dio dio) = _LessonsRemoteDatasource;

  @GET('/lessons')
  Future<List<LessonModel>> getLessons(
    @Query('curriculum_id') String curriculumId,
  );

  @GET('/lessons/{id}')
  Future<LessonModel> getLessonById(@Path('id') String id);

  @POST('/lessons')
  Future<LessonModel> createLesson(@Body() Map<String, dynamic> data);

  @PUT('/lessons/{id}')
  Future<LessonModel> updateLesson(
    @Path('id') String id,
    @Body() Map<String, dynamic> data,
  );

  @DELETE('/lessons/{id}')
  Future<void> deleteLesson(@Path('id') String id);

  @PUT('/lessons/{id}/quiz-flashcards')
  Future<void> updateQuizFlashcards(
    @Path('id') String id,
    @Body() Map<String, dynamic> data,
  );

  @GET('/lessons/{id}/images')
  Future<List<LessonImageModel>> getLessonImages(
    @Path('id') String lessonId,
  );

  @POST('/lessons/{id}/images')
  @MultiPart()
  Future<List<LessonImageModel>> uploadImages(
    @Path('id') String lessonId,
    @Part() List<File> images,
  );

  @DELETE('/lessons/{lessonId}/images/{imageId}')
  Future<void> deleteImage(
    @Path('lessonId') String lessonId,
    @Path('imageId') String imageId,
  );

  @GET('/progress')
  Future<List<LessonProgressModel>> getProgress(
    @Query('student_id') String studentId,
  );

  @PUT('/progress/{lessonId}')
  Future<LessonProgressModel> updateProgress(
    @Path('lessonId') String lessonId,
    @Body() Map<String, dynamic> data,
  );
}
