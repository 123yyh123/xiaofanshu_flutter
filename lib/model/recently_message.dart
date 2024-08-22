class RecentlyMessage {
  static const String tableName = 'message_list';

  int? id;
  String userId;
  String avatarUrl;
  String userName;
  String lastMessage;
  int lastTime;
  int unreadNum;
  int stranger;

  RecentlyMessage({
    this.id,
    required this.userId,
    required this.avatarUrl,
    required this.userName,
    required this.lastMessage,
    required this.lastTime,
    required this.unreadNum,
    required this.stranger,
  });

  factory RecentlyMessage.fromJson(Map<String, dynamic> json) {
    return RecentlyMessage(
      id: json['id'],
      userId: json['user_id'],
      avatarUrl: json['avatar_url'],
      userName: json['user_name'],
      lastMessage: json['last_message'],
      lastTime: json['last_time'],
      unreadNum: json['unread_num'],
      stranger: json['stranger'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'avatar_url': avatarUrl,
      'user_name': userName,
      'last_message': lastMessage,
      'last_time': lastTime,
      'unread_num': unreadNum,
      'stranger': stranger,
    };
  }
}
