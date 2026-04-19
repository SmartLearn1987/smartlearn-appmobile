import 'package:equatable/equatable.dart';

class NNCQuestionEntity extends Equatable {
  final String id;
  final String question;
  final List<String> options;
  final int correctIndex;
  final String? explanation;
  final String level;

  const NNCQuestionEntity({
    required this.id,
    required this.question,
    required this.options,
    required this.correctIndex,
    this.explanation,
    required this.level,
  });

  @override
  List<Object?> get props => [id, question, options, correctIndex, explanation, level];
}
