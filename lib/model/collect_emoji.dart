class CollectEmoji {
  static const String table = 'collect_emoji';

  int id;
  int time;
  String fileUrl;
  String networkUrl;

  CollectEmoji(
      {required this.id,
      required this.time,
      required this.fileUrl,
      required this.networkUrl});

  factory CollectEmoji.fromJson(Map<String, dynamic> json) {
    return CollectEmoji(
      id: json['id'],
      time: json['time'],
      fileUrl: json['fileUrl'],
      networkUrl: json['networkUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'time': time,
      'fileUrl': fileUrl,
      'networkUrl': networkUrl,
    };
  }
}
