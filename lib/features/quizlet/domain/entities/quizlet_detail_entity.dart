import 'package:equatable/equatable.dart';

import 'quizlet_term_entity.dart';

class QuizletDetailEntity extends Equatable {
  final String id;
  final String title;
  final String? description;
  final String? subjectName;
  final List<QuizletTermEntity> terms;

  const QuizletDetailEntity({
    required this.id,
    required this.title,
    this.description,
    this.subjectName,
    required this.terms,
  });

  @override
  List<Object?> get props => [id, title, description, subjectName, terms];
}
