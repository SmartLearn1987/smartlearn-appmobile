import 'package:json_annotation/json_annotation.dart';
import 'package:smart_learn/features/lessons/domain/entities/lesson_image.dart';

part 'lesson_image_model.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class LessonImageModel extends LessonImage {
  const LessonImageModel({
    required super.id,
    required super.lessonId,
    required super.fileUrl,
    super.caption,
    required super.sortOrder,
  });

  factory LessonImageModel.fromJson(Map<String, dynamic> json) =>
      _$LessonImageModelFromJson(json);

  Map<String, dynamic> toJson() => _$LessonImageModelToJson(this);
}
