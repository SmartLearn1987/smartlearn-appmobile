import 'package:json_annotation/json_annotation.dart';
import 'package:smart_learn/features/quizlet/domain/entities/quizlet_entity.dart';

part 'quizlet_model.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class QuizletModel extends QuizletEntity {
  const QuizletModel({
    required super.id,
    required super.title,
    required super.subjectName,
    required super.educationLevel,
    required super.isPublic,
    required super.userId,
    required super.termCount,
    required super.authorName,
    required super.createdAt,
  });

  factory QuizletModel.fromJson(Map<String, dynamic> json) =>
      _$QuizletModelFromJson(json);

  Map<String, dynamic> toJson() => _$QuizletModelToJson(this);
}
