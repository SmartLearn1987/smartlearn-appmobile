import 'package:json_annotation/json_annotation.dart';
import 'package:smart_learn/features/exam/domain/entities/exam_detail_entity.dart';

import 'exam_question_model.dart';

part 'exam_detail_model.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class ExamDetailModel extends ExamDetailEntity {
  @override
  final List<ExamQuestionModel> questions;

  const ExamDetailModel({
    required super.id,
    required super.title,
    required super.duration,
    required this.questions,
  }) : super(questions: questions);

  factory ExamDetailModel.fromJson(Map<String, dynamic> json) =>
      _$ExamDetailModelFromJson(json);

  Map<String, dynamic> toJson() => _$ExamDetailModelToJson(this);
}
