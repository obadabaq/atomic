import 'dart:math';
import 'package:atomic/features/notes_feature/domain/models/note_type.dart';

class NoteModel {
  int? id;
  final String content;
  final NoteType type;
  final String? attachmentPath;
  final String? attachmentName;
  final DateTime createdAt;
  final DateTime? editedAt;

  NoteModel({
    this.id,
    required this.content,
    required this.type,
    this.attachmentPath,
    this.attachmentName,
    required this.createdAt,
    this.editedAt,
  }) {
    id ??= 10000 + Random().nextInt(90000);
  }

  factory NoteModel.fromJson(Map<String, dynamic> json) {
    return NoteModel(
      id: json['id'] as int,
      content: json['content'] as String,
      type: NoteType.fromString(json['type'] as String),
      attachmentPath: json['attachmentPath'] as String?,
      attachmentName: json['attachmentName'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      editedAt: json['editedAt'] != null
          ? DateTime.parse(json['editedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'type': type.toStoring(),
      'attachmentPath': attachmentPath,
      'attachmentName': attachmentName,
      'createdAt': createdAt.toIso8601String(),
      'editedAt': editedAt?.toIso8601String(),
    };
  }

  NoteModel copyWith({
    int? id,
    String? content,
    NoteType? type,
    String? attachmentPath,
    String? attachmentName,
    DateTime? createdAt,
    DateTime? editedAt,
  }) {
    return NoteModel(
      id: id ?? this.id,
      content: content ?? this.content,
      type: type ?? this.type,
      attachmentPath: attachmentPath ?? this.attachmentPath,
      attachmentName: attachmentName ?? this.attachmentName,
      createdAt: createdAt ?? this.createdAt,
      editedAt: editedAt ?? this.editedAt,
    );
  }
}
