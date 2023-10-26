class Note {
  final int id;
  final String content;

  Note({this.id = 0, required this.content});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'content': content,
    };
  }

  factory Note.fromSqfliteDatabase(Map<String, dynamic> map) => Note(
        id: map['id']?.toInt() ?? 0,
        content: map['content'] ?? '',
      );
}
