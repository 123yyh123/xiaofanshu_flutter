// 0:连接信息，1:心跳信息，2:系统信息，3:聊天信息，4:新增关注信息，5:服务器应答信息，6:token鉴权信息，7:@消息，8:赞与收藏信息

class MessageType {
  static const int connect = 0;
  static const int heartBeat = 1;
  static const int system = 2;
  static const int chat = 3;
  static const int follow = 4;
  static const int serverAnswer = 5;
  static const int tokenAuth = 6;
  static const int at = 7;
  static const int likeAndCollect = 8;
}
