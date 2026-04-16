import 'package:equatable/equatable.dart';

import 'exam_option_entity.dart';

class ExamQuestionResult extends Equatable {
  final String questionId;
  final String questionContent;
  final String? selectedOptionId;
  final String correctOptionId;
  final bool isCorrect;
  final List<ExamOptionEntity> options;

  const ExamQuestionResult({
    required this.questionId,
    required this.questionContent,
    this.selectedOptionId,
    required this.correctOptionId,
    required this.isCorrect,
    required this.options,
  });

  @override
  List<Object?> get props => [
        questionId,
        questionContent,
        selectedOptionId,
        correctOptionId,
        isCorrect,
        options,
      ];
}
