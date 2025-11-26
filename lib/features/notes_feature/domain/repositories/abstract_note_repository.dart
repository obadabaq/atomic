import 'dart:io';
import 'package:atomic/core/errors/failures.dart';
import 'package:atomic/core/helpers/functional_types.dart';
import 'package:atomic/features/notes_feature/domain/models/note_model.dart';

abstract class AbstractNoteRepository {
  FunctionalFuture<Failure, List<NoteModel>> getNotes();
  FunctionalFuture<Failure, NoteModel> addTextNote(String content);
  FunctionalFuture<Failure, NoteModel> addImageNote(
      String content, File imageFile);
  FunctionalFuture<Failure, NoteModel> addFileNote(
      String content, File file, String filename);
  FunctionalFuture<Failure, List<NoteModel>> updateNote(NoteModel note);
  FunctionalFuture<Failure, List<NoteModel>> deleteNote(int noteId);
  FunctionalFuture<Failure, List<NoteModel>> searchNotes(
      String query, DateTime? dateFilter);
}
