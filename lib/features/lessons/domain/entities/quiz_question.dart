import 'package:equatable/equatable.dart';

class QuizQuestion extends Equatable {
  final String id;
  final String lessonId;
  final String question;
  final List<String> options;
  final int correctIndex;
  final String? explanation;

  const QuizQuestion({
    required this.id,
    required this.lessonId,
    required this.question,
    required this.options,
    required this.correctIndex,
    this.explanation,
  });

  @override
  List<Object?> get props => [
        id,
        lessonId,
        question,
        options,
        correctIndex,
        explanation,
      ];
}
