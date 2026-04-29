import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../domain/entities/timetable_entry_entity.dart';
import '../../../domain/entities/timetable_group_entity.dart';
import '../../../domain/repositories/schedule_repository.dart';
import '../../../domain/validators/schedule_validators.dart';

part 'timetable_state.dart';

@injectable
class TimetableCubit extends Cubit<TimetableState> {
  final ScheduleRepository _repository;

  TimetableCubit(this._repository) : super(const TimetableState());

  Future<void> loadGroups() async {
    emit(state.copyWith(status: TimetableStatus.loading));
    final result = await _repository.getTimetableGroups();
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: TimetableStatus.error,
          errorMessage: failure.message,
        ),
      ),
      (groups) => emit(
        state.copyWith(
          groups: groups,
          selectedGroupIndex: 0,
          status: TimetableStatus.loaded,
        ),
      ),
    );
  }

  void selectGroup(int index) {
    if (index >= 0 && index < state.groups.length) {
      emit(state.copyWith(selectedGroupIndex: index));
    }
  }

  Future<void> addGroup(String name) async {
    if (name.trim().isEmpty) {
      emit(
        state.copyWith(
          status: TimetableStatus.error,
          errorMessage: 'Vui lòng nhập tên loại',
        ),
      );
      return;
    }

    final result = await _repository.createTimetableGroup(name.trim());
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: TimetableStatus.error,
          errorMessage: failure.message,
        ),
      ),
      (newGroup) {
        final updatedGroups = [...state.groups, newGroup];
        emit(
          state.copyWith(
            groups: updatedGroups,
            selectedGroupIndex: updatedGroups.length - 1,
            isAddingGroup: false,
            status: TimetableStatus.loaded,
          ),
        );
      },
    );
  }

  Future<void> deleteGroup(String groupId) async {
    if (state.groups.length <= 1) {
      emit(
        state.copyWith(
          status: TimetableStatus.error,
          errorMessage: 'Không thể xóa nhóm cuối cùng',
        ),
      );
      return;
    }

    final result = await _repository.deleteTimetableGroup(groupId);
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: TimetableStatus.error,
          errorMessage: failure.message,
        ),
      ),
      (_) {
        final updatedGroups =
            state.groups.where((g) => g.id != groupId).toList();
        final newSelectedIndex =
            state.selectedGroupIndex >= updatedGroups.length
                ? 0
                : state.selectedGroupIndex;
        emit(
          state.copyWith(
            groups: updatedGroups,
            selectedGroupIndex: newSelectedIndex,
            status: TimetableStatus.loaded,
          ),
        );
      },
    );
  }

  Future<void> addEntry({
    required String day,
    required String subject,
    required String startTime,
    required String endTime,
    required String room,
  }) async {
    final error = validateSubjectName(subject);
    if (error != null) {
      emit(state.copyWith(status: TimetableStatus.error, errorMessage: error));
      return;
    }

    final currentGroup = state.groups[state.selectedGroupIndex];
    final result = await _repository.createTimetableEntry(
      groupId: currentGroup.id,
      day: day,
      subject: subject,
      startTime: startTime,
      endTime: endTime,
      room: room,
    );

    result.fold(
      (failure) => emit(
        state.copyWith(
          status: TimetableStatus.error,
          errorMessage: failure.message,
        ),
      ),
      (newEntry) {
        final updatedEntries = [...currentGroup.entries, newEntry];
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
      },
    );
  }

  Future<void> editEntry(TimetableEntryEntity entry) async {
    final error = validateSubjectName(entry.subject);
    if (error != null) {
      emit(state.copyWith(status: TimetableStatus.error, errorMessage: error));
      return;
    }

    final result = await _repository.updateTimetableEntry(
      entryId: entry.id,
      day: entry.day,
      subject: entry.subject,
      startTime: entry.startTime,
      endTime: entry.endTime,
      room: entry.room ?? '',
    );

    result.fold(
      (failure) => emit(
        state.copyWith(
          status: TimetableStatus.error,
          errorMessage: failure.message,
        ),
      ),
      (updatedEntry) {
        final currentGroup = state.groups[state.selectedGroupIndex];
        final updatedEntries = currentGroup.entries
            .map((e) => e.id == updatedEntry.id ? updatedEntry : e)
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
      },
    );
  }

  Future<void> deleteEntry(String entryId) async {
    final result = await _repository.deleteTimetableEntry(entryId);
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: TimetableStatus.error,
          errorMessage: failure.message,
        ),
      ),
      (_) {
        final currentGroup = state.groups[state.selectedGroupIndex];
        final updatedEntries =
            currentGroup.entries.where((e) => e.id != entryId).toList();
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
            status: TimetableStatus.loaded,
          ),
        );
      },
    );
  }

  void toggleAddForm() {
    emit(state.copyWith(isAddingEntry: !state.isAddingEntry));
  }

  void toggleAddGroup() {
    emit(state.copyWith(isAddingGroup: !state.isAddingGroup));
  }

  void setEditingEntry(TimetableEntryEntity? entry) {
    if (entry != null && state.editingEntry != null) {
      emit(state.copyWith(editingEntry: null));
    }
    emit(state.copyWith(editingEntry: entry));
  }
}
