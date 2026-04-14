import 'package:json_annotation/json_annotation.dart';
import 'package:smart_learn/features/home/domain/entities/pictogram_entity.dart';

part 'pictogram_model.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class PictogramModel extends PictogramEntity {
  const PictogramModel({
    required super.id,
    required super.imageUrl,
    required super.answer,
    required super.level,
  });

  factory PictogramModel.fromJson(Map<String, dynamic> json) =>
      _$PictogramModelFromJson(json);

  Map<String, dynamic> toJson() => _$PictogramModelToJson(this);
}
