import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/note_item_entity.dart';
import '../entities/task_item_entity.dart';
import '../entities/timetable_entry_entity.dart';
import '../entities/timetable_group_entity.dart';

abstract class ScheduleRepository {
  // ── Timetable Groups ──────────────────────────────────────────────────────
  Future<Either<Failure, List<TimetableGroupEntity>>> getTimetableGroups();

  Future<Either<Failure, TimetableGroupEntity>> createTimetableGroup(
    String name,
  );

  Future<Either<Failure, void>> deleteTimetableGroup(String groupId);

  // ── Timetable Entries ─────────────────────────────────────────────────────
  Future<Either<Failure, TimetableEntryEntity>> createTimetableEntry({
    required String groupId,
    required String day,
    required String subject,
    required String startTime,
    required String endTime,
    String? room,
  });

  Future<Either<Failure, TimetableEntryEntity>> updateTimetableEntry({
    required String entryId,
    required String day,
    required String subject,
    required String startTime,
    required String endTime,
    String? room,
  });

  Future<Either<Failure, void>> deleteTimetableEntry(String entryId);

  // ── Tasks ─────────────────────────────────────────────────────────────────
  Future<Either<Failure, List<TaskItemEntity>>> getTasks();

  Future<Either<Failure, TaskItemEntity>> createTask({
    required String title,
    required String description,
    required DateTime? dueDate,
    required String priority,
  });

  Future<Either<Failure, TaskItemEntity>> updateTask({
    required String taskId,
    String? title,
    String? description,
    DateTime? dueDate,
    bool? completed,
    String? priority,
  });

  Future<Either<Failure, void>> deleteTask(String taskId);

  // ── Notes ─────────────────────────────────────────────────────────────────
  Future<Either<Failure, List<NoteItemEntity>>> getNotes();

  Future<Either<Failure, NoteItemEntity>> createNote({
    required String title,
    required String content,
  });

  Future<Either<Failure, NoteItemEntity>> updateNote({
    required String noteId,
    required String title,
    required String content,
  });

  Future<Either<Failure, void>> deleteNote(String noteId);
}
