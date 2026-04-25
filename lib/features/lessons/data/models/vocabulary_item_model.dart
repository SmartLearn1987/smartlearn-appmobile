import 'package:json_annotation/json_annotation.dart';
import 'package:smart_learn/features/lessons/domain/entities/vocabulary_item.dart';

part 'vocabulary_item_model.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class VocabularyItemModel extends VocabularyItem {
  const VocabularyItemModel({
    required super.term,
    required super.definition,
  });

  factory VocabularyItemModel.fromJson(Map<String, dynamic> json) =>
      _$VocabularyItemModelFromJson(json);

  Map<String, dynamic> toJson() => _$VocabularyItemModelToJson(this);
}
