import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:smart_learn/core/error/failures.dart';
import 'package:smart_learn/features/lessons/domain/entities/lesson_entity.dart';
import 'package:smart_learn/features/lessons/domain/entities/lesson_image.dart';
import 'package:smart_learn/features/lessons/domain/entities/lesson_progress.dart';

abstract class LessonsRepository {
  Future<Either<Failure, List<LessonEntity>>> getLessons(String curriculumId);
  Future<Either<Failure, LessonEntity>> getLessonById(String id);
  Future<Either<Failure, LessonEntity>> createLesson(
    Map<String, dynamic> data,
  );
  Future<Either<Failure, LessonEntity>> updateLesson(
    String id,
    Map<String, dynamic> data,
  );
  Future<Either<Failure, void>> deleteLesson(String id);
  Future<Either<Failure, void>> updateQuizFlashcards(
    String lessonId,
    Map<String, dynamic> data,
  );
  Future<Either<Failure, List<LessonImage>>> getLessonImages(String lessonId);
  Future<Either<Failure, List<LessonImage>>> uploadImages(
    String lessonId,
    List<File> images,
  );
  Future<Either<Failure, void>> deleteImage(String lessonId, String imageId);
  Future<Either<Failure, List<LessonProgress>>> getProgress(String studentId);
  Future<Either<Failure, LessonProgress>> updateProgress(
    String lessonId,
    Map<String, dynamic> data,
  );
}
