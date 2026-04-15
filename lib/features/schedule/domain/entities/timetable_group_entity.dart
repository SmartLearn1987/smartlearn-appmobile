import 'package:equatable/equatable.dart';

import 'timetable_entry_entity.dart';

class TimetableGroupEntity extends Equatable {
  final String id;
  final String name;
  final List<TimetableEntryEntity> entries;

  const TimetableGroupEntity({
    required this.id,
    required this.name,
    required this.entries,
  });

  @override
  List<Object?> get props => [id, name, entries];
}
