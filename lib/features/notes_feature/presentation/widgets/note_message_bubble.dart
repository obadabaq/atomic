import 'dart:io';
import 'package:atomic/core/constants/colors.dart';
import 'package:atomic/core/helpers/file_manager_helper.dart';
import 'package:atomic/features/notes_feature/domain/models/note_model.dart';
import 'package:atomic/features/notes_feature/domain/models/note_type.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:open_filex/open_filex.dart';
import 'package:sizer/sizer.dart';

class NoteMessageBubble extends StatelessWidget {
  final NoteModel note;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final FileManagerHelper fileManagerHelper;

  const NoteMessageBubble({
    Key? key,
    required this.note,
    required this.onEdit,
    required this.onDelete,
    required this.fileManagerHelper,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
      child: GestureDetector(
        onLongPress: () => _showContextMenu(context),
        child: Align(
          alignment: Alignment.centerRight,
          child: Container(
            constraints: BoxConstraints(maxWidth: 75.w),
            decoration: BoxDecoration(
              color: CustomColors.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: CustomColors.primaryColor.withOpacity(0.2),
                width: 1,
              ),
            ),
            padding: EdgeInsets.all(2.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Content based on type
                _buildNoteContent(context),

                SizedBox(height: 1.h),

                // Timestamp and edited indicator
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      DateFormat('MMM d, h:mm a').format(note.createdAt),
                      style: TextStyle(
                        fontSize: 10.sp,
                        color: CustomColors.neutralColor.withOpacity(0.7),
                      ),
                    ),
                    if (note.editedAt != null) ...[
                      SizedBox(width: 1.w),
                      Text(
                        '(edited)',
                        style: TextStyle(
                          fontSize: 10.sp,
                          color: CustomColors.neutralColor.withOpacity(0.7),
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNoteContent(BuildContext context) {
    switch (note.type) {
      case NoteType.text:
        return Text(
          note.content,
          style: TextStyle(
            fontSize: 16.sp,
            color: CustomColors.blackColor,
          ),
        );

      case NoteType.image:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (note.content.isNotEmpty) ...[
              Text(
                note.content,
                style: TextStyle(
                  fontSize: 16.sp,
                  color: CustomColors.blackColor,
                ),
              ),
              SizedBox(height: 1.h),
            ],
            FutureBuilder<File?>(
              future: fileManagerHelper.getFile(note.attachmentPath!),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError || !snapshot.hasData) {
                  return Text(
                    'Image not found',
                    style: TextStyle(
                      fontSize: 10.sp,
                      color: CustomColors.redColor,
                      fontStyle: FontStyle.italic,
                    ),
                  );
                }
                return GestureDetector(
                  onTap: () => _showFullScreenImage(context, snapshot.data!),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(
                      snapshot.data!,
                      fit: BoxFit.cover,
                      width: double.infinity,
                    ),
                  ),
                );
              },
            ),
          ],
        );

      case NoteType.file:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (note.content.isNotEmpty) ...[
              Text(
                note.content,
                style: TextStyle(
                  fontSize: 16.sp,
                  color: CustomColors.blackColor,
                ),
              ),
              SizedBox(height: 1.h),
            ],
            GestureDetector(
              onTap: () => _openFile(context),
              child: Container(
                padding: EdgeInsets.all(2.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: CustomColors.neutralColor.withOpacity(0.3),
                  ),
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
                        note.attachmentName ?? 'Unknown file',
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: CustomColors.blackColor,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Icon(
                      Icons.open_in_new,
                      color: CustomColors.neutralColor,
                      size: 16.sp,
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
    }
  }

  void _showContextMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext bottomSheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.copy),
                title: const Text('Copy'),
                onTap: () {
                  Clipboard.setData(ClipboardData(text: note.content));
                  Navigator.pop(bottomSheetContext);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Copied to clipboard')),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text('Edit'),
                onTap: () {
                  Navigator.pop(bottomSheetContext);
                  onEdit();
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Delete', style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.pop(bottomSheetContext);
                  _showDeleteConfirmation(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Note'),
        content: const Text('Are you sure you want to delete this note?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              onDelete();
              Navigator.pop(dialogContext);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: CustomColors.redColor,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showFullScreenImage(BuildContext context, File imageFile) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            automaticallyImplyLeading: false,
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
            title: const Text('Image Viewer'),
            leading: IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          body: Center(
            child: InteractiveViewer(
              minScale: 0.5,
              maxScale: 4.0,
              child: Image.file(imageFile),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _openFile(BuildContext context) async {
    try {
      final file = await fileManagerHelper.getFile(note.attachmentPath!);
      if (file == null) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('File not found'),
              backgroundColor: CustomColors.redColor,
            ),
          );
        }
        return;
      }

      final result = await OpenFilex.open(file.path);

      if (result.type != ResultType.done && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.message ?? 'Could not open file'),
            backgroundColor: CustomColors.redColor,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error opening file: $e'),
            backgroundColor: CustomColors.redColor,
          ),
        );
      }
    }
  }
}
