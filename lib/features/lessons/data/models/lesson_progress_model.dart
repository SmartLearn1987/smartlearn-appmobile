import 'package:json_annotation/json_annotation.dart';
import 'package:smart_learn/features/lessons/domain/entities/lesson_progress.dart';

part 'lesson_progress_model.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class LessonProgressModel extends LessonProgress {
  const LessonProgressModel({
    required super.id,
    required super.studentId,
    required super.lessonId,
    required super.completed,
    super.completedAt,
  });

  factory LessonProgressModel.fromJson(Map<String, dynamic> json) =>
      _$LessonProgressModelFromJson(json);

  Map<String, dynamic> toJson() => _$LessonProgressModelToJson(this);
}
