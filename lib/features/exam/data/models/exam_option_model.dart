import 'package:json_annotation/json_annotation.dart';
import 'package:smart_learn/features/exam/domain/entities/exam_option_entity.dart';

part 'exam_option_model.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class ExamOptionModel extends ExamOptionEntity {
  const ExamOptionModel({
    required super.id,
    required super.content,
    required super.isCorrect,
    required super.sortOrder,
  });

  factory ExamOptionModel.fromJson(Map<String, dynamic> json) =>
      _$ExamOptionModelFromJson(json);

  Map<String, dynamic> toJson() => _$ExamOptionModelToJson(this);
}
