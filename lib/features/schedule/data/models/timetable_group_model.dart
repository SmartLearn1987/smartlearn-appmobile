import 'package:json_annotation/json_annotation.dart';

import '../../domain/entities/timetable_group_entity.dart';
import 'timetable_entry_model.dart';

part 'timetable_group_model.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class TimetableGroupModel extends TimetableGroupEntity {
  @override
  final List<TimetableEntryModel> entries;

  const TimetableGroupModel({
    required super.id,
    required super.name,
    required this.entries,
  }) : super(entries: entries);

  factory TimetableGroupModel.fromJson(Map<String, dynamic> json) =>
      _$TimetableGroupModelFromJson(json);

  Map<String, dynamic> toJson() => _$TimetableGroupModelToJson(this);
}
