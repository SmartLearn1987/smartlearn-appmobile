import 'package:json_annotation/json_annotation.dart';
import 'package:smart_learn/features/lessons/domain/entities/quiz_question.dart';

part 'quiz_question_model.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class QuizQuestionModel extends QuizQuestion {
  const QuizQuestionModel({
    required super.id,
    required super.question,
    required super.options,
    @JsonKey(name: 'correctIndex') required super.correctIndex,
    super.explanation,
  });

  factory QuizQuestionModel.fromJson(Map<String, dynamic> json) =>
      _$QuizQuestionModelFromJson(json);

  Map<String, dynamic> toJson() => _$QuizQuestionModelToJson(this);
}
