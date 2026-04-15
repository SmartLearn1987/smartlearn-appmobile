part of 'notes_cubit.dart';

enum NotesStatus { initial, loaded, error }

class NotesState extends Equatable {
  final List<NoteItemEntity> notes;
  final bool isAddingNote;
  final String? editingNoteId;
  final NoteItemEntity? viewingNote;
  final NotesStatus status;
  final String? errorMessage;

  const NotesState({
    this.notes = const [],
    this.isAddingNote = false,
    this.editingNoteId,
    this.viewingNote,
    this.status = NotesStatus.initial,
    this.errorMessage,
  });

  NotesState copyWith({
    List<NoteItemEntity>? notes,
    bool? isAddingNote,
    String? editingNoteId,
    NoteItemEntity? viewingNote,
    NotesStatus? status,
    String? errorMessage,
  }) =>
      NotesState(
        notes: notes ?? this.notes,
        isAddingNote: isAddingNote ?? this.isAddingNote,
        editingNoteId: editingNoteId ?? this.editingNoteId,
        viewingNote: viewingNote ?? this.viewingNote,
        status: status ?? this.status,
        errorMessage: errorMessage,
      );

  @override
  List<Object?> get props => [
        notes,
        isAddingNote,
        editingNoteId,
        viewingNote,
        status,
        errorMessage,
      ];
}
