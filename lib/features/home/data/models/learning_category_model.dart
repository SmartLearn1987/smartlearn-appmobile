import 'package:json_annotation/json_annotation.dart';
import 'package:smart_learn/features/home/domain/entities/learning_category_entity.dart';

part 'learning_category_model.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class LearningCategoryModel extends LearningCategoryEntity {
  const LearningCategoryModel({
    required super.id,
    required super.name,
    required super.description,
    required super.generalQuestion,
    required super.itemCount,
  });

  factory LearningCategoryModel.fromJson(Map<String, dynamic> json) =>
      _$LearningCategoryModelFromJson(json);

  Map<String, dynamic> toJson() => _$LearningCategoryModelToJson(this);
}
