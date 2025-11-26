import 'package:atomic/features/notes_feature/domain/models/note_model.dart';

class NoteEntity extends NoteModel {
  NoteEntity({
    required super.id,
    required super.content,
    required super.type,
    super.attachmentPath,
    super.attachmentName,
    required super.createdAt,
    super.editedAt,
  });

  factory NoteEntity.fromModel(NoteModel model) {
    return NoteEntity(
      id: model.id,
      content: model.content,
      type: model.type,
      attachmentPath: model.attachmentPath,
      attachmentName: model.attachmentName,
      createdAt: model.createdAt,
      editedAt: model.editedAt,
    );
  }
}
