import 'package:equatable/equatable.dart';

import 'content_block.dart';
import 'flashcard.dart';
import 'quiz_question.dart';
import 'vocabulary_item.dart';

class LessonEntity extends Equatable {
  final String id;
  final String curriculumId;
  final String title;
  final String? description;
  final List<ContentBlock> content;
  final String? summary;
  final List<String> keyPoints;
  final List<VocabularyItem> vocabulary;
  final List<QuizQuestion>? quiz;
  final List<Flashcard>? flashcards;
  final int sortOrder;

  const LessonEntity({
    required this.id,
    required this.curriculumId,
    required this.title,
    this.description,
    required this.content,
    this.summary,
    required this.keyPoints,
    required this.vocabulary,
    this.quiz,
    this.flashcards,
    required this.sortOrder,
  });

  @override
  List<Object?> get props => [
        id,
        curriculumId,
        title,
        description,
        content,
        summary,
        keyPoints,
        vocabulary,
        quiz,
        flashcards,
        sortOrder,
      ];
}
