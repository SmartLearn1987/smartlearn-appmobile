import 'package:equatable/equatable.dart';

import 'exam_question_entity.dart';

class ExamDetailEntity extends Equatable {
  final String id;
  final String title;
  final int duration;
  final List<ExamQuestionEntity> questions;

  const ExamDetailEntity({
    required this.id,
    required this.title,
    required this.duration,
    required this.questions,
  });

  @override
  List<Object?> get props => [id, title, duration, questions];
}
