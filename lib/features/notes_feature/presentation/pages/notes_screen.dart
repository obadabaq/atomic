import 'package:atomic/core/constants/colors.dart';
import 'package:atomic/core/dependency_injection/locator.dart';
import 'package:atomic/core/helpers/file_manager_helper.dart';
import 'package:atomic/features/notes_feature/presentation/bloc/note_bloc.dart';
import 'package:atomic/features/notes_feature/presentation/bloc/note_event.dart';
import 'package:atomic/features/notes_feature/presentation/bloc/note_state.dart';
import 'package:atomic/features/notes_feature/presentation/widgets/add_note_dialog.dart';
import 'package:atomic/features/notes_feature/presentation/widgets/edit_note_dialog.dart';
import 'package:atomic/features/notes_feature/presentation/widgets/note_message_bubble.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:sizer/sizer.dart';

class NotesScreen extends StatefulWidget {
  const NotesScreen({Key? key}) : super(key: key);

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  final _searchController = TextEditingController();
  bool _isSearching = false;
  DateTime? _selectedDate;
  final _fileManagerHelper = sl<FileManagerHelper>();

  @override
  void initState() {
    super.initState();
    _fileManagerHelper.initializeDirectories();
    context.read<NoteBloc>().add(const OnGettingNotesEvent());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                style: const TextStyle(color: CustomColors.blackColor),
                decoration: const InputDecoration(
                  hintText: 'Search notes...',
                  hintStyle: TextStyle(color: Colors.black54),
                  border: InputBorder.none,
                ),
                onChanged: (query) {
                  if (query.isEmpty && _selectedDate == null) {
                    context.read<NoteBloc>().add(const OnClearingSearchEvent());
                  } else {
                    context.read<NoteBloc>().add(
                        OnSearchingNotesEvent(query, dateFilter: _selectedDate));
                  }
                },
              )
            : const Text('Notes'),
        backgroundColor: Colors.white,
        foregroundColor: CustomColors.blackColor,
        actions: [
          if (_isSearching) ...[
            IconButton(
              icon: const Icon(Icons.calendar_today),
              onPressed: _showDatePicker,
              tooltip: 'Filter by date',
            ),
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                setState(() {
                  _isSearching = false;
                  _searchController.clear();
                  _selectedDate = null;
                });
                context.read<NoteBloc>().add(const OnClearingSearchEvent());
              },
            ),
          ] else ...[
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {
                setState(() {
                  _isSearching = true;
                });
              },
            ),
          ],
        ],
      ),
      body: Column(
        children: [
          if (_selectedDate != null) _buildDateFilterChip(),
          Expanded(
            child: BlocConsumer<NoteBloc, NoteState>(
              listener: (context, state) {
                if (state is SuccessAddNoteState) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Note added successfully'),
                      backgroundColor: CustomColors.complementaryColor,
                      duration: Duration(seconds: 2),
                    ),
                  );
                } else if (state is SuccessUpdateNoteState) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Note updated successfully'),
                      backgroundColor: CustomColors.complementaryColor,
                      duration: Duration(seconds: 2),
                    ),
                  );
                } else if (state is SuccessDeleteNoteState) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Note deleted'),
                      backgroundColor: CustomColors.complementaryColor,
                      duration: Duration(seconds: 2),
                    ),
                  );
                } else if (state is ErrorNoteOperationState) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.error),
                      backgroundColor: CustomColors.redColor,
                      duration: const Duration(seconds: 3),
                    ),
                  );
                }
              },
              builder: (context, state) {
                if (state is NoteLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                final notes = state is SuccessSearchNotesState
                    ? state.filteredNotes
                    : state is SuccessGetNotesState
                        ? state.notes
                        : state is SuccessAddNoteState
                            ? state.notes
                            : state is SuccessUpdateNoteState
                                ? state.notes
                                : state is SuccessDeleteNoteState
                                    ? state.notes
                                    : [];

                if (notes.isEmpty) {
                  return _buildEmptyState(state is SuccessSearchNotesState);
                }

                // Sort notes by creation date (oldest first)
                final sortedNotes = List.from(notes)
                  ..sort((a, b) => a.createdAt.compareTo(b.createdAt));

                return RefreshIndicator(
                  onRefresh: () async {
                    context.read<NoteBloc>().add(const OnGettingNotesEvent());
                    if (_isSearching &&
                        (_searchController.text.isNotEmpty ||
                            _selectedDate != null)) {
                      context.read<NoteBloc>().add(OnSearchingNotesEvent(
                          _searchController.text,
                          dateFilter: _selectedDate));
                    }
                  },
                  child: ListView.builder(
                    reverse: false,
                    padding: EdgeInsets.only(bottom: 10.h, top: 1.h),
                    itemCount: sortedNotes.length,
                    itemBuilder: (context, index) {
                      final note = sortedNotes[index];
                      return NoteMessageBubble(
                        note: note,
                        fileManagerHelper: _fileManagerHelper,
                        onEdit: () {
                          showDialog(
                            context: context,
                            builder: (dialogContext) => BlocProvider.value(
                              value: context.read<NoteBloc>(),
                              child: EditNoteDialog(
                                note: note,
                                fileManagerHelper: _fileManagerHelper,
                              ),
                            ),
                          );
                        },
                        onDelete: () {
                          context
                              .read<NoteBloc>()
                              .add(OnDeletingNoteEvent(note.id!));
                        },
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (dialogContext) => BlocProvider.value(
              value: context.read<NoteBloc>(),
              child: const AddNoteDialog(),
            ),
          );
        },
        backgroundColor: CustomColors.primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildDateFilterChip() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
      color: CustomColors.primaryColor.withOpacity(0.1),
      child: Row(
        children: [
          Chip(
            label: Text(
              'Date: ${DateFormat('MMM d, yyyy').format(_selectedDate!)}',
              style: TextStyle(fontSize: 10.sp),
            ),
            deleteIcon: const Icon(Icons.close, size: 18),
            onDeleted: () {
              setState(() {
                _selectedDate = null;
              });
              if (_searchController.text.isEmpty) {
                context.read<NoteBloc>().add(const OnClearingSearchEvent());
              } else {
                context
                    .read<NoteBloc>()
                    .add(OnSearchingNotesEvent(_searchController.text));
              }
            },
            backgroundColor: CustomColors.primaryColor.withOpacity(0.2),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool isSearchResult) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isSearchResult ? Icons.search_off : Icons.note_outlined,
            size: 80.sp,
            color: CustomColors.neutralColor,
          ),
          SizedBox(height: 2.h),
          Text(
            isSearchResult ? 'No notes found' : 'No notes yet',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          SizedBox(height: 1.h),
          Text(
            isSearchResult
                ? 'Try a different search term'
                : 'Tap + to add your first note',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: CustomColors.neutralColor,
                ),
          ),
        ],
      ),
    );
  }

  Future<void> _showDatePicker() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: CustomColors.primaryColor,
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
      context.read<NoteBloc>().add(OnSearchingNotesEvent(
          _searchController.text,
          dateFilter: _selectedDate));
    }
  }
}
