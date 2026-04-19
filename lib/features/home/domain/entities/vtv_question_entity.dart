import 'package:equatable/equatable.dart';

class VTVQuestionEntity extends Equatable {
  final String id;
  final String question;
  final String answer;
  final String hint;
  final String level;

  const VTVQuestionEntity({
    required this.id,
    required this.question,
    required this.answer,
    required this.hint,
    required this.level,
  });

  @override
  List<Object?> get props => [id, question, answer, hint, level];
}
