import 'dart:convert';

import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/note_item_model.dart';
import '../models/task_item_model.dart';
import '../models/timetable_group_model.dart';

@lazySingleton
class ScheduleLocalDatasource {
  final SharedPreferences _prefs;

  static const timetableKey = 'smartlearn-timetable';
  static const tasksKey = 'smartlearn-tasks';
  static const notesKey = 'smartlearn-notes';

  ScheduleLocalDatasource(this._prefs);

  List<TimetableGroupModel> getTimetableGroups() {
    try {
      final jsonString = _prefs.getString(timetableKey);
      if (jsonString == null || jsonString.isEmpty) {
        return <TimetableGroupModel>[];
      }
      final decoded = jsonDecode(jsonString) as List<dynamic>;
      return decoded
          .map(
            (e) =>
                TimetableGroupModel.fromJson(e as Map<String, dynamic>),
          )
          .toList();
    } on FormatException {
      return <TimetableGroupModel>[];
    } catch (_) {
      return <TimetableGroupModel>[];
    }
  }

  Future<void> saveTimetableGroups(
    List<TimetableGroupModel> groups,
  ) async {
    final jsonString = jsonEncode(
      groups.map((g) => g.toJson()).toList(),
    );
    await _prefs.setString(timetableKey, jsonString);
  }

  List<TaskItemModel> getTasks() {
    try {
      final jsonString = _prefs.getString(tasksKey);
      if (jsonString == null || jsonString.isEmpty) {
        return <TaskItemModel>[];
      }
      final decoded = jsonDecode(jsonString) as List<dynamic>;
      return decoded
          .map(
            (e) => TaskItemModel.fromJson(e as Map<String, dynamic>),
          )
          .toList();
    } on FormatException {
      return <TaskItemModel>[];
    } catch (_) {
      return <TaskItemModel>[];
    }
  }

  Future<void> saveTasks(List<TaskItemModel> tasks) async {
    final jsonString = jsonEncode(
      tasks.map((t) => t.toJson()).toList(),
    );
    await _prefs.setString(tasksKey, jsonString);
  }

  List<NoteItemModel> getNotes() {
    try {
      final jsonString = _prefs.getString(notesKey);
      if (jsonString == null || jsonString.isEmpty) {
        return <NoteItemModel>[];
      }
      final decoded = jsonDecode(jsonString) as List<dynamic>;
      return decoded
          .map(
            (e) => NoteItemModel.fromJson(e as Map<String, dynamic>),
          )
          .toList();
    } on FormatException {
      return <NoteItemModel>[];
    } catch (_) {
      return <NoteItemModel>[];
    }
  }

  Future<void> saveNotes(List<NoteItemModel> notes) async {
    final jsonString = jsonEncode(
      notes.map((n) => n.toJson()).toList(),
    );
    await _prefs.setString(notesKey, jsonString);
  }
}
