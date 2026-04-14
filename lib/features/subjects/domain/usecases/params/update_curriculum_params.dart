import 'dart:io';

import 'package:equatable/equatable.dart';

class UpdateCurriculumParams extends Equatable {
  final String id;
  final String? name;
  final String? grade;
  final String? educationLevel;
  final bool? isPublic;
  final String? publisher;
  final int? lessonCount;
  final File? imageFile;
  final String? existingImageUrl;

  const UpdateCurriculumParams({
    required this.id,
    this.name,
    this.grade,
    this.educationLevel,
    this.isPublic,
    this.publisher,
    this.lessonCount,
    this.imageFile,
    this.existingImageUrl,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        grade,
        educationLevel,
        isPublic,
        publisher,
        lessonCount,
        imageFile,
        existingImageUrl,
      ];
}
