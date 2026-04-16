import 'package:json_annotation/json_annotation.dart';
import 'package:smart_learn/features/exam/domain/entities/exam_question_entity.dart';

import 'exam_option_model.dart';

part 'exam_question_model.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class ExamQuestionModel extends ExamQuestionEntity {
  @override
  final List<ExamOptionModel> options;

  const ExamQuestionModel({
    required super.id,
    required super.content,
    required super.type,
    required super.sortOrder,
    required this.options,
  }) : super(options: options);

  factory ExamQuestionModel.fromJson(Map<String, dynamic> json) =>
      _$ExamQuestionModelFromJson(json);

  Map<String, dynamic> toJson() => _$ExamQuestionModelToJson(this);
}
