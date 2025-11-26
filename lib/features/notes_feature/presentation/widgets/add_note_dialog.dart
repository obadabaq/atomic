import 'dart:io';
import 'package:atomic/core/constants/colors.dart';
import 'package:atomic/features/notes_feature/presentation/bloc/note_bloc.dart';
import 'package:atomic/features/notes_feature/presentation/bloc/note_event.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sizer/sizer.dart';

class AddNoteDialog extends StatefulWidget {
  const AddNoteDialog({Key? key}) : super(key: key);

  @override
  State<AddNoteDialog> createState() => _AddNoteDialogState();
}

class _AddNoteDialogState extends State<AddNoteDialog> {
  final _formKey = GlobalKey<FormState>();
  final _contentController = TextEditingController();
  final _imagePicker = ImagePicker();

  File? _selectedImage;
  File? _selectedFile;
  String? _selectedFileName;

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Note'),
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
                  if ((value == null || value.trim().isEmpty) &&
                      _selectedImage == null &&
                      _selectedFile == null) {
                    return 'Please enter text or attach a file/image';
                  }
                  return null;
                },
              ),
              SizedBox(height: 2.h),

              // Attachment section
              if (_selectedImage != null) _buildImagePreview(),
              if (_selectedFile != null) _buildFilePreview(),

              SizedBox(height: 2.h),

              // Attachment buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildAttachmentButton(
                    icon: Icons.image,
                    label: 'Image',
                    onPressed: _pickImage,
                    isSelected: _selectedImage != null,
                  ),
                  _buildAttachmentButton(
                    icon: Icons.attach_file,
                    label: 'File',
                    onPressed: _pickFile,
                    isSelected: _selectedFile != null,
                  ),
                ],
              ),
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
          child: const Text('Add'),
        ),
      ],
    );
  }

  Widget _buildAttachmentButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    required bool isSelected,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 16.sp),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor:
            isSelected ? CustomColors.primaryColor : CustomColors.neutralColor,
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
      ),
    );
  }

  Widget _buildImagePreview() {
    return Container(
      margin: EdgeInsets.only(top: 1.h),
      decoration: BoxDecoration(
        border: Border.all(color: CustomColors.primaryColor),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.file(
              _selectedImage!,
              height: 20.h,
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            top: 1.w,
            right: 1.w,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white),
              onPressed: () {
                setState(() {
                  _selectedImage = null;
                });
              },
              style: IconButton.styleFrom(
                backgroundColor: Colors.black54,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilePreview() {
    return Container(
      margin: EdgeInsets.only(top: 1.h),
      padding: EdgeInsets.all(2.w),
      decoration: BoxDecoration(
        border: Border.all(color: CustomColors.primaryColor),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(Icons.attach_file, color: CustomColors.primaryColor),
          SizedBox(width: 2.w),
          Expanded(
            child: Text(
              _selectedFileName ?? 'Unknown file',
              style: TextStyle(fontSize: 11.sp),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.red),
            onPressed: () {
              setState(() {
                _selectedFile = null;
                _selectedFileName = null;
              });
            },
          ),
        ],
      ),
    );
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
          // Clear file selection if image is selected
          _selectedFile = null;
          _selectedFileName = null;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to pick image: $e')),
        );
      }
    }
  }

  Future<void> _pickFile() async {
    try {
      final FilePickerResult? result = await FilePicker.platform.pickFiles();

      if (result != null && result.files.single.path != null) {
        setState(() {
          _selectedFile = File(result.files.single.path!);
          _selectedFileName = result.files.single.name;
          // Clear image selection if file is selected
          _selectedImage = null;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to pick file: $e')),
        );
      }
    }
  }

  void _handleSave() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final content = _contentController.text.trim();

    if (_selectedImage != null) {
      // Add image note
      context
          .read<NoteBloc>()
          .add(OnAddingImageNoteEvent(content, _selectedImage!));
    } else if (_selectedFile != null) {
      // Add file note
      context.read<NoteBloc>().add(
          OnAddingFileNoteEvent(content, _selectedFile!, _selectedFileName!));
    } else {
      // Add text-only note
      context.read<NoteBloc>().add(OnAddingTextNoteEvent(content));
    }

    Navigator.pop(context);
  }
}
