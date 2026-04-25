part of 'notes_cubit.dart';

enum NotesStatus { initial, loaded, error }

const _sentinel = Object();

class NotesState extends Equatable {
  final List<NoteItemEntity> notes;
  final bool isAddingNote;
  final NoteItemEntity? editingNote;
  final NoteItemEntity? viewingNote;
  final NotesStatus status;
  final String? errorMessage;

  const NotesState({
    this.notes = const [],
    this.isAddingNote = false,
    this.editingNote,
    this.viewingNote,
    this.status = NotesStatus.initial,
    this.errorMessage,
  });

  NotesState copyWith({
    List<NoteItemEntity>? notes,
    bool? isAddingNote,
    Object? editingNote = _sentinel,
    Object? viewingNote = _sentinel,
    NotesStatus? status,
    String? errorMessage,
  }) =>
      NotesState(
        notes: notes ?? this.notes,
        isAddingNote: isAddingNote ?? this.isAddingNote,
        editingNote: editingNote == _sentinel
            ? this.editingNote
            : editingNote as NoteItemEntity?,
        viewingNote: viewingNote == _sentinel
            ? this.viewingNote
            : viewingNote as NoteItemEntity?,
        status: status ?? this.status,
        errorMessage: errorMessage,
      );

  @override
  List<Object?> get props => [
        notes,
        isAddingNote,
        editingNote,
        viewingNote,
        status,
        errorMessage,
      ];
}
