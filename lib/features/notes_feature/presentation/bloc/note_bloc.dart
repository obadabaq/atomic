import 'package:atomic/core/abstracts/use_case.dart';
import 'package:atomic/features/notes_feature/domain/models/note_model.dart';
import 'package:atomic/features/notes_feature/domain/usecases/note_use_case.dart';
import 'package:atomic/features/notes_feature/presentation/bloc/note_event.dart';
import 'package:atomic/features/notes_feature/presentation/bloc/note_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class NoteBloc extends Bloc<NoteEvent, NoteState> {
  final NoteUseCase noteUseCase;

  List<NoteModel> _cachedNotes = [];
  List<NoteModel> _filteredNotes = [];
  String _currentQuery = '';
  DateTime? _currentDateFilter;

  NoteBloc({required this.noteUseCase}) : super(NoteInitial()) {
    on<OnGettingNotesEvent>(_onGettingNotesEvent);
    on<OnAddingTextNoteEvent>(_onAddingTextNoteEvent);
    on<OnAddingImageNoteEvent>(_onAddingImageNoteEvent);
    on<OnAddingFileNoteEvent>(_onAddingFileNoteEvent);
    on<OnUpdatingNoteEvent>(_onUpdatingNoteEvent);
    on<OnDeletingNoteEvent>(_onDeletingNoteEvent);
    on<OnSearchingNotesEvent>(_onSearchingNotesEvent);
    on<OnClearingSearchEvent>(_onClearingSearchEvent);
  }

  // Helper method to check if search is active
  bool isSearchActive() {
    return _currentQuery.isNotEmpty || _currentDateFilter != null;
  }

  Future<void> _onGettingNotesEvent(
      OnGettingNotesEvent event, Emitter<NoteState> emitter) async {
    emitter(NoteLoading());
    final result = await noteUseCase.call(NoParams());
    result.fold(
      (failure) => emitter(ErrorNoteOperationState(failure.error)),
      (notes) {
        _cachedNotes = notes;
        emitter(SuccessGetNotesState(notes));
      },
    );
  }

  Future<void> _onAddingTextNoteEvent(
      OnAddingTextNoteEvent event, Emitter<NoteState> emitter) async {
    emitter(NoteLoading());
    final result = await noteUseCase.addTextNote(event.content);

    final newNote = result.fold(
      (failure) {
        emitter(ErrorNoteOperationState(failure.error));
        return null;
      },
      (note) => note,
    );

    if (newNote == null) return;

    // Refresh the list after adding
    final notesResult = await noteUseCase.call(NoParams());
    notesResult.fold(
      (failure) => emitter(ErrorNoteOperationState(failure.error)),
      (notes) {
        _cachedNotes = notes;
        emitter(SuccessAddNoteState(notes));
      },
    );
  }

  Future<void> _onAddingImageNoteEvent(
      OnAddingImageNoteEvent event, Emitter<NoteState> emitter) async {
    emitter(NoteLoading());
    final result =
        await noteUseCase.addImageNote(event.content, event.imageFile);

    final newNote = result.fold(
      (failure) {
        emitter(ErrorNoteOperationState(failure.error));
        return null;
      },
      (note) => note,
    );

    if (newNote == null) return;

    // Refresh the list after adding
    final notesResult = await noteUseCase.call(NoParams());
    notesResult.fold(
      (failure) => emitter(ErrorNoteOperationState(failure.error)),
      (notes) {
        _cachedNotes = notes;
        emitter(SuccessAddNoteState(notes));
      },
    );
  }

  Future<void> _onAddingFileNoteEvent(
      OnAddingFileNoteEvent event, Emitter<NoteState> emitter) async {
    emitter(NoteLoading());
    final result = await noteUseCase.addFileNote(
        event.content, event.file, event.filename);

    final newNote = result.fold(
      (failure) {
        emitter(ErrorNoteOperationState(failure.error));
        return null;
      },
      (note) => note,
    );

    if (newNote == null) return;

    // Refresh the list after adding
    final notesResult = await noteUseCase.call(NoParams());
    notesResult.fold(
      (failure) => emitter(ErrorNoteOperationState(failure.error)),
      (notes) {
        _cachedNotes = notes;
        emitter(SuccessAddNoteState(notes));
      },
    );
  }

  Future<void> _onUpdatingNoteEvent(
      OnUpdatingNoteEvent event, Emitter<NoteState> emitter) async {
    emitter(NoteLoading());
    final result = await noteUseCase.updateNote(event.noteModel);
    result.fold(
      (failure) => emitter(ErrorNoteOperationState(failure.error)),
      (notes) {
        _cachedNotes = notes;
        // If search is active, re-apply the search
        if (isSearchActive()) {
          add(OnSearchingNotesEvent(_currentQuery,
              dateFilter: _currentDateFilter));
        } else {
          emitter(SuccessUpdateNoteState(notes));
        }
      },
    );
  }

  Future<void> _onDeletingNoteEvent(
      OnDeletingNoteEvent event, Emitter<NoteState> emitter) async {
    emitter(NoteLoading());
    final result = await noteUseCase.deleteNote(event.noteId);
    result.fold(
      (failure) => emitter(ErrorNoteOperationState(failure.error)),
      (notes) {
        _cachedNotes = notes;
        // If search is active, re-apply the search
        if (isSearchActive()) {
          add(OnSearchingNotesEvent(_currentQuery,
              dateFilter: _currentDateFilter));
        } else {
          emitter(SuccessDeleteNoteState(notes));
        }
      },
    );
  }

  Future<void> _onSearchingNotesEvent(
      OnSearchingNotesEvent event, Emitter<NoteState> emitter) async {
    emitter(NoteLoading());
    _currentQuery = event.query;
    _currentDateFilter = event.dateFilter;

    final result =
        await noteUseCase.searchNotes(event.query, event.dateFilter);
    result.fold(
      (failure) => emitter(ErrorNoteOperationState(failure.error)),
      (filteredNotes) {
        _filteredNotes = filteredNotes;
        emitter(SuccessSearchNotesState(filteredNotes, event.query));
      },
    );
  }

  Future<void> _onClearingSearchEvent(
      OnClearingSearchEvent event, Emitter<NoteState> emitter) async {
    _currentQuery = '';
    _currentDateFilter = null;
    _filteredNotes = [];
    emitter(SuccessGetNotesState(_cachedNotes));
  }
}
