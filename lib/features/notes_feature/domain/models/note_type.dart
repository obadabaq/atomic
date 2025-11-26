enum NoteType {
  text,
  image,
  file;

  static NoteType fromString(String type) {
    switch (type) {
      case 'text':
        return NoteType.text;
      case 'image':
        return NoteType.image;
      case 'file':
        return NoteType.file;
      default:
        return NoteType.text;
    }
  }

  String toStoring() {
    return name;
  }
}
