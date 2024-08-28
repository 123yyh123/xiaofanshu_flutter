import 'dart:async';
import 'dart:convert';
import 'package:get/get.dart';
import 'package:tencent_calls_uikit/tencent_calls_uikit.dart';
import 'package:tencent_calls_uikit/tuicall_kit.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:xiaofanshu_flutter/apis/app.dart';
import 'package:xiaofanshu_flutter/config/base_request.dart';
import 'package:xiaofanshu_flutter/controller/chat_controller.dart';
import 'package:xiaofanshu_flutter/controller/home_controller.dart';
import 'package:xiaofanshu_flutter/controller/recently_message_controller.dart';
import 'package:xiaofanshu_flutter/mapper/chat_message_mapper.dart';
import 'package:xiaofanshu_flutter/mapper/recently_message_mapper.dart';
import 'package:xiaofanshu_flutter/model/response.dart';
import 'package:xiaofanshu_flutter/model/user.dart';
import 'package:xiaofanshu_flutter/model/websocket_message_vo.dart';
import 'package:xiaofanshu_flutter/static/custom_code.dart';
import 'package:xiaofanshu_flutter/utils/db_util.dart';
import 'package:xiaofanshu_flutter/utils/snackbar_util.dart';
import 'package:xiaofanshu_flutter/utils/store_util.dart';
import 'package:synchronized/synchronized.dart';

import '../model/recently_message.dart';
import '../static/default_data.dart';

class WebSocketManager {
  late WebSocketChannel _channel;
  final String _serverUrl = BaseRequest.wsUrl; //ws连接路径
  bool _isConnected = false; //连接状态
  bool _isManuallyDisconnected = false; //是否为主动断开
  late Timer _heartbeatTimer; //心跳定时器
  late Timer _reconnectTimer; //重新连接定时器
  final Duration _reconnectInterval = const Duration(seconds: 5); //重新连接间隔时间
  StreamController<String> _messageController = StreamController<String>();
  final _lock = Lock();

  Stream<String> get messageStream => _messageController.stream; //监听的消息
  late String token;
  late User userInfo;

  // 定时器，10秒内服务器未应答,没有将对应的消息定时器清除，将对应的消息状态设置为发送失败
  Map<String, Timer> _timerMap = {};

  //初始化
  WebSocketManager() {
    Get.log('初始化');
    _heartbeatTimer = Timer(const Duration(seconds: 0), () {});
    _startConnection();
  }

  //建立连接
  void _startConnection() async {
    try {
      userInfo = User.fromJson(jsonDecode(
          await readData('userInfo') ?? jsonEncode(DefaultData.user)));
      if (userInfo.id == 1) {
        return;
      }
      token = await readData('token') ?? '';
      if (token.isEmpty) {
        return;
      }
      Get.log('userId: ${userInfo.id}, token: $token');
      _channel = WebSocketChannel.connect(Uri.parse(_serverUrl));
      Get.log('建立连接');
      _isConnected = true;
      _channel.stream.listen(
        (data) {
          _isConnected = true;
          Get.log('已连接$data');
          _handlerMessage(data);
        },
        onError: (error) {
          // 处理连接错误
          Get.log('连接错误: $error');
          _onError(error);
        },
        onDone: _onDone,
      );
      _startHeartbeat(); //开始心跳
      _sendInitialData(); // 连接成功后发送登录信息();
      loginTrtc(); // 登录TRTC
      // 停止重连定时器
      try {
        if (_reconnectTimer.isActive) {
          _reconnectTimer.cancel();
        }
      } catch (e) {
        // 说明还没有被初始化
      }
    } catch (e) {
      // 连接错误处理
      Get.log('连接异常错误: $e');
      _onError(e);
    }
  }

  //断开连接
  void disconnect() {
    Get.log('断开连接');
    _isConnected = false;
    _isManuallyDisconnected = true;
    try {
      _logoutTrtc();
      _stopHeartbeat();
      _messageController.close();
      _channel.sink.close();
    } catch (e) {
      Get.log('断开连接成功');
    }
  }

  //开始心跳
  void _startHeartbeat() {
    try {
      if (_heartbeatTimer.isActive) {
        _heartbeatTimer.cancel();
      }
    } catch (e) {
      // 说明还没有被初始化
    }
    _heartbeatTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      sendHeartbeat();
    });
  }

  //停止心跳
  void _stopHeartbeat() {
    _heartbeatTimer.cancel();
  }

  //重置心跳
  void _resetHeartbeat() {
    _stopHeartbeat();
    _startHeartbeat(); //开始心跳
  }

  // 发送心跳消息到服务器
  void sendHeartbeat() {
    if (_isConnected) {
      String message =
          WebsocketMessageVo.heartBeatMessage(userInfo.id.toString(), token);
      _channel.sink.add(message); // 发送 JSON 字符串
      Get.log('连接成功发送心跳消息到服务器$message');
    }
  }

  // 登录
  void _sendInitialData() async {
    try {
      String message = WebsocketMessageVo.loginMessage(userInfo.id.toString());
      _channel.sink.add(message); // 发送 JSON 字符串
      Get.log('连接成功-发送登录信息$message');
    } catch (e) {
      // 连接错误处理
      Get.log('连接异常错误: $e');
      _onError(e);
    }
  }

  Future<void> loginTrtc() async {
    if (userInfo.id == 1) {
      return;
    }
    if (token.isEmpty) {
      return;
    }
    if (!_isConnected) {
      return;
    }
    HttpResponse response =
        await AuthApi.getTrtcUserSig(userInfo.id.toString());
    if (response.code == StatusCode.postSuccess) {
      Map<String, dynamic> data = response.data;
      int appId = int.parse(data['sdkAppId'].toString());
      String userSig = data['userSig'].toString();
      TUIResult result = await TUICallKit.instance
          .login(appId, userInfo.id.toString(), userSig);
      if (result.code.isEmpty) {
        Get.log('登录成功');
        await TUICallKit.instance
            .setSelfInfo(userInfo.nickname, userInfo.avatarUrl);
        await TUICallKit.instance.enableFloatWindow(true);
        await TUICallKit.instance.enableVirtualBackground(true);
      } else {
        Get.log('登录失败, code: ${result.code}, message: ${result.message}');
      }
    }
  }

  // 退出Trtc
  Future<void> _logoutTrtc() async {
    await TUICallKit.instance.logout();
  }

  //发送信息
  void sendMessage(Map<String, dynamic> data) {
    Get.log('发送信息$data');
    if (data['messageType'] == 3) {
      // 设置定时器，如果超过10秒，没有把该定时器清除，就认为发送失败
      var timer = Timer(const Duration(seconds: 10), () {
        ChatMessageMapper.updateMessageStatus(
          int.parse(data['id'].toString()),
          int.parse(data['to'].toString()),
          2,
        ).then((value) {
          Get.log('更新消息状态成功');
          // 告知chatController更新消息状态
          if (value > 0 && Get.isRegistered<ChatController>()) {
            ChatController chatController = Get.find<ChatController>();
            chatController.updateMessageStatus(
                int.parse(data['id'].toString()), data['to'].toString(), 2);
          }
        });
      });
      _timerMap['time${data['id']}${data['to']}'] = timer;
    }
    final jsonString = jsonEncode(data); // 将消息对象转换为 JSON 字符串
    _channel.sink.add(jsonString); // 发送 JSON 字符串
  }

  // 处理接收到的消息
  void _onMessageReceived(dynamic message) {
    Get.log(
        '处理接收到的消息Received===========================================: $message');
    _messageController.add(message);
  }

  //异常
  void _onError(dynamic error) {
    // 处理错误
    Get.log('Error: $error');
    _isConnected = false;
    _stopHeartbeat();
    _logoutTrtc();
    if (!_isManuallyDisconnected) {
      // 如果不是主动断开连接，则尝试重连
      _reconnect();
    }
  }

  //关闭
  void _onDone() {
    Get.log('WebSocket 连接已关闭');
    _isConnected = false;
    _logoutTrtc();
    _stopHeartbeat();
    if (!_isManuallyDisconnected) {
      // 如果不是主动断开连接，则尝试重连
      _reconnect();
    }
  }

  // 重连
  void _reconnect() {
    // 避免频繁重连，启动重连定时器
    _reconnectTimer = Timer(_reconnectInterval, () {
      _isConnected = false;
      _channel.sink.close(); // 关闭之前的连接
      Get.log('重连====================$_serverUrl');
      _startConnection();
    });
  }

  void _handlerMessage(data) {
    Get.log('处理消息$data');
    Map<String, dynamic> message = jsonDecode(data.toString());
    // 判断消息类型
    if (message['messageType'] == 3) {
      // 聊天信息
      _onMessageChat(message);
    } else if (message['messageType'] == 4) {
      // 新增关注
    } else if (message['messageType'] == 5) {
      // 服务器应答
      _onMessageServerResponse(message);
    } else if (message['messageType'] == 6) {
      // token鉴权失败
      _tokenAuthFailed(message);
    } else if (message['messageType'] == 8) {
      // 新增点赞或收藏
    }
  }

  void _onMessageChat(Map<String, dynamic> message) async {
    Get.log('聊天信息$message');
    // 保存消息到数据库
    await DBManager.instance.createChatRecordTable(message['from'].toString());
    ChatMessageMapper.insert({
      'from_id': message['from'],
      'to_id': message['to'],
      'content': message['content'],
      'time': message['time'],
      'chat_type': message['chatType'],
      'is_read': 1,
      'is_send': 1,
      'audio_time': message['audioTime']
    }, message['from'].toString())
        .then((value) async {
      Get.log('插入消息成功');
      // 告知chatController更新消息
      if (ChatController.isInitialized) {
        Get.log('ChatController已注册');
        ChatController chatController = Get.find<ChatController>();
        if (chatController.otherUserInfo.value.id.toString() ==
            message['from'].toString()) {
          await chatController.addMessage(message['from'].toString());
          Get.log('更新最新消息');
          await RecentlyMessageMapper.update(RecentlyMessage(
              userId: message['from'].toString(),
              avatarUrl: message['fromAvatar'],
              userName: message['fromName'],
              lastMessage: message['chatType'] == 1
                  ? message['content']
                  : message['chatType'] == 2
                      ? '[图片]'
                      : message['chatType'] == 3
                          ? '[文件]'
                          : message['chatType'] == 4
                              ? '[语音]'
                              : message['chatType'] == 5
                                  ? '[视频]'
                                  : message['chatType'] == 6
                                      ? GetUtils.isURL(message['content'])
                                          ? '[表情]'
                                          : message['content']
                                      : '',
              lastTime: message['time'],
              unreadNum: 0,
              stranger: 1));
        } else {
          // 更新最近聊天列表，获取与该联系人的未读数量
          _lock.synchronized(() async {
            RecentlyMessage? value =
                await RecentlyMessageMapper.queryByUserId(message['from']);
            if (value != null) {
              await RecentlyMessageMapper.update(RecentlyMessage(
                  userId: value.userId,
                  avatarUrl: message['fromAvatar'],
                  userName: message['fromName'],
                  lastMessage: message['chatType'] == 1
                      ? message['content']
                      : message['chatType'] == 2
                          ? '[图片]'
                          : message['chatType'] == 3
                              ? '[文件]'
                              : message['chatType'] == 4
                                  ? '[语音]'
                                  : message['chatType'] == 5
                                      ? '[视频]'
                                      : message['chatType'] == 6
                                          ? GetUtils.isURL(message['content'])
                                              ? '[表情]'
                                              : message['content']
                                          : '',
                  lastTime: message['time'],
                  unreadNum: value.unreadNum + 1,
                  stranger: value.stranger));
            } else {
              await RecentlyMessageMapper.insert(RecentlyMessage(
                  userId: message['from'].toString(),
                  avatarUrl: message['fromAvatar'],
                  userName: message['fromName'],
                  lastMessage: message['chatType'] == 1
                      ? message['content']
                      : message['chatType'] == 2
                          ? '[图片]'
                          : message['chatType'] == 3
                              ? '[文件]'
                              : message['chatType'] == 4
                                  ? '[语音]'
                                  : message['chatType'] == 5
                                      ? '[视频]'
                                      : message['chatType'] == 6
                                          ? GetUtils.isURL(message['content'])
                                              ? '[表情]'
                                              : message['content']
                                          : '',
                  lastTime: message['time'],
                  unreadNum: 1,
                  stranger: 1));
            }
          });
          SnackbarUtil.showInfo('您有新消息');
        }
      } else {
        // 更新最近聊天列表，获取与该联系人的未读数量
        Get.log('ChatController未注册');
        await _lock.synchronized(() async {
          RecentlyMessage? value =
              await RecentlyMessageMapper.queryByUserId(message['from']);
          if (value != null) {
            await RecentlyMessageMapper.update(RecentlyMessage(
                userId: value.userId,
                avatarUrl: message['fromAvatar'],
                userName: message['fromName'],
                lastMessage: message['chatType'] == 1
                    ? message['content']
                    : message['chatType'] == 2
                        ? '[图片]'
                        : message['chatType'] == 3
                            ? '[文件]'
                            : message['chatType'] == 4
                                ? '[语音]'
                                : message['chatType'] == 5
                                    ? '[视频]'
                                    : message['chatType'] == 6
                                        ? GetUtils.isURL(message['content'])
                                            ? '[表情]'
                                            : message['content']
                                        : '',
                lastTime: message['time'],
                unreadNum: value.unreadNum + 1,
                stranger: value.stranger));
          } else {
            await RecentlyMessageMapper.insert(RecentlyMessage(
                userId: message['from'].toString(),
                avatarUrl: message['fromAvatar'],
                userName: message['fromName'],
                lastMessage: message['chatType'] == 1
                    ? message['content']
                    : message['chatType'] == 2
                        ? '[图片]'
                        : message['chatType'] == 3
                            ? '[文件]'
                            : message['chatType'] == 4
                                ? '[语音]'
                                : message['chatType'] == 5
                                    ? '[视频]'
                                    : message['chatType'] == 6
                                        ? GetUtils.isURL(message['content'])
                                            ? '[表情]'
                                            : message['content']
                                        : '',
                lastTime: message['time'],
                unreadNum: 1,
                stranger: 1));
          }
        });
        SnackbarUtil.showNewMessage(
            message['fromAvatar'],
            message['fromName'],
            message['chatType'] == 1
                ? message['content']
                : message['chatType'] == 2
                    ? '[图片]'
                    : message['chatType'] == 3
                        ? '[文件]'
                        : message['chatType'] == 4
                            ? '[语音]'
                            : message['chatType'] == 5
                                ? '[视频]'
                                : message['chatType'] == 6
                                    ? GetUtils.isURL(message['content'])
                                        ? '[表情]'
                                        : message['content']
                                    : '',
            message['from']);
      }

      // 通知HomeController更新消息角标
      HomeController homeController = Get.find<HomeController>();
      homeController.refreshUnReadCount();

      // 通知RecentlyMessageController更新最近消息列表
      if (RecentlyMessageController.isInitialized) {
        Get.log('RecentlyMessageController已注册');
        RecentlyMessageController recentlyMessageController =
            Get.find<RecentlyMessageController>();
        recentlyMessageController.updateRecentlyMessageList();
      } else {
        Get.log('RecentlyMessageController未注册');
      }
    });
  }

  _onMessageServerResponse(Map<String, dynamic> message) {
    Get.log('服务器应答信息$message');
    int status = 1;
    if (message.containsKey('content') &&
        message['content'].toString().isNotEmpty) {
      status = 2;
      SnackbarUtil.showError(message['content'].toString());
    }
    Get.log('status: $status');
    // 清除发送中状态
    _timerMap['time${message['id']}${message['to']}']?.cancel();
    ChatMessageMapper.updateMessageStatus(
      int.parse(message['id'].toString()),
      int.parse(message['to'].toString()),
      status,
    ).then((value) {
      Get.log('更新消息状态成功');
      // 告知chatController更新消息状态
      if (value > 0 && Get.isRegistered<ChatController>()) {
        ChatController chatController = Get.find<ChatController>();
        chatController.updateMessageStatus(int.parse(message['id'].toString()),
            message['to'].toString(), status);
      }
    });
  }

  void _tokenAuthFailed(Map<String, dynamic> message) {
    Get.log('token鉴权失败');
    // 清除token
    removeData('token');
    removeData('userInfo');
    SnackbarUtil.showError(message['content'].toString());
    //断开连接
    disconnect();
    //数据库连接信息清除
    DBManager.dispose();
    // 重新登录
    Future.delayed(const Duration(seconds: 1), () {
      Get.offAllNamed('/login');
    });
  }
}
