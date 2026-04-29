import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/note_item_entity.dart';
import '../../domain/entities/task_item_entity.dart';
import '../../domain/entities/timetable_group_entity.dart';
import '../../domain/repositories/schedule_local_repository.dart';
import '../datasources/schedule_local_datasource.dart';
import '../models/note_item_model.dart';
import '../models/task_item_model.dart';
import '../models/timetable_entry_model.dart';
import '../models/timetable_group_model.dart';

@LazySingleton(as: ScheduleLocalRepository)
class ScheduleLocalRepositoryImpl implements ScheduleLocalRepository {
  final ScheduleLocalDatasource _datasource;

  const ScheduleLocalRepositoryImpl(this._datasource);

  @override
  Either<Failure, List<TimetableGroupEntity>> getTimetableGroups() {
    try {
      final groups = _datasource.getTimetableGroups();
      return Right(groups);
    } catch (e) {
      return Left(CacheFailure(message: 'Failed to load timetable: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> saveTimetableGroups(
    List<TimetableGroupEntity> groups,
  ) async {
    try {
      final models = groups
          .map(
            (g) => TimetableGroupModel(
              id: g.id,
              name: g.name,
              entries: g.entries
                  .map(
                    (e) => TimetableEntryModel(
                      id: e.id,
                      day: e.day,
                      subject: e.subject,
                      startTime: e.startTime,
                      endTime: e.endTime,
                      room: e.room,
                    ),
                  )
                  .toList(),
            ),
          )
          .toList();
      await _datasource.saveTimetableGroups(models);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(message: 'Failed to save timetable: $e'));
    }
  }

  @override
  Either<Failure, List<TaskItemEntity>> getTasks() {
    try {
      final tasks = _datasource.getTasks();
      return Right(tasks);
    } catch (e) {
      return Left(CacheFailure(message: 'Failed to load tasks: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> saveTasks(
    List<TaskItemEntity> tasks,
  ) async {
    try {
      final models = tasks
          .map(
            (t) => TaskItemModel(
              id: t.id,
              title: t.title,
              description: t.description,
              dueDate: t.dueDate,
              completed: t.completed,
              priority: t.priority,
              createdAt: t.createdAt,
            ),
          )
          .toList();
      await _datasource.saveTasks(models);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(message: 'Failed to save tasks: $e'));
    }
  }

  @override
  Either<Failure, List<NoteItemEntity>> getNotes() {
    try {
      final notes = _datasource.getNotes();
      return Right(notes);
    } catch (e) {
      return Left(CacheFailure(message: 'Failed to load notes: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> saveNotes(
    List<NoteItemEntity> notes,
  ) async {
    try {
      final models = notes
          .map(
            (n) => NoteItemModel(
              id: n.id,
              title: n.title,
              content: n.content,
              updatedAt: n.updatedAt,
            ),
          )
          .toList();
      await _datasource.saveNotes(models);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(message: 'Failed to save notes: $e'));
    }
  }
}
