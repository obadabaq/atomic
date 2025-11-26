import 'dart:io';
import 'package:atomic/core/abstracts/use_case.dart';
import 'package:atomic/core/errors/failures.dart';
import 'package:atomic/core/helpers/functional_types.dart';
import 'package:atomic/features/notes_feature/domain/models/note_model.dart';
import 'package:atomic/features/notes_feature/domain/repositories/abstract_note_repository.dart';

class NoteUseCase extends UseCase<List<NoteModel>, NoParams> {
  final AbstractNoteRepository _noteRepository;

  NoteUseCase(this._noteRepository);

  @override
  FunctionalFuture<Failure, List<NoteModel>> call(NoParams params) {
    return _noteRepository.getNotes();
  }

  FunctionalFuture<Failure, NoteModel> addTextNote(String content) {
    return _noteRepository.addTextNote(content);
  }

  FunctionalFuture<Failure, NoteModel> addImageNote(
      String content, File imageFile) {
    return _noteRepository.addImageNote(content, imageFile);
  }

  FunctionalFuture<Failure, NoteModel> addFileNote(
      String content, File file, String filename) {
    return _noteRepository.addFileNote(content, file, filename);
  }

  FunctionalFuture<Failure, List<NoteModel>> updateNote(NoteModel note) {
    return _noteRepository.updateNote(note);
  }

  FunctionalFuture<Failure, List<NoteModel>> deleteNote(int noteId) {
    return _noteRepository.deleteNote(noteId);
  }

  FunctionalFuture<Failure, List<NoteModel>> searchNotes(
      String query, DateTime? dateFilter) {
    return _noteRepository.searchNotes(query, dateFilter);
  }
}
