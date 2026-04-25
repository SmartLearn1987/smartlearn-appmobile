import 'package:json_annotation/json_annotation.dart';
import 'package:smart_learn/features/subjects/domain/entities/curriculum_entity.dart';

part 'curriculum_model.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class CurriculumModel extends CurriculumEntity {
  const CurriculumModel({
    required super.id,
    required super.subjectId,
    required super.name,
    super.grade,
    super.educationLevel,
    required super.isPublic,
    super.publisher,
    super.imageUrl,
    super.createdBy,
    required super.lessonCount,
  });

  factory CurriculumModel.fromJson(Map<String, dynamic> json) =>
      _$CurriculumModelFromJson(json);

  Map<String, dynamic> toJson() => _$CurriculumModelToJson(this);
}
