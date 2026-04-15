import 'package:json_annotation/json_annotation.dart';

import '../../domain/entities/task_item_entity.dart';

part 'task_item_model.g.dart';

@JsonSerializable()
class TaskItemModel extends TaskItemEntity {
  const TaskItemModel({
    required super.id,
    required super.title,
    required super.description,
    super.dueDate,
    required super.completed,
    required super.priority,
    required super.createdAt,
  });

  factory TaskItemModel.fromJson(Map<String, dynamic> json) =>
      _$TaskItemModelFromJson(json);

  Map<String, dynamic> toJson() => _$TaskItemModelToJson(this);
}
