import 'package:equatable/equatable.dart';

class CurriculumEntity extends Equatable {
  final String id;
  final String subjectId;
  final String name;
  final String? grade;
  final String? educationLevel;
  final bool isPublic;
  final String? publisher;
  final String? imageUrl;
  final String? createdBy;
  final int lessonCount;

  const CurriculumEntity({
    required this.id,
    required this.subjectId,
    required this.name,
    this.grade,
    this.educationLevel,
    required this.isPublic,
    this.publisher,
    this.imageUrl,
    this.createdBy,
    required this.lessonCount,
  });

  @override
  List<Object?> get props => [
        id,
        subjectId,
        name,
        grade,
        educationLevel,
        isPublic,
        publisher,
        imageUrl,
        createdBy,
        lessonCount,
      ];
}
