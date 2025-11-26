import 'dart:io';
import 'package:atomic/features/notes_feature/domain/models/note_model.dart';

abstract class NoteEvent {
  const NoteEvent();
}

class OnGettingNotesEvent extends NoteEvent {
  const OnGettingNotesEvent();
}

class OnAddingTextNoteEvent extends NoteEvent {
  final String content;

  const OnAddingTextNoteEvent(this.content);
}

class OnAddingImageNoteEvent extends NoteEvent {
  final String content;
  final File imageFile;

  const OnAddingImageNoteEvent(this.content, this.imageFile);
}

class OnAddingFileNoteEvent extends NoteEvent {
  final String content;
  final File file;
  final String filename;

  const OnAddingFileNoteEvent(this.content, this.file, this.filename);
}

class OnUpdatingNoteEvent extends NoteEvent {
  final NoteModel noteModel;

  const OnUpdatingNoteEvent(this.noteModel);
}

class OnDeletingNoteEvent extends NoteEvent {
  final int noteId;

  const OnDeletingNoteEvent(this.noteId);
}

class OnSearchingNotesEvent extends NoteEvent {
  final String query;
  final DateTime? dateFilter;

  const OnSearchingNotesEvent(this.query, {this.dateFilter});
}

class OnClearingSearchEvent extends NoteEvent {
  const OnClearingSearchEvent();
}
