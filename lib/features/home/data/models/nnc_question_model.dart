import 'package:json_annotation/json_annotation.dart';
import 'package:smart_learn/features/home/domain/entities/nnc_question_entity.dart';

part 'nnc_question_model.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class NNCQuestionModel extends NNCQuestionEntity {
  const NNCQuestionModel({
    required super.id,
    required super.question,
    required super.options,
    required super.correctIndex,
    super.explanation,
    required super.level,
  });

  factory NNCQuestionModel.fromJson(Map<String, dynamic> json) =>
      _$NNCQuestionModelFromJson(json);

  Map<String, dynamic> toJson() => _$NNCQuestionModelToJson(this);
}
