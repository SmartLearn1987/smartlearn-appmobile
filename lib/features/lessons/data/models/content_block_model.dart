import 'package:json_annotation/json_annotation.dart';
import 'package:smart_learn/features/lessons/domain/entities/content_block.dart';

part 'content_block_model.g.dart';

@JsonSerializable(fieldRename: FieldRename.none)
class ContentBlockModel extends ContentBlock {
  const ContentBlockModel({
    required super.type,
    required super.content,
  });

  factory ContentBlockModel.fromJson(Map<String, dynamic> json) =>
      _$ContentBlockModelFromJson(json);

  Map<String, dynamic> toJson() => _$ContentBlockModelToJson(this);
}
