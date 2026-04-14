import 'package:json_annotation/json_annotation.dart';
import 'package:smart_learn/features/home/domain/entities/subject_entity.dart';

part 'subject_model.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class SubjectModel extends SubjectEntity {
  const SubjectModel({
    required super.id,
    required super.name,
    super.description,
    super.icon,
    required super.sortOrder,
    required super.curriculumCount,
  });

  factory SubjectModel.fromJson(Map<String, dynamic> json) =>
      _$SubjectModelFromJson(json);

  Map<String, dynamic> toJson() => _$SubjectModelToJson(this);
}
