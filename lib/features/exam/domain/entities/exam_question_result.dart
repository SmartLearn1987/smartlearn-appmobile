import 'package:equatable/equatable.dart';

import 'exam_option_entity.dart';

class ExamQuestionResult extends Equatable {
  final String questionId;
  final String questionContent;
  final String questionType;
  final String? selectedOptionId;
  final List<String> selectedOptionIds;
  final String? selectedTextAnswer;
  final String? correctTextAnswer;
  final String correctOptionId;
  final bool isCorrect;
  final List<ExamOptionEntity> options;

  const ExamQuestionResult({
    required this.questionId,
    required this.questionContent,
    required this.questionType,
    this.selectedOptionId,
    this.selectedOptionIds = const [],
    this.selectedTextAnswer,
    this.correctTextAnswer,
    required this.correctOptionId,
    required this.isCorrect,
    required this.options,
  });

  @override
  List<Object?> get props => [
    questionId,
    questionContent,
    questionType,
    selectedOptionId,
    selectedOptionIds,
    selectedTextAnswer,
    correctTextAnswer,
    correctOptionId,
    isCorrect,
    options,
  ];
}
