import 'dart:io';
import 'package:atomic/core/errors/failures.dart';
import 'package:atomic/core/helpers/file_manager_helper.dart';
import 'package:atomic/core/helpers/functional_types.dart';
import 'package:atomic/core/helpers/prefs_helper.dart';
import 'package:atomic/features/notes_feature/domain/models/note_model.dart';
import 'package:atomic/features/notes_feature/domain/models/note_type.dart';
import 'package:dartz/dartz.dart';

abstract class NoteLocalDataSource {
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

class NoteLocalDataSourceImpl implements NoteLocalDataSource {
  final PrefsHelper _prefsHelper;
  final FileManagerHelper _fileManagerHelper;

  NoteLocalDataSourceImpl(this._prefsHelper, this._fileManagerHelper);

  @override
  FunctionalFuture<Failure, List<NoteModel>> getNotes() async {
    try {
      final notes = _prefsHelper.getNotes();
      return Right(notes);
    } catch (e) {
      return Left(DatabaseFailure('Failed to retrieve notes: $e'));
    }
  }

  @override
  FunctionalFuture<Failure, NoteModel> addTextNote(String content) async {
    try {
      final note = NoteModel(
        content: content,
        type: NoteType.text,
        createdAt: DateTime.now(),
      );

      final newNote = _prefsHelper.addNote(note);
      return Right(newNote);
    } catch (e) {
      return Left(DatabaseFailure('Failed to add text note: $e'));
    }
  }

  @override
  FunctionalFuture<Failure, NoteModel> addImageNote(
      String content, File imageFile) async {
    try {
      // Create note with temporary ID to get noteId for file naming
      final tempNote = NoteModel(
        content: content,
        type: NoteType.image,
        createdAt: DateTime.now(),
      );

      final noteId = tempNote.id!;

      // Save image file
      final imagePath =
          await _fileManagerHelper.saveImage(imageFile, noteId);

      // Create final note with image path
      final note = tempNote.copyWith(
        attachmentPath: imagePath,
      );

      final newNote = _prefsHelper.addNote(note);
      return Right(newNote);
    } catch (e) {
      return Left(DatabaseFailure('Failed to add image note: $e'));
    }
  }

  @override
  FunctionalFuture<Failure, NoteModel> addFileNote(
      String content, File file, String filename) async {
    try {
      // Create note with temporary ID to get noteId for file naming
      final tempNote = NoteModel(
        content: content,
        type: NoteType.file,
        createdAt: DateTime.now(),
      );

      final noteId = tempNote.id!;

      // Save file
      final filePath = await _fileManagerHelper.saveFile(file, noteId, filename);

      // Create final note with file path and name
      final note = tempNote.copyWith(
        attachmentPath: filePath,
        attachmentName: filename,
      );

      final newNote = _prefsHelper.addNote(note);
      return Right(newNote);
    } catch (e) {
      return Left(DatabaseFailure('Failed to add file note: $e'));
    }
  }

  @override
  FunctionalFuture<Failure, List<NoteModel>> updateNote(NoteModel note) async {
    try {
      final notes = _prefsHelper.updateNote(note);
      return Right(notes);
    } catch (e) {
      return Left(DatabaseFailure('Failed to update note: $e'));
    }
  }

  @override
  FunctionalFuture<Failure, List<NoteModel>> deleteNote(int noteId) async {
    try {
      // Get note first to delete associated file
      final notes = _prefsHelper.getNotes();
      final note = notes.firstWhere((n) => n.id == noteId,
          orElse: () => throw Exception('Note not found'));

      // Delete associated file if exists
      if (note.attachmentPath != null) {
        await _fileManagerHelper.deleteFile(note.attachmentPath!);
      }

      // Delete note from prefs
      final updatedNotes = _prefsHelper.deleteNote(noteId);
      return Right(updatedNotes);
    } catch (e) {
      return Left(DatabaseFailure('Failed to delete note: $e'));
    }
  }

  @override
  FunctionalFuture<Failure, List<NoteModel>> searchNotes(
      String query, DateTime? dateFilter) async {
    try {
      final notes = _prefsHelper.getNotes();

      // Filter by text content (case-insensitive)
      var filteredNotes = notes.where((note) {
        final contentMatch =
            note.content.toLowerCase().contains(query.toLowerCase());
        return contentMatch;
      }).toList();

      // Filter by date if provided
      if (dateFilter != null) {
        filteredNotes = filteredNotes.where((note) {
          final noteDate = DateTime(
            note.createdAt.year,
            note.createdAt.month,
            note.createdAt.day,
          );
          final filterDate = DateTime(
            dateFilter.year,
            dateFilter.month,
            dateFilter.day,
          );
          return noteDate.isAtSameMomentAs(filterDate);
        }).toList();
      }

      return Right(filteredNotes);
    } catch (e) {
      return Left(DatabaseFailure('Failed to search notes: $e'));
    }
  }
}
