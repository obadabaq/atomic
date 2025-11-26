import 'dart:io';
import 'package:path_provider/path_provider.dart';

class FileManagerHelper {
  /// Initialize directories for storing notes files
  Future<void> initializeDirectories() async {
    final appDir = await getApplicationDocumentsDirectory();
    final notesImagesDir = Directory('${appDir.path}/notes/images');
    final notesFilesDir = Directory('${appDir.path}/notes/files');

    if (!await notesImagesDir.exists()) {
      await notesImagesDir.create(recursive: true);
    }

    if (!await notesFilesDir.exists()) {
      await notesFilesDir.create(recursive: true);
    }
  }

  /// Save an image file and return the relative path
  Future<String> saveImage(File imageFile, int noteId) async {
    await initializeDirectories();

    final appDir = await getApplicationDocumentsDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final extension = imageFile.path.split('.').last;
    final fileName = '${noteId}_$timestamp.$extension';
    final savePath = '${appDir.path}/notes/images/$fileName';

    await imageFile.copy(savePath);

    // Return relative path
    return 'notes/images/$fileName';
  }

  /// Save a file and return the relative path
  Future<String> saveFile(File file, int noteId, String filename) async {
    await initializeDirectories();

    final appDir = await getApplicationDocumentsDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final extension = filename.split('.').last;
    final newFileName = '${noteId}_$timestamp.$extension';
    final savePath = '${appDir.path}/notes/files/$newFileName';

    await file.copy(savePath);

    // Return relative path
    return 'notes/files/$newFileName';
  }

  /// Delete a file from storage
  Future<void> deleteFile(String relativePath) async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final fullPath = '${appDir.path}/$relativePath';
      final file = File(fullPath);

      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      // Log error but don't throw - file might already be deleted
      print('Error deleting file: $e');
    }
  }

  /// Retrieve a file by its relative path
  Future<File?> getFile(String relativePath) async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final fullPath = '${appDir.path}/$relativePath';
      final file = File(fullPath);

      if (await file.exists()) {
        return file;
      }
      return null;
    } catch (e) {
      print('Error getting file: $e');
      return null;
    }
  }

  /// Get the full path from relative path
  Future<String> getFullPath(String relativePath) async {
    final appDir = await getApplicationDocumentsDirectory();
    return '${appDir.path}/$relativePath';
  }

  /// Check if file exists
  Future<bool> fileExists(String relativePath) async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final fullPath = '${appDir.path}/$relativePath';
      final file = File(fullPath);
      return await file.exists();
    } catch (e) {
      return false;
    }
  }
}
