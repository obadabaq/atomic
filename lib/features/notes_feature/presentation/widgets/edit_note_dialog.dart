import 'dart:io';
import 'package:atomic/core/constants/colors.dart';
import 'package:atomic/core/helpers/file_manager_helper.dart';
import 'package:atomic/features/notes_feature/domain/models/note_model.dart';
import 'package:atomic/features/notes_feature/domain/models/note_type.dart';
import 'package:atomic/features/notes_feature/presentation/bloc/note_bloc.dart';
import 'package:atomic/features/notes_feature/presentation/bloc/note_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sizer/sizer.dart';

class EditNoteDialog extends StatefulWidget {
  final NoteModel note;
  final FileManagerHelper fileManagerHelper;

  const EditNoteDialog({
    Key? key,
    required this.note,
    required this.fileManagerHelper,
  }) : super(key: key);

  @override
  State<EditNoteDialog> createState() => _EditNoteDialogState();
}

class _EditNoteDialogState extends State<EditNoteDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _contentController;

  @override
  void initState() {
    super.initState();
    _contentController = TextEditingController(text: widget.note.content);
  }

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Note'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _contentController,
                decoration: const InputDecoration(
                  labelText: 'Note Content',
                  hintText: 'Enter your note...',
                  border: OutlineInputBorder(),
                ),
                maxLines: 5,
                autofocus: true,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter note content';
                  }
                  return null;
                },
              ),
              SizedBox(height: 2.h),

              // Show attachment preview (read-only)
              if (widget.note.type == NoteType.image)
                _buildImageAttachment(),
              if (widget.note.type == NoteType.file)
                _buildFileAttachment(),

              if (widget.note.type != NoteType.text) ...[
                SizedBox(height: 1.h),
                Text(
                  'Note: Attachments cannot be changed',
                  style: TextStyle(
                    fontSize: 9.sp,
                    color: CustomColors.neutralColor,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _handleSave,
          style: ElevatedButton.styleFrom(
            backgroundColor: CustomColors.primaryColor,
            foregroundColor: Colors.white,
          ),
          child: const Text('Save'),
        ),
      ],
    );
  }

  Widget _buildImageAttachment() {
    return FutureBuilder<File?>(
      future: widget.fileManagerHelper.getFile(widget.note.attachmentPath!),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError || !snapshot.hasData) {
          return Container(
            padding: EdgeInsets.all(2.w),
            decoration: BoxDecoration(
              border: Border.all(color: CustomColors.redColor),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'Image not found',
              style: TextStyle(
                fontSize: 10.sp,
                color: CustomColors.redColor,
              ),
            ),
          );
        }
        return Container(
          decoration: BoxDecoration(
            border: Border.all(color: CustomColors.neutralColor),
            borderRadius: BorderRadius.circular(8),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.file(
              snapshot.data!,
              height: 15.h,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
        );
      },
    );
  }

  Widget _buildFileAttachment() {
    return Container(
      padding: EdgeInsets.all(2.w),
      decoration: BoxDecoration(
        border: Border.all(color: CustomColors.neutralColor),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            Icons.attach_file,
            color: CustomColors.primaryColor,
            size: 18.sp,
          ),
          SizedBox(width: 2.w),
          Expanded(
            child: Text(
              widget.note.attachmentName ?? 'Unknown file',
              style: TextStyle(
                fontSize: 11.sp,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  void _handleSave() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final updatedNote = widget.note.copyWith(
      content: _contentController.text.trim(),
    );

    context.read<NoteBloc>().add(OnUpdatingNoteEvent(updatedNote));
    Navigator.pop(context);
  }
}
