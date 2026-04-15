import 'package:json_annotation/json_annotation.dart';

import '../../domain/entities/timetable_entry_entity.dart';

part 'timetable_entry_model.g.dart';

@JsonSerializable()
class TimetableEntryModel extends TimetableEntryEntity {
  const TimetableEntryModel({
    required super.id,
    required super.day,
    required super.subject,
    required super.startTime,
    required super.endTime,
    required super.room,
    required super.color,
  });

  factory TimetableEntryModel.fromJson(Map<String, dynamic> json) =>
      _$TimetableEntryModelFromJson(json);

  Map<String, dynamic> toJson() => _$TimetableEntryModelToJson(this);
}
