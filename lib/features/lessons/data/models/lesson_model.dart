import 'package:json_annotation/json_annotation.dart';
import 'package:smart_learn/features/lessons/data/models/content_block_model.dart';
import 'package:smart_learn/features/lessons/data/models/flashcard_model.dart';
import 'package:smart_learn/features/lessons/data/models/quiz_question_model.dart';
import 'package:smart_learn/features/lessons/data/models/vocabulary_item_model.dart';
import 'package:smart_learn/features/lessons/domain/entities/lesson_entity.dart';

part 'lesson_model.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class LessonModel extends LessonEntity {
  @override
  final List<ContentBlockModel> content;

  @override
  final List<VocabularyItemModel> vocabulary;

  @override
  final List<QuizQuestionModel>? quiz;

  @override
  final List<FlashcardModel>? flashcards;

  const LessonModel({
    required super.id,
    required super.curriculumId,
    required super.title,
    super.description,
    required this.content,
    super.summary,
    required super.keyPoints,
    required this.vocabulary,
    this.quiz,
    this.flashcards,
    required super.sortOrder,
  }) : super(
         content: content,
         vocabulary: vocabulary,
         quiz: quiz,
         flashcards: flashcards,
       );

  factory LessonModel.fromJson(Map<String, dynamic> json) =>
      _$LessonModelFromJson(json);

  Map<String, dynamic> toJson() => _$LessonModelToJson(this);
}
