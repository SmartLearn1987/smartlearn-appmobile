import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../domain/entities/note_item_entity.dart';
import '../../../domain/repositories/schedule_repository.dart';
import '../../../domain/validators/schedule_validators.dart';

part 'notes_state.dart';

@injectable
class NotesCubit extends Cubit<NotesState> {
  final ScheduleRepository _repository;

  NotesCubit(this._repository) : super(const NotesState());

  Future<void> loadNotes() async {
    emit(state.copyWith(status: NotesStatus.loading));
    final result = await _repository.getNotes();
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

  Future<void> addNote({
    required String title,
    required String content,
  }) async {
    final error = validateNoteContent(title, content);
    if (error != null) {
      emit(state.copyWith(status: NotesStatus.error, errorMessage: error));
      return;
    }

    final result = await _repository.createNote(
      title: title,
      content: content,
    );

    result.fold(
      (failure) => emit(
        state.copyWith(
          status: NotesStatus.error,
          errorMessage: failure.message,
        ),
      ),
      (newNote) {
        emit(
          state.copyWith(
            notes: [newNote, ...state.notes],
            isAddingNote: false,
            status: NotesStatus.loaded,
          ),
        );
      },
    );
  }

  Future<void> editNote(NoteItemEntity note) async {
    final error = validateNoteContent(note.title, note.content);
    if (error != null) {
      emit(state.copyWith(status: NotesStatus.error, errorMessage: error));
      return;
    }

    final result = await _repository.updateNote(
      noteId: note.id,
      title: note.title,
      content: note.content,
    );

    result.fold(
      (failure) => emit(
        state.copyWith(
          status: NotesStatus.error,
          errorMessage: failure.message,
        ),
      ),
      (updatedNote) {
        final updatedNotes =
            state.notes.map((n) => n.id == updatedNote.id ? updatedNote : n).toList();
        emit(
          state.copyWith(
            notes: updatedNotes,
            editingNote: null,
            status: NotesStatus.loaded,
          ),
        );
      },
    );
  }

  Future<void> deleteNote(String noteId) async {
    final result = await _repository.deleteNote(noteId);
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: NotesStatus.error,
          errorMessage: failure.message,
        ),
      ),
      (_) {
        emit(
          state.copyWith(
            notes: state.notes.where((n) => n.id != noteId).toList(),
            status: NotesStatus.loaded,
          ),
        );
      },
    );
  }

  void toggleAddForm() {
    emit(state.copyWith(isAddingNote: !state.isAddingNote));
  }

  void setEditingNote(NoteItemEntity? note) {
    if (note != null && state.editingNote != null) {
      emit(state.copyWith(editingNote: null));
    }
    emit(state.copyWith(editingNote: note));
  }

  void setViewingNote(NoteItemEntity? note) {
    if (note != null && state.viewingNote != null) {
      emit(state.copyWith(viewingNote: null));
    }
    emit(state.copyWith(viewingNote: note));
  }
}
