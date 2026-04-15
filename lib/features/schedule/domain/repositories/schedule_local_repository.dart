import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/note_item_entity.dart';
import '../entities/task_item_entity.dart';
import '../entities/timetable_group_entity.dart';

abstract class ScheduleLocalRepository {
  // Timetable
  Either<Failure, List<TimetableGroupEntity>> getTimetableGroups();
  Future<Either<Failure, void>> saveTimetableGroups(
    List<TimetableGroupEntity> groups,
  );

  // Tasks
  Either<Failure, List<TaskItemEntity>> getTasks();
  Future<Either<Failure, void>> saveTasks(List<TaskItemEntity> tasks);

  // Notes
  Either<Failure, List<NoteItemEntity>> getNotes();
  Future<Either<Failure, void>> saveNotes(List<NoteItemEntity> notes);
}
