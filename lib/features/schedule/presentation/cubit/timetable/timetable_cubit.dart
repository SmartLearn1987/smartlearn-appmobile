import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../domain/entities/timetable_entry_entity.dart';
import '../../../domain/entities/timetable_group_entity.dart';
import '../../../domain/repositories/schedule_local_repository.dart';
import '../../../domain/validators/schedule_validators.dart';

part 'timetable_state.dart';

@injectable
class TimetableCubit extends Cubit<TimetableState> {
  final ScheduleLocalRepository _repository;

  TimetableCubit(this._repository) : super(const TimetableState());

  void loadGroups() {
    final result = _repository.getTimetableGroups();
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: TimetableStatus.error,
          errorMessage: failure.message,
        ),
      ),
      (groups) {
        if (groups.isEmpty) {
          final defaultGroup = TimetableGroupEntity(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            name: 'Lịch học chính',
            entries: const [],
          );
          final newGroups = [defaultGroup];
          emit(
            state.copyWith(
              groups: newGroups,
              selectedGroupIndex: 0,
              status: TimetableStatus.loaded,
            ),
          );
          _saveGroups();
        } else {
          emit(
            state.copyWith(
              groups: groups,
              selectedGroupIndex: 0,
              status: TimetableStatus.loaded,
            ),
          );
        }
      },
    );
  }

  void selectGroup(int index) {
    if (index >= 0 && index < state.groups.length) {
      emit(state.copyWith(selectedGroupIndex: index));
    }
  }

  void addGroup(String name) {
    if (name.trim().isEmpty) {
      emit(
        state.copyWith(
          status: TimetableStatus.error,
          errorMessage: 'Vui lòng nhập tên loại',
        ),
      );
      return;
    }

    final newGroup = TimetableGroupEntity(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name.trim(),
      entries: const [],
    );
    final updatedGroups = [...state.groups, newGroup];
    emit(
      state.copyWith(
        groups: updatedGroups,
        selectedGroupIndex: updatedGroups.length - 1,
        isAddingGroup: false,
        status: TimetableStatus.loaded,
      ),
    );
    _saveGroups();
  }

  void deleteGroup(int index) {
    if (state.groups.length <= 1) {
      emit(
        state.copyWith(
          status: TimetableStatus.error,
          errorMessage: 'Không thể xóa nhóm cuối cùng',
        ),
      );
      return;
    }

    final updatedGroups = [...state.groups]..removeAt(index);
    final newSelectedIndex = state.selectedGroupIndex >= updatedGroups.length
        ? 0
        : state.selectedGroupIndex;
    emit(
      state.copyWith(
        groups: updatedGroups,
        selectedGroupIndex: newSelectedIndex,
        status: TimetableStatus.loaded,
      ),
    );
    _saveGroups();
  }

  void addEntry(TimetableEntryEntity entry) {
    final error = validateSubjectName(entry.subject);
    if (error != null) {
      emit(state.copyWith(status: TimetableStatus.error, errorMessage: error));
      return;
    }

    final currentGroup = state.groups[state.selectedGroupIndex];
    final updatedEntries = [...currentGroup.entries, entry];
    final updatedGroup = TimetableGroupEntity(
      id: currentGroup.id,
      name: currentGroup.name,
      entries: updatedEntries,
    );
    final updatedGroups = [...state.groups];
    updatedGroups[state.selectedGroupIndex] = updatedGroup;
    emit(
      state.copyWith(
        groups: updatedGroups,
        isAddingEntry: false,
        status: TimetableStatus.loaded,
      ),
    );
    _saveGroups();
  }

  void editEntry(TimetableEntryEntity entry) {
    final error = validateSubjectName(entry.subject);
    if (error != null) {
      emit(state.copyWith(status: TimetableStatus.error, errorMessage: error));
      return;
    }

    final currentGroup = state.groups[state.selectedGroupIndex];
    final updatedEntries = currentGroup.entries
        .map((e) => e.id == entry.id ? entry : e)
        .toList();
    final updatedGroup = TimetableGroupEntity(
      id: currentGroup.id,
      name: currentGroup.name,
      entries: updatedEntries,
    );
    final updatedGroups = [...state.groups];
    updatedGroups[state.selectedGroupIndex] = updatedGroup;
    emit(
      state.copyWith(
        groups: updatedGroups,
        editingEntry: null,
        status: TimetableStatus.loaded,
      ),
    );
    _saveGroups();
  }

  void deleteEntry(String entryId) {
    final currentGroup = state.groups[state.selectedGroupIndex];
    final updatedEntries = currentGroup.entries
        .where((e) => e.id != entryId)
        .toList();
    final updatedGroup = TimetableGroupEntity(
      id: currentGroup.id,
      name: currentGroup.name,
      entries: updatedEntries,
    );
    final updatedGroups = [...state.groups];
    updatedGroups[state.selectedGroupIndex] = updatedGroup;
    emit(state.copyWith(groups: updatedGroups, status: TimetableStatus.loaded));
    _saveGroups();
  }

  void toggleAddForm() {
    emit(state.copyWith(isAddingEntry: !state.isAddingEntry));
  }

  void toggleAddGroup() {
    emit(state.copyWith(isAddingGroup: !state.isAddingGroup));
  }

  void setEditingEntry(TimetableEntryEntity? entry) {
    // Reset to null first so re-selecting the same entry still triggers the listener.
    if (entry != null && state.editingEntry != null) {
      emit(state.copyWith(editingEntry: null));
    }
    emit(state.copyWith(editingEntry: entry));
  }

  Future<void> _saveGroups() async {
    await _repository.saveTimetableGroups(state.groups);
  }
}
