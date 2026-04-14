import 'package:json_annotation/json_annotation.dart';
import 'package:smart_learn/features/home/domain/entities/dictation_entity.dart';

part 'dictation_model.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class DictationModel extends DictationEntity {
  const DictationModel({
    required super.id,
    required super.title,
    required super.level,
    required super.content,
    required super.language,
  });

  factory DictationModel.fromJson(Map<String, dynamic> json) =>
      _$DictationModelFromJson(json);

  Map<String, dynamic> toJson() => _$DictationModelToJson(this);
}
