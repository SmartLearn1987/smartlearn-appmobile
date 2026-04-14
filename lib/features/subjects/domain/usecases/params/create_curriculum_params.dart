import 'dart:io';

import 'package:equatable/equatable.dart';

class CreateCurriculumParams extends Equatable {
  final String subjectId;
  final String name;
  final String? grade;
  final String? educationLevel;
  final bool isPublic;
  final String? publisher;
  final int lessonCount;
  final File? imageFile;
  final String createdBy;

  const CreateCurriculumParams({
    required this.subjectId,
    required this.name,
    this.grade,
    this.educationLevel,
    this.isPublic = false,
    this.publisher,
    this.lessonCount = 1,
    this.imageFile,
    required this.createdBy,
  });

  @override
  List<Object?> get props => [
        subjectId,
        name,
        grade,
        educationLevel,
        isPublic,
        publisher,
        lessonCount,
        imageFile,
        createdBy,
      ];
}
