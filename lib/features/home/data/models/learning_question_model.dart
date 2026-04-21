import 'package:json_annotation/json_annotation.dart';
import 'package:smart_learn/features/home/domain/entities/learning_question_entity.dart';

part 'learning_question_model.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class LearningQuestionModel extends LearningQuestionEntity {
  const LearningQuestionModel({
    required super.id,
    required super.categoryId,
    required super.imageUrl,
    required super.answer,
  });

  factory LearningQuestionModel.fromJson(Map<String, dynamic> json) =>
      _$LearningQuestionModelFromJson(json);

  Map<String, dynamic> toJson() => _$LearningQuestionModelToJson(this);
}
