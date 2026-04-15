part of 'timetable_cubit.dart';

enum TimetableStatus { initial, loaded, error }

class TimetableState extends Equatable {
  final List<TimetableGroupEntity> groups;
  final int selectedGroupIndex;
  final bool isAddingEntry;
  final TimetableEntryEntity? editingEntry;
  final bool isAddingGroup;
  final TimetableStatus status;
  final String? errorMessage;

  const TimetableState({
    this.groups = const [],
    this.selectedGroupIndex = 0,
    this.isAddingEntry = false,
    this.editingEntry,
    this.isAddingGroup = false,
    this.status = TimetableStatus.initial,
    this.errorMessage,
  });

  TimetableState copyWith({
    List<TimetableGroupEntity>? groups,
    int? selectedGroupIndex,
    bool? isAddingEntry,
    TimetableEntryEntity? editingEntry,
    bool? isAddingGroup,
    TimetableStatus? status,
    String? errorMessage,
  }) =>
      TimetableState(
        groups: groups ?? this.groups,
        selectedGroupIndex: selectedGroupIndex ?? this.selectedGroupIndex,
        isAddingEntry: isAddingEntry ?? this.isAddingEntry,
        editingEntry: editingEntry ?? this.editingEntry,
        isAddingGroup: isAddingGroup ?? this.isAddingGroup,
        status: status ?? this.status,
        errorMessage: errorMessage,
      );

  @override
  List<Object?> get props => [
        groups,
        selectedGroupIndex,
        isAddingEntry,
        editingEntry,
        isAddingGroup,
        status,
        errorMessage,
      ];
}
