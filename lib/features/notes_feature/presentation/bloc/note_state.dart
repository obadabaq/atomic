import 'package:atomic/features/notes_feature/domain/models/note_model.dart';

abstract class NoteState {
  const NoteState();
}

class NoteInitial extends NoteState {}

class NoteLoading extends NoteState {}

class SuccessGetNotesState extends NoteState {
  final List<NoteModel> notes;

  const SuccessGetNotesState(this.notes);
}

class SuccessAddNoteState extends NoteState {
  final List<NoteModel> notes;

  const SuccessAddNoteState(this.notes);
}

class SuccessUpdateNoteState extends NoteState {
  final List<NoteModel> notes;

  const SuccessUpdateNoteState(this.notes);
}

class SuccessDeleteNoteState extends NoteState {
  final List<NoteModel> notes;

  const SuccessDeleteNoteState(this.notes);
}

class SuccessSearchNotesState extends NoteState {
  final List<NoteModel> filteredNotes;
  final String query;

  const SuccessSearchNotesState(this.filteredNotes, this.query);
}

class ErrorNoteOperationState extends NoteState {
  final String error;

  const ErrorNoteOperationState(this.error);
}
