import 'dart:io';
import 'package:atomic/core/errors/failures.dart';
import 'package:atomic/core/helpers/functional_types.dart';
import 'package:atomic/features/notes_feature/data/sources/local_data_source.dart';
import 'package:atomic/features/notes_feature/domain/models/note_model.dart';
import 'package:atomic/features/notes_feature/domain/repositories/abstract_note_repository.dart';

class NoteRepositoryImpl extends AbstractNoteRepository {
  final NoteLocalDataSource _noteLocalDataSource;

  NoteRepositoryImpl(this._noteLocalDataSource);

  @override
  FunctionalFuture<Failure, List<NoteModel>> getNotes() {
    return _noteLocalDataSource.getNotes();
  }

  @override
  FunctionalFuture<Failure, NoteModel> addTextNote(String content) {
    return _noteLocalDataSource.addTextNote(content);
  }

  @override
  FunctionalFuture<Failure, NoteModel> addImageNote(
      String content, File imageFile) {
    return _noteLocalDataSource.addImageNote(content, imageFile);
  }

  @override
  FunctionalFuture<Failure, NoteModel> addFileNote(
      String content, File file, String filename) {
    return _noteLocalDataSource.addFileNote(content, file, filename);
  }

  @override
  FunctionalFuture<Failure, List<NoteModel>> updateNote(NoteModel note) {
    return _noteLocalDataSource.updateNote(note);
  }

  @override
  FunctionalFuture<Failure, List<NoteModel>> deleteNote(int noteId) {
    return _noteLocalDataSource.deleteNote(noteId);
  }

  @override
  FunctionalFuture<Failure, List<NoteModel>> searchNotes(
      String query, DateTime? dateFilter) {
    return _noteLocalDataSource.searchNotes(query, dateFilter);
  }
}
