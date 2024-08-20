class DraftNotes {
  static String tableName = 'draft_notes';

  int? id;
  String? title;
  String? content;
  int type;
  String filesPath;
  String? coverPath;
  int authority;
  String? address;
  int? createTime;

  DraftNotes({
    this.id,
    this.title,
    this.content,
    required this.type,
    required this.filesPath,
    this.coverPath,
    required this.authority,
    this.address,
    this.createTime,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'content': content,
      'type': type,
      'filesPath': filesPath,
      'coverPath': coverPath,
      'authority': authority,
      'address': address,
    };
  }

  factory DraftNotes.fromMap(Map<String, dynamic> map) {
    return DraftNotes(
      id: map['id'],
      title: map['title'],
      content: map['content'],
      type: map['type'],
      filesPath: map['filesPath'],
      coverPath: map['coverPath'],
      authority: map['authority'],
      address: map['address'],
      createTime: DateTime.parse(map['createTime']).millisecondsSinceEpoch,
    );
  }
}
