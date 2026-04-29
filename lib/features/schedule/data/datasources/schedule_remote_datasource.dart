import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:retrofit/retrofit.dart';

import '../models/note_item_model.dart';
import '../models/task_item_model.dart';
import '../models/timetable_entry_model.dart';
import '../models/timetable_group_model.dart';

part 'schedule_remote_datasource.g.dart';

@RestApi()
@lazySingleton
abstract class ScheduleRemoteDatasource {
  @factoryMethod
  factory ScheduleRemoteDatasource(Dio dio) = _ScheduleRemoteDatasource;

  // ── Timetable ─────────────────────────────────────────────────────────────

  /// GET /timetable — returns all groups with their entries
  @GET('/timetable')
  Future<List<TimetableGroupModel>> getTimetableGroups();

  /// POST /timetable/groups — create a new timetable group
  @POST('/timetable/groups')
  Future<TimetableGroupModel> createTimetableGroup(
    @Body() Map<String, dynamic> body,
  );

  /// DELETE /timetable/groups/:id
  @DELETE('/timetable/groups/{id}')
  Future<void> deleteTimetableGroup(@Path('id') String id);

  /// POST /timetable/entries — create a new entry inside a group
  @POST('/timetable/entries')
  Future<TimetableEntryModel> createTimetableEntry(
    @Body() Map<String, dynamic> body,
  );

  /// PUT /timetable/entries/:id — update an existing entry
  @PUT('/timetable/entries/{id}')
  Future<TimetableEntryModel> updateTimetableEntry(
    @Path('id') String id,
    @Body() Map<String, dynamic> body,
  );

  /// DELETE /timetable/entries/:id
  @DELETE('/timetable/entries/{id}')
  Future<void> deleteTimetableEntry(@Path('id') String id);

  // ── Tasks ─────────────────────────────────────────────────────────────────

  /// GET /tasks
  @GET('/tasks')
  Future<List<TaskItemModel>> getTasks();

  /// POST /tasks
  @POST('/tasks')
  Future<TaskItemModel> createTask(@Body() Map<String, dynamic> body);

  /// PUT /tasks/:id
  @PUT('/tasks/{id}')
  Future<TaskItemModel> updateTask(
    @Path('id') String id,
    @Body() Map<String, dynamic> body,
  );

  /// DELETE /tasks/:id
  @DELETE('/tasks/{id}')
  Future<void> deleteTask(@Path('id') String id);

  // ── Notes ─────────────────────────────────────────────────────────────────

  /// GET /notes
  @GET('/notes')
  Future<List<NoteItemModel>> getNotes();

  /// POST /notes
  @POST('/notes')
  Future<NoteItemModel> createNote(@Body() Map<String, dynamic> body);

  /// PUT /notes/:id
  @PUT('/notes/{id}')
  Future<NoteItemModel> updateNote(
    @Path('id') String id,
    @Body() Map<String, dynamic> body,
  );

  /// DELETE /notes/:id
  @DELETE('/notes/{id}')
  Future<void> deleteNote(@Path('id') String id);
}
