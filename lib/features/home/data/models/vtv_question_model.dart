import 'package:json_annotation/json_annotation.dart';
import 'package:smart_learn/features/home/domain/entities/vtv_question_entity.dart';

part 'vtv_question_model.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class VTVQuestionModel extends VTVQuestionEntity {
  const VTVQuestionModel({
    required super.id,
    required super.question,
    required super.answer,
    required super.hint,
    required super.level,
  });

  factory VTVQuestionModel.fromJson(Map<String, dynamic> json) =>
      _$VTVQuestionModelFromJson(json);

  Map<String, dynamic> toJson() => _$VTVQuestionModelToJson(this);
}
