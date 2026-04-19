import 'package:json_annotation/json_annotation.dart';
import 'package:smart_learn/features/home/domain/entities/proverb_entity.dart';

part 'proverb_model.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class ProverbModel extends ProverbEntity {
  const ProverbModel({
    required super.id,
    required super.content,
    required super.level,
  });

  factory ProverbModel.fromJson(Map<String, dynamic> json) =>
      _$ProverbModelFromJson(json);

  Map<String, dynamic> toJson() => _$ProverbModelToJson(this);
}
