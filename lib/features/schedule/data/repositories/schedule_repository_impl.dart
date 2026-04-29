import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/error_utils.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/note_item_entity.dart';
import '../../domain/entities/task_item_entity.dart';
import '../../domain/entities/timetable_entry_entity.dart';
import '../../domain/entities/timetable_group_entity.dart';
import '../../domain/repositories/schedule_repository.dart';
import '../datasources/schedule_remote_datasource.dart';

@LazySingleton(as: ScheduleRepository)
class ScheduleRepositoryImpl implements ScheduleRepository {
  final ScheduleRemoteDatasource _remote;

  const ScheduleRepositoryImpl(this._remote);

  // ── Timetable Groups ──────────────────────────────────────────────────────

  @override
  Future<Either<Failure, List<TimetableGroupEntity>>> getTimetableGroups() async {
    try {
      final groups = await _remote.getTimetableGroups();
      return Right(groups);
    } on DioException catch (e) {
      return Left(ServerFailure(message: extractDioErrorMessage(e)));
    } catch (e) {
      return Left(ServerFailure(message: 'Đã xảy ra lỗi không xác định'));
    }
  }

  @override
  Future<Either<Failure, TimetableGroupEntity>> createTimetableGroup(
    String name,
  ) async {
    try {
      final group = await _remote.createTimetableGroup({'name': name});
      return Right(group);
    } on DioException catch (e) {
      return Left(ServerFailure(message: extractDioErrorMessage(e)));
    } catch (e) {
      return Left(ServerFailure(message: 'Đã xảy ra lỗi không xác định'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteTimetableGroup(String groupId) async {
    try {
      await _remote.deleteTimetableGroup(groupId);
      return const Right(null);
    } on DioException catch (e) {
      return Left(ServerFailure(message: extractDioErrorMessage(e)));
    } catch (e) {
      return Left(ServerFailure(message: 'Đã xảy ra lỗi không xác định'));
    }
  }

  // ── Timetable Entries ─────────────────────────────────────────────────────

  @override
  Future<Either<Failure, TimetableEntryEntity>> createTimetableEntry({
    required String groupId,
    required String day,
    required String subject,
    required String startTime,
    required String endTime,
    String? room,
  }) async {
    try {
      final entry = await _remote.createTimetableEntry({
        'group_id': groupId,
        'day': day,
        'subject': subject,
        'start_time': startTime,
        'end_time': endTime,
        'room': room,
      });
      return Right(entry);
    } on DioException catch (e) {
      return Left(ServerFailure(message: extractDioErrorMessage(e)));
    } catch (e) {
      return Left(ServerFailure(message: 'Đã xảy ra lỗi không xác định'));
    }
  }

  @override
  Future<Either<Failure, TimetableEntryEntity>> updateTimetableEntry({
    required String entryId,
    required String day,
    required String subject,
    required String startTime,
    required String endTime,
    String? room,
  }) async {
    try {
      final entry = await _remote.updateTimetableEntry(entryId, {
        'day': day,
        'subject': subject,
        'start_time': startTime,
        'end_time': endTime,
        'room': room ?? '',
      });
      return Right(entry);
    } on DioException catch (e) {
      return Left(ServerFailure(message: extractDioErrorMessage(e)));
    } catch (e) {
      return Left(ServerFailure(message: 'Đã xảy ra lỗi không xác định'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteTimetableEntry(String entryId) async {
    try {
      await _remote.deleteTimetableEntry(entryId);
      return const Right(null);
    } on DioException catch (e) {
      return Left(ServerFailure(message: extractDioErrorMessage(e)));
    } catch (e) {
      return Left(ServerFailure(message: 'Đã xảy ra lỗi không xác định'));
    }
  }

  // ── Tasks ─────────────────────────────────────────────────────────────────

  @override
  Future<Either<Failure, List<TaskItemEntity>>> getTasks() async {
    try {
      final tasks = await _remote.getTasks();
      return Right(tasks);
    } on DioException catch (e) {
      return Left(ServerFailure(message: extractDioErrorMessage(e)));
    } catch (e) {
      return Left(ServerFailure(message: 'Đã xảy ra lỗi không xác định'));
    }
  }

  @override
  Future<Either<Failure, TaskItemEntity>> createTask({
    required String title,
    required String description,
    required DateTime? dueDate,
    required String priority,
  }) async {
    try {
      final task = await _remote.createTask({
        'title': title,
        'description': description,
        'due_date': dueDate?.toIso8601String(),
        'priority': priority,
      });
      return Right(task);
    } on DioException catch (e) {
      return Left(ServerFailure(message: extractDioErrorMessage(e)));
    } catch (e) {
      return Left(ServerFailure(message: 'Đã xảy ra lỗi không xác định'));
    }
  }

  @override
  Future<Either<Failure, TaskItemEntity>> updateTask({
    required String taskId,
    String? title,
    String? description,
    DateTime? dueDate,
    bool? completed,
    String? priority,
  }) async {
    try {
      final body = <String, dynamic>{};
      if (title != null) body['title'] = title;
      if (description != null) body['description'] = description;
      if (dueDate != null) body['due_date'] = dueDate.toIso8601String();
      if (completed != null) body['completed'] = completed;
      if (priority != null) body['priority'] = priority;

      final task = await _remote.updateTask(taskId, body);
      return Right(task);
    } on DioException catch (e) {
      return Left(ServerFailure(message: extractDioErrorMessage(e)));
    } catch (e) {
      return Left(ServerFailure(message: 'Đã xảy ra lỗi không xác định'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteTask(String taskId) async {
    try {
      await _remote.deleteTask(taskId);
      return const Right(null);
    } on DioException catch (e) {
      return Left(ServerFailure(message: extractDioErrorMessage(e)));
    } catch (e) {
      return Left(ServerFailure(message: 'Đã xảy ra lỗi không xác định'));
    }
  }

  // ── Notes ─────────────────────────────────────────────────────────────────

  @override
  Future<Either<Failure, List<NoteItemEntity>>> getNotes() async {
    try {
      final notes = await _remote.getNotes();
      return Right(notes);
    } on DioException catch (e) {
      return Left(ServerFailure(message: extractDioErrorMessage(e)));
    } catch (e) {
      return Left(ServerFailure(message: 'Đã xảy ra lỗi không xác định'));
    }
  }

  @override
  Future<Either<Failure, NoteItemEntity>> createNote({
    required String title,
    required String content,
  }) async {
    try {
      final note = await _remote.createNote({
        'title': title,
        'content': content,
      });
      return Right(note);
    } on DioException catch (e) {
      return Left(ServerFailure(message: extractDioErrorMessage(e)));
    } catch (e) {
      return Left(ServerFailure(message: 'Đã xảy ra lỗi không xác định'));
    }
  }

  @override
  Future<Either<Failure, NoteItemEntity>> updateNote({
    required String noteId,
    required String title,
    required String content,
  }) async {
    try {
      final note = await _remote.updateNote(noteId, {
        'title': title,
        'content': content,
      });
      return Right(note);
    } on DioException catch (e) {
      return Left(ServerFailure(message: extractDioErrorMessage(e)));
    } catch (e) {
      return Left(ServerFailure(message: 'Đã xảy ra lỗi không xác định'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteNote(String noteId) async {
    try {
      await _remote.deleteNote(noteId);
      return const Right(null);
    } on DioException catch (e) {
      return Left(ServerFailure(message: extractDioErrorMessage(e)));
    } catch (e) {
      return Left(ServerFailure(message: 'Đã xảy ra lỗi không xác định'));
    }
  }
}
