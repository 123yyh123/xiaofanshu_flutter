import 'dart:convert';

import 'package:xiaofanshu_flutter/enum/chat_type.dart';
import 'package:xiaofanshu_flutter/enum/message_type.dart';

class WebsocketMessageVo {
  int? id;

  // 发送者id
  String? from;

  // 发送者名称
  String? fromName;

  // 发送者头像
  String? fromAvatar;

  // 接收者id
  String? to;

  // 消息内容
  String? content;

  // 发送时间
  int? time;

  // 0:连接信息，1:心跳信息，2:系统信息，3:聊天信息，4:新增关注信息，5:服务器应答信息，6:token鉴权信息，7:@消息，8:赞与收藏信息
  int messageType;

  // 0:不是聊天信息，1:文本信息，2:图片信息，3:文件信息，4:语音信息，5:视频信息，6:大表情信息
  int? chatType;

  // 0:好友消息，1:陌生人消息
  int? friendType;

  // 语音时长，单位秒
  int? audioTime;

  WebsocketMessageVo({
    this.id,
    this.from,
    this.fromName,
    this.fromAvatar,
    this.to,
    this.content,
    this.time,
    required this.messageType,
    this.chatType,
    this.friendType,
    this.audioTime,
  });

  static String loginMessage(String from) {
    return jsonEncode({
      'from': from,
      'messageType': MessageType.connect,
    });
  }

  static String heartBeatMessage(String from, String token) {
    return jsonEncode({
      'from': from,
      'content': token,
      'messageType': MessageType.heartBeat,
    });
  }

  static Map<String, dynamic> chatLocalTextMessage(
      String from, String to, String content) {
    return {
      'from_id': from,
      'to_id': to,
      'content': content,
      'time': DateTime.now().millisecondsSinceEpoch,
      'chat_type': ChatType.text,
      'is_read': 1,
      'is_send': 0,
      'audio_time': 0,
    };
  }

  static Map<String, dynamic> chatLocalEmojiMessage(
      String from, String to, String content) {
    return {
      'from_id': from,
      'to_id': to,
      'content': content,
      'time': DateTime.now().millisecondsSinceEpoch,
      'chat_type': ChatType.emoji,
      'is_read': 1,
      'is_send': 0,
      'audio_time': 0,
    };
  }

  static Map<String, dynamic> chatServerTextMessage(int id, String from,
      String fromName, String fromAvatar, String to, String content) {
    return {
      'id': id,
      'from': from,
      'fromName': fromName,
      'fromAvatar': fromAvatar,
      'to': to,
      'content': content,
      'time': DateTime.now().millisecondsSinceEpoch,
      'messageType': MessageType.chat,
      'chatType': ChatType.text,
      'friendType': 0,
      'audioTime': 0,
    };
  }

  static Map<String, dynamic> chatServerEmojiMessage(int id, String from,
      String fromName, String fromAvatar, String to, String content) {
    return {
      'id': id,
      'from': from,
      'fromName': fromName,
      'fromAvatar': fromAvatar,
      'to': to,
      'content': content,
      'time': DateTime.now().millisecondsSinceEpoch,
      'messageType': MessageType.chat,
      'chatType': ChatType.emoji,
      'friendType': 0,
      'audioTime': 0,
    };
  }

  static Map<String, dynamic> chatLocalAudioMessage(
      String from, String to, String content, int audioTime) {
    return {
      'from_id': from,
      'to_id': to,
      'content': content,
      'time': DateTime.now().millisecondsSinceEpoch,
      'chat_type': ChatType.audio,
      'is_read': 1,
      'is_send': 0,
      'audio_time': audioTime,
    };
  }

  static Map<String, dynamic> chatServerAudioMessage(
      int id,
      String from,
      String fromName,
      String fromAvatar,
      String to,
      String content,
      int audioTime) {
    return {
      'id': id,
      'from': from,
      'fromName': fromName,
      'fromAvatar': fromAvatar,
      'to': to,
      'content': content,
      'time': DateTime.now().millisecondsSinceEpoch,
      'messageType': MessageType.chat,
      'chatType': ChatType.audio,
      'friendType': 0,
      'audioTime': audioTime,
    };
  }

  static Map<String, dynamic> chatLocalImageMessage(
      String from, String to, String content) {
    return {
      'from_id': from,
      'to_id': to,
      'content': content,
      'time': DateTime.now().millisecondsSinceEpoch,
      'chat_type': ChatType.image,
      'is_read': 1,
      'is_send': 0,
      'audio_time': 0,
    };
  }

  static Map<String, dynamic> chatServerImageMessage(int id, String from,
      String fromName, String fromAvatar, String to, String content) {
    return {
      'id': id,
      'from': from,
      'fromName': fromName,
      'fromAvatar': fromAvatar,
      'to': to,
      'content': content,
      'time': DateTime.now().millisecondsSinceEpoch,
      'messageType': MessageType.chat,
      'chatType': ChatType.image,
      'friendType': 0,
      'audioTime': 0,
    };
  }

  static Map<String, dynamic> chatLocalVideoMessage(
      String from, String to, String content) {
    return {
      'from_id': from,
      'to_id': to,
      'content': content,
      'time': DateTime.now().millisecondsSinceEpoch,
      'chat_type': ChatType.video,
      'is_read': 1,
      'is_send': 0,
      'audio_time': 0,
    };
  }

  static Map<String, dynamic> chatServerVideoMessage(int id, String from,
      String fromName, String fromAvatar, String to, String content) {
    return {
      'id': id,
      'from': from,
      'fromName': fromName,
      'fromAvatar': fromAvatar,
      'to': to,
      'content': content,
      'time': DateTime.now().millisecondsSinceEpoch,
      'messageType': MessageType.chat,
      'chatType': ChatType.video,
      'friendType': 0,
      'audioTime': 0,
    };
  }
}
