import 'package:json_annotation/json_annotation.dart';

import '../../domain/entities/note_item_entity.dart';

part 'note_item_model.g.dart';

@JsonSerializable()
class NoteItemModel extends NoteItemEntity {
  const NoteItemModel({
    required super.id,
    required super.title,
    required super.content,
    required super.color,
    required super.updatedAt,
  });

  factory NoteItemModel.fromJson(Map<String, dynamic> json) =>
      _$NoteItemModelFromJson(json);

  Map<String, dynamic> toJson() => _$NoteItemModelToJson(this);
}
