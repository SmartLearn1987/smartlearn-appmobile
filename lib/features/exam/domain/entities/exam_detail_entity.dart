import 'package:equatable/equatable.dart';

import 'exam_question_entity.dart';

class ExamDetailEntity extends Equatable {
  final String id;
  final String title;
  final String? description;
  final int duration;
  final String? subjectId;
  final String? educationLevel;
  final String? grade;
  final bool? isPublic;
  final List<ExamQuestionEntity> questions;

  const ExamDetailEntity({
    required this.id,
    required this.title,
    this.description,
    required this.duration,
    this.subjectId,
    this.educationLevel,
    this.grade,
    this.isPublic,
    required this.questions,
  });

  @override
  List<Object?> get props => [
    id,
    title,
    description,
    duration,
    subjectId,
    educationLevel,
    grade,
    isPublic,
    questions,
  ];
}
