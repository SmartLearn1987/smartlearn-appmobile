import '../../domain/entities/timetable_entry_entity.dart';

/// Groups timetable entries by their [day] field.
///
/// Returns a map where keys are day values and values are lists of entries
/// for that day. Only days with at least one entry appear as keys.
Map<int, List<TimetableEntryEntity>> groupEntriesByDay(
  List<TimetableEntryEntity> entries,
) {
  final map = <int, List<TimetableEntryEntity>>{};
  for (final entry in entries) {
    map.putIfAbsent(entry.day, () => []).add(entry);
  }
  return map;
}

/// Splits entries into morning (startTime < "12:00") and
/// afternoon (startTime >= "12:00").
({List<TimetableEntryEntity> morning, List<TimetableEntryEntity> afternoon})
    splitByPeriod(List<TimetableEntryEntity> entries) {
  final morning = <TimetableEntryEntity>[];
  final afternoon = <TimetableEntryEntity>[];
  for (final entry in entries) {
    if (entry.startTime.compareTo('12:00') < 0) {
      morning.add(entry);
    } else {
      afternoon.add(entry);
    }
  }
  return (morning: morning, afternoon: afternoon);
}

/// Sorts entries by [startTime] ascending using lexicographic comparison.
///
/// HH:MM format guarantees lexicographic order equals chronological order.
List<TimetableEntryEntity> sortEntriesByTime(
  List<TimetableEntryEntity> entries,
) =>
    List.of(entries)..sort((a, b) => a.startTime.compareTo(b.startTime));
