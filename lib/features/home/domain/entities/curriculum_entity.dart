import 'package:equatable/equatable.dart';

class CurriculumEntity extends Equatable {
  final String id;
  final String subjectId;
  final String name;
  final String? grade;
  final String? educationLevel;
  final bool isPublic;
  final String userId;
  final int lessonCount;

  const CurriculumEntity({
    required this.id,
    required this.subjectId,
    required this.name,
    this.grade,
    this.educationLevel,
    required this.isPublic,
    required this.userId,
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
        userId,
        lessonCount,
      ];
}
