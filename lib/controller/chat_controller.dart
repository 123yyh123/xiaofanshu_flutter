import 'dart:async';
import 'dart:convert';
import 'dart:ffi';
import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:dio/dio.dart' as dio;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mc_flutter_recorder/mc_flutter_recorder.dart';
import 'package:mc_flutter_recorder/recorder_config.dart';
import 'package:mc_flutter_recorder/recorder_info.dart';
import 'package:mc_flutter_recorder/recorder_state.dart';
import 'package:path_provider/path_provider.dart';
import 'package:xiaofanshu_flutter/controller/recently_message_controller.dart';
import 'package:xiaofanshu_flutter/controller/websocket_controller.dart';
import 'package:xiaofanshu_flutter/mapper/chat_message_mapper.dart';
import 'package:xiaofanshu_flutter/mapper/recently_message_mapper.dart';
import 'package:xiaofanshu_flutter/model/recently_message.dart';
import 'package:xiaofanshu_flutter/model/response.dart';
import 'package:xiaofanshu_flutter/model/websocket_message_vo.dart';
import 'package:xiaofanshu_flutter/static/emoji_map.dart';
import 'package:xiaofanshu_flutter/utils/audio_play_manager.dart';
import 'package:xiaofanshu_flutter/utils/comment_util.dart';
import 'package:xiaofanshu_flutter/utils/db_util.dart';

import '../apis/app.dart';
import '../model/user.dart';
import '../static/custom_code.dart';
import '../static/default_data.dart';
import '../utils/permission_apply.dart';
import '../utils/snackbar_util.dart';
import '../utils/store_util.dart';
import 'home_controller.dart';

class ChatController extends GetxController {
  WebsocketController websocketController = Get.find();
  static bool isInitialized = false;
  var userInfo = DefaultData.user.obs;
  var otherUserInfo = OtherUser.defaultUser.obs;
  var hasText = false.obs;
  var isShowEmoji = false.obs;
  var isShowMore = false.obs;
  var chatList = [].obs;
  var hasMore = true.obs;
  var isLoading = false.obs;
  var isSend = false.obs;
  var readyRecord = false.obs;
  var isRecording = false.obs;
  var maxLength = 60;
  String audioPath = '';
  double audioTime = 0.0;
  MCFlutterRecorder audioRecordPlugin = MCFlutterRecorder();
  ScrollController scrollController = ScrollController();
  TextEditingController inputController = TextEditingController();

  @override
  void onInit() async {
    // TODO: implement onInit
    super.onInit();
    isInitialized = true;
    AudioPlayManager.instance.audioPlayer.setSourceUrl("");
    userInfo.value = User.fromJson(
        jsonDecode(await readData('userInfo') ?? jsonEncode(DefaultData.user)));
    int otherUserId = int.parse(Get.arguments.toString());
    HttpResponse response = await UserApi.viewUserInfo(otherUserId);
    if (response.code == StatusCode.getSuccess) {
      otherUserInfo.value = OtherUser.fromJson(response.data);
      await DBManager.instance.createChatRecordTable(otherUserId.toString());
      loadMessageList();
    } else {
      SnackbarUtil.showError('获取用户信息失败');
    }
    inputController.addListener(() {
      hasText.value = inputController.text.isNotEmpty;
    });
    audioRecordPlugin.recorderInfoStream().listen((event) async {
      audioTime = event.duration.inSeconds.toDouble();
      // 最多录制60秒
      if (event.duration >= Duration(seconds: maxLength)) {
        SnackbarUtil.showInfo('录制时间最长为60秒，已经暂停录制');
        await stopRecordAudio();
        await sendRecordAudio();
      }
    });
    RecentlyMessageMapper.queryByUserId(otherUserId.toString()).then((value) {
      Get.log('value: $value');
      if (value != null) {
        RecentlyMessageMapper.updateRead(value.id!);
        if (RecentlyMessageController.isInitialized) {
          Get.log('RecentlyMessageController已注册');
          RecentlyMessageController recentlyMessageController =
              Get.find<RecentlyMessageController>();
          recentlyMessageController.updateRecentlyMessageList();
        } else {
          Get.log('RecentlyMessageController未注册');
        }
        // 通知HomeController更新角标
        Get.find<HomeController>().refreshUnReadCount();
      }
    });
  }

  @override
  void onReady() {
    // TODO: implement onReady
    super.onReady();
    Future.delayed(const Duration(milliseconds: 1000), () {
      scrollController.jumpTo(scrollController.position.maxScrollExtent);
    });
    scrollController.addListener(() {
      Get.log(
          'scrollController.position.pixels: ${scrollController.position.pixels}');
      Get.log(
          'scrollController.position.maxScrollExtent: ${scrollController.position.maxScrollExtent}');
      // 到达顶部时加载更多
      if (scrollController.position.pixels ==
          scrollController.position.minScrollExtent) {
        loadMessageList();
      }
    });
  }

  @override
  void onClose() {
    AudioPlayManager.dispose();
    super.onClose();
    isInitialized = false;
  }

  Future<void> startRecordAudio() async {
    final dir = (await getApplicationDocumentsDirectory()).path;
    String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    String suffix = '.wav';
    audioPath = '$dir/$fileName$suffix';
    Get.log('audio path: $audioPath');
    await audioRecordPlugin.init(RecorderConfig(
      filePath: audioPath,
      sampleRate: 16000,
      channel: RecorderChannel.mono,
      pcmBitRate: PcmBitRate.pcm16Bit,
      period: const Duration(milliseconds: 100),
      interruptedBehavior: InterruptedBehavior.stop,
      freeDisk: 100,
    ));
    await audioRecordPlugin.start();
  }

  Future<void> stopRecordAudio() async {
    await audioRecordPlugin.stop();
    await audioRecordPlugin.close();
  }

  void loadMessageList() async {
    if (isLoading.value || !hasMore.value) {
      return;
    }
    isLoading.value = true;
    int lastMessageId = -1;
    if (chatList.isNotEmpty) {
      lastMessageId = chatList.first['id'];
    }
    List<Map<String, dynamic>> list =
        await ChatMessageMapper.queryRecentMessage(
            otherUserInfo.value.id, lastMessageId);
    // 记录加载数据前的位置
    double before = scrollController.position.maxScrollExtent;
    // 将list倒序插入到chatList
    if (chatList.isEmpty) {
      chatList.addAll(list.reversed.toList());
    } else {
      if (list.isNotEmpty) {
        chatList.insertAll(0, list.reversed.toList());
      } else {
        hasMore.value = false;
      }
    }
    chatList.refresh();
    // 插入后，滚动到插入前的位置
    scrollController.jumpTo(scrollController.position.maxScrollExtent - before);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      // 滚动到插入前的位置
      scrollController
          .jumpTo(scrollController.position.maxScrollExtent - before);
    });
    isLoading.value = false;
  }

  Future<void> sendMessage() async {
    if (inputController.text.isEmpty) {
      SnackbarUtil.showInfo('请输入消息');
      return;
    }
    if (isSend.value) {
      return;
    }
    isSend.value = true;
    bool isEmoji = judgeEmoji(inputController.text);
    Map<String, dynamic> data;
    if (isEmoji) {
      data = WebsocketMessageVo.chatLocalEmojiMessage(
          userInfo.value.id.toString(),
          otherUserInfo.value.id.toString(),
          inputController.text);
    } else {
      data = WebsocketMessageVo.chatLocalTextMessage(
          userInfo.value.id.toString(),
          otherUserInfo.value.id.toString(),
          inputController.text);
    }
    await ChatMessageMapper.insert(data, otherUserInfo.value.id.toString());
    // 取最新的一条消息插入到聊天列表
    Map<String, dynamic> map =
        await ChatMessageMapper.queryLatestMessage(otherUserInfo.value.id);
    Get.log('map: $map');
    chatList.add(map);
    inputController.clear();
    hasText.value = false;
    scrollController.jumpTo(scrollController.position.maxScrollExtent);
    // 更新最近聊天列表
    await RecentlyMessageMapper.update(RecentlyMessage(
        userId: otherUserInfo.value.id.toString(),
        avatarUrl: otherUserInfo.value.avatarUrl,
        userName: otherUserInfo.value.nickname,
        lastMessage: map['content'],
        lastTime: DateTime.now().millisecondsSinceEpoch,
        unreadNum: 0,
        stranger: 0));
    if (RecentlyMessageController.isInitialized) {
      Get.log('RecentlyMessageController已注册');
      RecentlyMessageController recentlyMessageController =
          Get.find<RecentlyMessageController>();
      recentlyMessageController.updateRecentlyMessageList();
    } else {
      Get.log('RecentlyMessageController未注册');
    }
    websocketController.webSocketManager.sendMessage(
      isEmoji
          ? WebsocketMessageVo.chatServerEmojiMessage(
              map['id'],
              userInfo.value.id.toString(),
              userInfo.value.nickname,
              userInfo.value.avatarUrl,
              otherUserInfo.value.id.toString(),
              map['content'],
            )
          : WebsocketMessageVo.chatServerTextMessage(
              map['id'],
              userInfo.value.id.toString(),
              userInfo.value.nickname,
              userInfo.value.avatarUrl,
              otherUserInfo.value.id.toString(),
              map['content'],
            ),
    );
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      // 滚动到底部
      scrollController.jumpTo(scrollController.position.maxScrollExtent);
    });
    isSend.value = false;
  }

  Future<void> sendRecordAudio() async {
    if (!isRecording.value) {
      return;
    }
    Get.log('wavPath: $audioPath');
    File file = File(audioPath);
    dio.MultipartFile multipartFile = dio.MultipartFile.fromFileSync(
      file.path,
      filename: file.path.split('/').last,
      contentType: dio.DioMediaType('audio', 'wav'),
    );
    dio.FormData formData = dio.FormData.fromMap({
      'file': multipartFile,
    });
    HttpResponse response = await ThirdApi.uploadAudio(formData);
    if (response.code != StatusCode.postSuccess) {
      SnackbarUtil.showError('发送失败');
      return;
    }
    Get.log('上传成功');
    Get.log('data: ${response.data.toString()}');
    Map<String, dynamic> data = WebsocketMessageVo.chatLocalAudioMessage(
        userInfo.value.id.toString(),
        otherUserInfo.value.id.toString(),
        response.data.toString(),
        audioTime.toInt());
    await ChatMessageMapper.insert(data, otherUserInfo.value.id.toString());
    // 取最新的一条消息插入到聊天列表
    Map<String, dynamic> map =
        await ChatMessageMapper.queryLatestMessage(otherUserInfo.value.id);
    Get.log('map: $map');
    chatList.add(map);
    scrollController.jumpTo(scrollController.position.maxScrollExtent);
    // 更新最近聊天列表
    await RecentlyMessageMapper.update(RecentlyMessage(
        userId: otherUserInfo.value.id.toString(),
        avatarUrl: otherUserInfo.value.avatarUrl,
        userName: otherUserInfo.value.nickname,
        lastMessage: '[语音]',
        lastTime: DateTime.now().millisecondsSinceEpoch,
        unreadNum: 0,
        stranger: 0));
    if (RecentlyMessageController.isInitialized) {
      Get.log('RecentlyMessageController已注册');
      RecentlyMessageController recentlyMessageController =
          Get.find<RecentlyMessageController>();
      recentlyMessageController.updateRecentlyMessageList();
    } else {
      Get.log('RecentlyMessageController未注册');
    }
    websocketController.webSocketManager.sendMessage(
      WebsocketMessageVo.chatServerAudioMessage(
        map['id'],
        userInfo.value.id.toString(),
        userInfo.value.nickname,
        userInfo.value.avatarUrl,
        otherUserInfo.value.id.toString(),
        response.data.toString(),
        audioTime.toInt(),
      ),
    );
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      // 滚动到底部
      scrollController.jumpTo(scrollController.position.maxScrollExtent);
    });
    isRecording.value = false;
  }

  void updateMessageStatus(int messageId, String toId, int status) {
    // 找到对应的消息，更新状态
    for (var element in chatList) {
      if (element['id'] == messageId && element['to_id'].toString() == toId) {
        // 将不可变的 Map 转换为可变的 Map
        Map<String, dynamic> mutableElement =
            Map<String, dynamic>.from(element);
        mutableElement['is_send'] = status;
        // 替换原来的不可变 Map
        int index = chatList.indexOf(element);
        chatList[index] = mutableElement;
        break;
      }
    }
    chatList.refresh();
  }

  void addMessage(Map<String, dynamic> message) {
    // 判断该消息是否是当前聊天对象的消息
    if (message['from'].toString() == otherUserInfo.value.id.toString() ||
        message['to'].toString() == otherUserInfo.value.id.toString()) {
      // 更新最近聊天列表
      ChatMessageMapper.queryNewMessage(otherUserInfo.value.id,
              chatList.isEmpty ? -1 : chatList.last['id'])
          .then((value) async {
        Get.log('value: $value');
        if (value.isNotEmpty) {
          // 将消息插入到聊天列表
          chatList.addAll(value);
        }
      });
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        // 滚动到底部
        scrollController.jumpTo(scrollController.position.maxScrollExtent);
      });
    }
  }

  bool judgeEmoji(String text) {
    // 判断是否为大表情，判断标准为有且仅有一个表情，格式为『表情』，并且需要在表情库中找到对应的表情
    if (text.length > 2 && text.startsWith('『') && text.endsWith('』')) {
      String emojiName = text.substring(1, text.length - 1);
      if (EmojiMap.getEmojiUrl(emojiName).isNotEmpty) {
        return true;
      }
    }
    return false;
  }
}

class OtherUser {
  int id;
  String nickname;
  String avatarUrl;

  OtherUser({required id, required this.nickname, required this.avatarUrl})
      : id = int.parse(id.toString());

  factory OtherUser.fromJson(Map<String, dynamic> json) {
    return OtherUser(
      id: json['id'],
      nickname: json['nickname'],
      avatarUrl: json['avatarUrl'],
    );
  }

  static OtherUser defaultUser = OtherUser(
    id: 10000,
    nickname: '',
    avatarUrl: 'https://pmall-yyh.oss-cn-chengdu.aliyuncs.com/00001.jpg',
  );
}
