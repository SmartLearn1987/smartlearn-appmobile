import 'package:json_annotation/json_annotation.dart';
import 'package:smart_learn/features/exam/domain/entities/exam_entity.dart';

part 'exam_model.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class ExamModel extends ExamEntity {
  const ExamModel({
    required super.id,
    required super.title,
    super.description,
    required super.duration,
    required super.subjectName,
    required super.questionCount,
    required super.averageScore,
    required super.authorName,
    required super.isPublic,
    required super.createdAt,
  });

  factory ExamModel.fromJson(Map<String, dynamic> json) =>
      _$ExamModelFromJson(json);

  Map<String, dynamic> toJson() => _$ExamModelToJson(this);
}
