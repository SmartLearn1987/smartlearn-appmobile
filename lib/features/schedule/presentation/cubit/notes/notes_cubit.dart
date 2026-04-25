import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../domain/entities/note_item_entity.dart';
import '../../../domain/repositories/schedule_local_repository.dart';
import '../../../domain/validators/schedule_validators.dart';

part 'notes_state.dart';

@injectable
class NotesCubit extends Cubit<NotesState> {
  final ScheduleLocalRepository _repository;

  NotesCubit(this._repository) : super(const NotesState());

  void loadNotes() {
    final result = _repository.getNotes();
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: NotesStatus.error,
          errorMessage: failure.message,
        ),
      ),
      (notes) => emit(
        state.copyWith(
          notes: notes,
          status: NotesStatus.loaded,
        ),
      ),
    );
  }

  void addNote(NoteItemEntity note) {
    final error = validateNoteContent(note.title, note.content);
    if (error != null) {
      emit(
        state.copyWith(
          status: NotesStatus.error,
          errorMessage: error,
        ),
      );
      return;
    }

    final updatedNotes = [note, ...state.notes];
    emit(
      state.copyWith(
        notes: updatedNotes,
        isAddingNote: false,
        status: NotesStatus.loaded,
      ),
    );
    _saveNotes();
  }

  void editNote(NoteItemEntity note) {
    final error = validateNoteContent(note.title, note.content);
    if (error != null) {
      emit(
        state.copyWith(
          status: NotesStatus.error,
          errorMessage: error,
        ),
      );
      return;
    }

    final updatedNotes =
        state.notes.map((n) => n.id == note.id ? note : n).toList();
    emit(
      state.copyWith(
        notes: updatedNotes,
        editingNote: null,
        status: NotesStatus.loaded,
      ),
    );
    _saveNotes();
  }

  void deleteNote(String noteId) {
    final updatedNotes =
        state.notes.where((n) => n.id != noteId).toList();
    emit(
      state.copyWith(
        notes: updatedNotes,
        status: NotesStatus.loaded,
      ),
    );
    _saveNotes();
  }

  void toggleAddForm() {
    emit(state.copyWith(isAddingNote: !state.isAddingNote));
  }

  void setEditingNote(NoteItemEntity? note) {
    // Reset to null first so re-selecting the same note still triggers the listener.
    if (note != null && state.editingNote != null) {
      emit(state.copyWith(editingNote: null));
    }
    emit(state.copyWith(editingNote: note));
  }

  void setViewingNote(NoteItemEntity? note) {
    // Reset to null first so re-selecting the same note still triggers the listener.
    if (note != null && state.viewingNote != null) {
      emit(state.copyWith(viewingNote: null));
    }
    emit(state.copyWith(viewingNote: note));
  }

  Future<void> _saveNotes() async {
    await _repository.saveNotes(state.notes);
  }
}
