import 'dart:io';

import 'package:animation_wrappers/animations/faded_slide_animation.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:extended_text_field/extended_text_field.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:image_pickers/image_pickers.dart';
import 'package:lifecycle_lite/lifecycle_mixin.dart';
import 'package:tencent_calls_uikit/tencent_calls_uikit.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';
import 'package:xiaofanshu_flutter/components/audio_animation.dart';
import 'package:xiaofanshu_flutter/controller/chat_controller.dart';
import 'package:xiaofanshu_flutter/static/custom_color.dart';
import 'package:xiaofanshu_flutter/static/emoji_map.dart';
import 'package:xiaofanshu_flutter/utils/Adapt.dart';
import 'package:xiaofanshu_flutter/utils/audio_play_manager.dart';
import 'package:xiaofanshu_flutter/utils/date_show_util.dart';
import 'package:xiaofanshu_flutter/utils/snackbar_util.dart';
import 'package:xiaofanshu_flutter/utils/toast_util.dart';

import '../../../components/audio_overlay.dart';
import '../../../config/text_field_config.dart';
import '../../../model/emoji.dart';
import '../../../utils/comment_util.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage>
    with
        WidgetsBindingObserver,
        SingleTickerProviderStateMixin,
        LifecycleStatefulMixin {
  ChatController chatController = Get.find();
  late OverlayState _overlayState;
  late OverlayEntry _overlayEntry;
  late AnimationController animationController;
  final GlobalKey<ChatAudioMaskState> chatAudioMaskKey = GlobalKey();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
    _overlayState = Overlay.of(context);
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeMetrics() {
    // TODO: implement didChangeMetrics
    super.didChangeMetrics();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        if (MediaQuery.of(context).viewInsets.bottom == 0) {
          Get.log('键盘收起');
        } else {
          chatController.isShowEmoji.value = false;
          chatController.isShowMore.value = false;
        }
        chatController.scrollController
            .jumpTo(chatController.scrollController.position.maxScrollExtent);
      }
    });
  }

  @override
  void deactivate() {
    // TODO: implement deactivate
    super.deactivate();
    AudioPlayManager.instance.audioPlayer.stop();
  }

  @override
  void dispose() {
    chatController.scrollController.dispose();
    animationController.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        if (chatController.isShowEmoji.value) {
          chatController.isShowEmoji.value = false;
          return Future.value(false);
        }
        return Future.value(true);
      },
      child: Scaffold(
        backgroundColor: const Color(0xfff3f3f2),
        appBar: _appBar(),
        body: SizedBox(
          height: MediaQuery.of(context).size.height - 56,
          child: Stack(
            children: [
              SingleChildScrollView(
                controller: chatController.scrollController,
                child: Obx(
                  () => Column(
                    children: [
                      Center(
                        child: !chatController.hasMore.value
                            ? const SizedBox(
                                height: 30,
                                child: Center(
                                  child: Text(
                                    '-----没有更多消息了-----',
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              )
                            : chatController.isLoading.value
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: Center(
                                      child: CircularProgressIndicator(),
                                    ),
                                  )
                                : Container(),
                      ).marginOnly(top: 10, bottom: 10),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: chatController.chatList.length,
                        itemBuilder: (context, index) {
                          return _chatBox(
                              chatController.chatList[index]['from_id']
                                      .toString() ==
                                  chatController.userInfo.value.id.toString(),
                              chatController.chatList[index]['content'],
                              chatController.chatList[index]['chat_type'],
                              chatController.chatList[index]['is_send'],
                              chatController.chatList[index]['time'],
                              isShowTime: index == 0 ||
                                  chatController.chatList[index]['time'] -
                                          chatController.chatList[index - 1]
                                              ['time'] >
                                      300000,
                              audioTime: chatController.chatList[index]
                                  ['audio_time']);
                        },
                      ).paddingOnly(bottom: 60),
                      chatController.isShowEmoji.value ||
                              chatController.isShowMore.value
                          ? Container(
                              height: chatController.isShowEmoji.value
                                  ? Adapt.setRpx(600) + 40
                                  : Adapt.setRpx(400),
                              width: double.infinity,
                              color: Colors.transparent,
                            )
                          : Container(),
                    ],
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: _inputBox(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  AppBar _appBar() {
    return AppBar(
      leading: Container(),
      leadingWidth: 0,
      centerTitle: true,
      backgroundColor: Colors.white,
      title: Obx(
        () => Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                GestureDetector(
                    onTap: () {
                      Get.back();
                    },
                    child: const Icon(Icons.arrow_back_ios,
                        color: Colors.black, size: 20)),
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    image: DecorationImage(
                      image: NetworkImage(
                          chatController.otherUserInfo.value.avatarUrl),
                      fit: BoxFit.cover,
                    ),
                  ),
                ).marginOnly(left: 10),
                Text(
                  chatController.otherUserInfo.value.nickname,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                  ),
                ).marginOnly(left: 10),
              ],
            ),
            GestureDetector(
              onTap: () {
                ToastUtil.showSimpleToast('暂未开放');
              },
              child:
                  const Icon(Icons.more_horiz, color: Colors.black, size: 20),
            ),
          ],
        ),
      ),
    );
  }

  Widget _chatBox(
      bool isMe, String message, int chatType, int sendStatus, int timestamp,
      {bool isShowTime = false, int audioTime = 0}) {
    return Obx(
      () => Column(
        children: [
          // 日期
          isShowTime
              ? SizedBox(
                  height: 20,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        DateShowUtil.showDateWithTime(timestamp),
                        style:
                            const TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    ),
                  ),
                ).marginOnly(top: 10)
              : Container(),
          // 聊天内容
          Row(
            mainAxisAlignment:
                isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 发送中或发送失败，0:发送中，1:发送成功，2:发送失败
              isMe && sendStatus == 0
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.0,
                        color: Colors.grey,
                      ),
                    ).marginOnly(right: 10)
                  : isMe && sendStatus == 2
                      ? const Icon(Icons.error_outline_rounded,
                              color: Colors.red, size: 20)
                          .marginOnly(right: 10)
                      : Container(),
              isMe
                  ? _messageBox(message, isMe, chatType, audioTime)
                  : GestureDetector(
                      onTap: () {
                        Get.toNamed(
                          '/other/mine',
                          arguments:
                              chatController.otherUserInfo.value.id.toString(),
                        );
                      },
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          image: DecorationImage(
                            image: NetworkImage(
                                chatController.otherUserInfo.value.avatarUrl),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ).marginOnly(right: 10),
                    ),
              isMe
                  ? GestureDetector(
                      onTap: () {
                        Get.toNamed(
                          '/other/mine',
                          arguments:
                              chatController.otherUserInfo.value.id.toString(),
                        );
                      },
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          image: DecorationImage(
                            image: NetworkImage(
                                chatController.userInfo.value.avatarUrl),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ).marginOnly(left: 10),
                    )
                  : _messageBox(message, isMe, chatType, audioTime),
            ],
          ).paddingOnly(
            left: isMe ? 0 : 10,
            right: isMe ? 10 : 0,
            top: 10,
            bottom: 10,
          ),
        ],
      ),
    );
  }

  Widget _messageBox(String message, bool isMe, int chatType, int audioTime) {
    return chatType == 1
        ? textMessage(message, isMe)
        : chatType == 2
            ? _imageMessage(message)
            : chatType == 3
                ? _fileMessage(message)
                : chatType == 4
                    ? AudioAnimation(
                        message: message, isMe: isMe, audioTime: audioTime)
                    : chatType == 5
                        ? _videoMessage(message)
                        : chatType == 6
                            ? _emojiMessage(message)
                            : Container();
  }

  Widget textMessage(String message, bool isMe) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: Adapt.setRpx(450), minWidth: 0),
      child: IntrinsicWidth(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: isMe ? const Color(0xff38a1db) : Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          child: ExtendedTextField(
            decoration: const InputDecoration(
              isCollapsed: true,
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(0),
            ),
            readOnly: true,
            maxLines: null,
            minLines: 1,
            selectionControls: CustomTextSelectionControls(),
            controller: TextEditingController()..text = message,
            specialTextSpanBuilder: MySpecialTextSpanBuilder(),
            style: TextStyle(
              color: isMe ? Colors.white : Colors.black,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }

  Widget _imageMessage(String message) {
    return GestureDetector(
      onTap: () {
        List<String> list = [message];
        Get.toNamed('/image/simple/pre', arguments: list);
      },
      child: ConstrainedBox(
        constraints: BoxConstraints(
            maxWidth: Adapt.setRpx(450),
            minWidth: 0,
            maxHeight: Adapt.setRpx(500),
            minHeight: 0),
        child: FutureBuilder<Size>(
          future: getImageDimensions(message),
          builder: (BuildContext context, AsyncSnapshot<Size> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return const Center(child: Text('Error loading image'));
            }
            final size = snapshot.data!;
            double width = size.width;
            double height = size.height;
            // 最大宽度和高度
            double maxWidth = Adapt.setRpx(450);
            double maxHeight = Adapt.setRpx(550);
            // 适配逻辑
            if (width > maxWidth || height > maxHeight) {
              if (width > maxWidth) {
                height = height * maxWidth / width;
                width = maxWidth;
              }
              if (height > maxHeight) {
                width = width * maxHeight / height;
                height = maxHeight;
              }
            }
            return Container(
              width: width,
              height: height,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                image: DecorationImage(
                  image: message.isURL
                      ? CachedNetworkImageProvider(message)
                      : FileImage(File(message)),
                  fit: BoxFit.cover,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _fileMessage(String message) {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: CachedNetworkImageProvider(message),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _videoMessage(String message) {
    return Container(
      width: 200,
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: const Color(0xff2b2b2b),
      ),
      child: Center(
        child: GestureDetector(
          onTap: () {
            Get.toNamed('/video/simple/pre', arguments: message);
          },
          child: const Icon(Icons.play_circle_fill_rounded,
              color: Colors.white, size: 50),
        ),
      ),
    );
  }

  Widget _emojiMessage(String message) {
    return SizedBox(
      width: 100,
      height: 100,
      child: CachedNetworkImage(
        imageUrl: GetUtils.isURL(message)
            ? message
            : EmojiMap.getEmojiUrl(message.substring(1, message.length - 1)),
        progressIndicatorBuilder: (context, url, downloadProgress) {
          return Center(
            child: CircularProgressIndicator(
              value: downloadProgress.progress,
            ),
          );
        },
        errorWidget: (context, url, error) => const Icon(
          Icons.error,
          size: 10,
        ),
        fit: BoxFit.contain,
      ),
    );
  }

  Widget _inputBox() {
    return Obx(() => Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: const Color(0xfff3f3f2),
            border: Border(
                top: BorderSide(
                    color: const Color(0xfff3f3f2).withOpacity(0.1),
                    width: 0.5)),
          ),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  GestureDetector(
                    onTap: () {
                      if (chatController.isShowEmoji.value) {
                        chatController.isShowEmoji.value = false;
                      }
                      if (chatController.isShowMore.value) {
                        chatController.isShowMore.value = false;
                      }
                      if (chatController.readyRecord.value) {
                        if (chatController.inputController.text.isNotEmpty) {
                          chatController.hasText.value = true;
                        }
                      } else {
                        chatController.hasText.value = false;
                      }
                      chatController.readyRecord.value =
                          !chatController.readyRecord.value;
                    },
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.black, width: 1),
                      ),
                      child: Icon(
                          chatController.readyRecord.value
                              ? Icons.keyboard_rounded
                              : Icons.graphic_eq_rounded,
                          color: Colors.black,
                          size: 20),
                    ).marginOnly(top: 5, bottom: 5),
                  ),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: chatController.readyRecord.value
                          ? GestureDetector(
                              onVerticalDragStart: (details) {
                                Get.log(
                                    '---------------onVerticalDragStart-------------');
                                _overlayEntry = OverlayEntry(
                                  builder: (BuildContext context) {
                                    return ChatAudioMask(
                                      key: chatAudioMaskKey,
                                      recordAudioState: RecordAudioState(
                                          recording: true,
                                          recordingState: 1,
                                          noticeMessage: '松开 发送'),
                                    );
                                  },
                                );
                                _overlayState.insert(_overlayEntry);
                                chatController.isRecording.value = true;
                                chatController.startRecordAudio();
                              },
                              onVerticalDragUpdate: (details) {
                                Get.log(
                                    '---------------onVerticalDragUpdate-------------');
                                if (details.localPosition.dy > -150) {
                                  chatAudioMaskKey.currentState!
                                      .updateParameter(RecordAudioState(
                                          recording: true,
                                          recordingState: 1,
                                          noticeMessage: '松开 发送'));
                                  chatController.isRecording.value = true;
                                } else {
                                  chatAudioMaskKey.currentState!
                                      .updateParameter(RecordAudioState(
                                          recording: true,
                                          recordingState: -1,
                                          noticeMessage: '松开 取消'));
                                  chatController.isRecording.value = false;
                                }
                              },
                              onVerticalDragEnd:
                                  (DragEndDetails details) async {
                                Get.log(
                                    '---------------onVerticalDragEnd-------------');
                                _overlayEntry.remove();
                                chatAudioMaskKey.currentState!.updateParameter(
                                  RecordAudioState(
                                      recording: false,
                                      recordingState: 1,
                                      noticeMessage: ''),
                                );
                                await chatController.stopRecordAudio();
                                await chatController.sendRecordAudio();
                              },
                              onVerticalDragCancel: () {
                                Get.log(
                                    '---------------onVerticalDragCancel-------------');
                                _overlayEntry.remove();
                                chatController.isRecording.value = false;
                                chatAudioMaskKey.currentState!.updateParameter(
                                  RecordAudioState(
                                      recording: false,
                                      recordingState: 1,
                                      noticeMessage: ''),
                                );
                                try {
                                  chatController.stopRecordAudio();
                                } catch (e) {
                                  Get.log('stopRecordAudio error: $e');
                                }
                              },
                              child: const Text(
                                '按住 说话',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: Colors.black, fontSize: 14),
                              ).paddingAll(5),
                            )
                          : ExtendedTextField(
                              decoration: const InputDecoration(
                                isCollapsed: true,
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.all(5),
                              ),
                              autofocus: true,
                              onTap: () {
                                chatController.isShowEmoji.value = false;
                                chatController.isShowMore.value = false;
                              },
                              maxLines: 4,
                              minLines: 1,
                              controller: chatController.inputController,
                              selectionControls: CustomTextSelectionControls(),
                              specialTextSpanBuilder:
                                  MySpecialTextSpanBuilder(),
                              style: const TextStyle(
                                  color: Colors.black, fontSize: 14),
                            ),
                    ).marginOnly(left: 10, top: 5, bottom: 5),
                  ),
                  GestureDetector(
                    onTap: () {
                      chatController.isShowMore.value = false;
                      if (!chatController.isShowEmoji.value) {
                        closeKeyboardButKeepFocus();
                      } else {
                        showKeyboard();
                      }
                      chatController.isShowEmoji.value =
                          !chatController.isShowEmoji.value;
                      // 滚动到底部
                      Future.delayed(const Duration(milliseconds: 100), () {
                        chatController.scrollController.jumpTo(chatController
                            .scrollController.position.maxScrollExtent);
                      });
                    },
                    child: SizedBox(
                      width: 30,
                      height: 30,
                      child: Center(
                          child: Icon(
                              chatController.isShowEmoji.value
                                  ? Icons.keyboard_rounded
                                  : Icons.emoji_emotions_outlined,
                              color: Colors.black,
                              size: 25)),
                    ).marginOnly(top: 5, bottom: 5, left: 10),
                  ),
                  chatController.hasText.value
                      ? GestureDetector(
                          onTap: () async {
                            await chatController.sendMessage();
                          },
                          child: FadedSlideAnimation(
                            beginOffset: const Offset(1, 0),
                            endOffset: Offset.zero,
                            fadeDuration: const Duration(milliseconds: 300),
                            slideDuration: const Duration(milliseconds: 300),
                            child: Container(
                                height: 30,
                                width: 50,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color: CustomColor.primaryColor),
                                child: const Center(
                                  child: Text(
                                    '发送',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 12),
                                  ),
                                )).marginOnly(top: 5, bottom: 5, left: 10),
                          ),
                        )
                      : GestureDetector(
                          onTap: () {
                            chatController.isShowEmoji.value = false;
                            if (!chatController.isShowMore.value) {
                              closeKeyboardButKeepFocus();
                            } else {
                              showKeyboard();
                            }
                            chatController.isShowMore.value =
                                !chatController.isShowMore.value;
                            Future.delayed(const Duration(milliseconds: 100),
                                () {
                              chatController.scrollController.jumpTo(
                                  chatController.scrollController.position
                                      .maxScrollExtent);
                            });
                          },
                          child: const SizedBox(
                            width: 30,
                            height: 30,
                            child: Center(
                                child: Icon(Icons.add_circle_outline_rounded,
                                    color: Colors.black, size: 25)),
                          ).marginOnly(top: 5, bottom: 5, left: 10),
                        ),
                ],
              ),
              chatController.isShowEmoji.value
                  ? _emojiWidget()
                  : const SizedBox(),
              chatController.isShowMore.value
                  ? _moreWidget()
                  : const SizedBox(),
            ],
          ),
        ));
  }

  Widget _emojiWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: double.infinity,
          height: 40,
          child: TabBar(
            controller: chatController.emojiTabController,
            tabAlignment: TabAlignment.start,
            overlayColor: WidgetStateProperty.all(Colors.transparent),
            enableFeedback: false,
            isScrollable: true,
            indicator: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            indicatorWeight: 0.1,
            indicatorSize: TabBarIndicatorSize.label,
            labelStyle: const TextStyle(fontSize: 16),
            onTap: (index) {
              chatController.emojiTabController.animateTo(index);
            },
            tabs: [
              const Tab(
                icon: Icon(Icons.emoji_emotions_outlined,
                    color: Colors.black, size: 20),
              ).marginSymmetric(horizontal: 10),
              const Tab(
                icon: Icon(Icons.favorite_border_rounded,
                    color: Colors.black, size: 20),
              ).marginSymmetric(horizontal: 10),
            ],
          ),
        ),
        Container(
          height: Adapt.setRpx(600),
          width: double.infinity,
          color: const Color(0xfff3f3f3),
          child: TabBarView(
            controller: chatController.emojiTabController,
            children: [
              GridView.builder(
                padding: const EdgeInsets.all(10),
                itemCount: EmojiMap.emojiList.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  //横轴元素个数
                  crossAxisCount: 7,
                  //纵轴间距
                  mainAxisSpacing: 20.0,
                  //横轴间距
                  crossAxisSpacing: 20.0,
                ),
                itemBuilder: (BuildContext context, int index) {
                  return GestureDetector(
                    onTap: () {
                      Emoji emoji = EmojiMap.emojiList[index];
                      String text = "『${emoji.name}』";
                      insertText(text, chatController.inputController);
                    },
                    child: CachedNetworkImage(
                      imageUrl: EmojiMap.emojiList[index].url,
                      progressIndicatorBuilder:
                          (context, url, downloadProgress) {
                        return Center(
                          child: CircularProgressIndicator(
                            value: downloadProgress.progress,
                          ),
                        );
                      },
                      errorWidget: (context, url, error) => const Icon(
                        Icons.error,
                        size: 10,
                      ),
                    ),
                  );
                },
              ),
              GridView.builder(
                padding: const EdgeInsets.all(10),
                itemCount: chatController.emojiList.length + 1,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  //横轴元素个数
                  crossAxisCount: 5,
                  //纵轴间距
                  mainAxisSpacing: 20.0,
                  //横轴间距
                  crossAxisSpacing: 20.0,
                ),
                itemBuilder: (BuildContext context, int index) {
                  return index == 0
                      ? GestureDetector(
                          onTap: () async {
                            List<AssetEntity>? result =
                                await AssetPicker.pickAssets(
                              context,
                              pickerConfig: const AssetPickerConfig(
                                maxAssets: 1,
                                requestType: RequestType.image,
                              ),
                            );
                            if (result != null && result.isNotEmpty) {
                              await chatController
                                  .addCollectEmoji(await result[0].originFile);
                            }
                          },
                          child: Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              border:
                                  Border.all(color: Colors.black, width: 0.5),
                            ),
                            child: const Icon(Icons.add_rounded,
                                color: Colors.black, size: 20),
                          ),
                        )
                      : GestureDetector(
                          onTap: () {
                            chatController.sendImage(
                              null,
                              chatController.emojiList[index - 1].networkUrl,
                              isUrl: true,
                            );
                          },
                          child: Image.file(
                            File(chatController.emojiList[index - 1].fileUrl),
                            width: 30,
                            height: 30,
                            fit: BoxFit.cover,
                            frameBuilder: (context, child, frame,
                                wasSynchronouslyLoaded) {
                              if (wasSynchronouslyLoaded) {
                                return child;
                              }
                              return AnimatedOpacity(
                                opacity: frame == null ? 0 : 1,
                                duration: const Duration(seconds: 1),
                                curve: Curves.easeOut,
                                child: child,
                              );
                            },
                            errorBuilder: (context, error, stackTrace) =>
                                const Center(
                              child: Icon(
                                Icons.error,
                                size: 10,
                              ),
                            ),
                          ),
                        );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _moreWidget() {
    return Container(
      height: Adapt.setRpx(400),
      width: double.infinity,
      color: const Color(0xfff3f3f3),
      child: GridView(
        padding: const EdgeInsets.all(10),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          //横轴元素个数
          crossAxisCount: 4,
          //纵轴间距
          mainAxisSpacing: 10.0,
          //横轴间距
          crossAxisSpacing: 5.0,
        ),
        children: [
          ..._moreElementList(),
        ],
      ),
    );
  }

  Widget _moreElement(IconData icon, String text) {
    return Column(
      children: [
        Container(
          width: Adapt.setRpx(100),
          height: Adapt.setRpx(100),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Icon(icon, color: Colors.black, size: 30),
          ),
        ),
        Text(
          text,
          style: const TextStyle(color: Colors.black54, fontSize: 12),
        ).marginOnly(top: 5),
      ],
    );
  }

  List<Widget> _moreElementList() {
    return [
      GestureDetector(
        onTap: () async {
          List<AssetEntity>? result = await AssetPicker.pickAssets(
            context,
            pickerConfig: const AssetPickerConfig(
              maxAssets: 9,
              requestType: RequestType.image,
            ),
          );
          if (result != null && result.isNotEmpty) {
            for (AssetEntity asset in result) {
              await chatController.sendImage(await asset.originFile, null);
            }
          }
        },
        child: _moreElement(Icons.image_rounded, '相册'),
      ),
      GestureDetector(
        onTap: () {
          ImagePickers.openCamera().then((value) async {
            if (value != null && value.path != null) {
              await chatController.sendImage(File(value.path!), null);
            }
          });
        },
        child: _moreElement(Icons.camera_alt_rounded, '拍摄'),
      ),
      GestureDetector(
        onTap: () async {
          List<AssetEntity>? results = await AssetPicker.pickAssets(
            context,
            permissionRequestOption: const PermissionRequestOption(
              androidPermission: AndroidPermission(
                  type: RequestType.video, mediaLocation: true),
            ),
            pickerConfig: const AssetPickerConfig(
              maxAssets: 1,
              requestType: RequestType.video,
            ),
          );
          if (results != null && results.isNotEmpty) {
            for (AssetEntity asset in results) {
              await chatController.sendVideo(await asset.originFile);
            }
          }
        },
        child: _moreElement(Icons.video_collection_rounded, '视频'),
      ),
      GestureDetector(
        onTap: () async {
          List<AssetEntity>? results = await AssetPicker.pickAssets(
            context,
            permissionRequestOption: const PermissionRequestOption(
              androidPermission: AndroidPermission(
                  type: RequestType.video, mediaLocation: true),
            ),
            pickerConfig: const AssetPickerConfig(
              maxAssets: 1,
              requestType: RequestType.all,
            ),
          );
        },
        child: _moreElement(Icons.file_open_sharp, '文件'),
      ),
      GestureDetector(
        onTap: () {
          chatController.isShowMore.value = false;
          TUICallKit.instance.call(
            chatController.otherUserInfo.value.id.toString(),
            TUICallMediaType.audio,
          );
        },
        child: _moreElement(Icons.call, '语音通话'),
      ),
      GestureDetector(
        onTap: () {
          chatController.isShowMore.value = false;
          TUICallKit.instance.call(
            chatController.otherUserInfo.value.id.toString(),
            TUICallMediaType.video,
          );
        },
        child: _moreElement(Icons.videocam_rounded, '视频通话'),
      ),
      GestureDetector(
        onTap: () {
          chatController.isShowMore.value = false;
          chatController.readyRecord.value = true;
        },
        child: _moreElement(Icons.mic_rounded, '语音输入'),
      ),
      GestureDetector(
        onTap: () {},
        child: _moreElement(Icons.location_on_rounded, '位置'),
      ),
      GestureDetector(
        onTap: () {
          ToastUtil.showSimpleToast('暂未开放');
        },
        child: _moreElement(Icons.person_rounded, '好友名片'),
      ),
    ];
  }

  @override
  void whenHide() {
    // TODO: implement whenHide
    Get.log('ChatPage hide');
    AudioPlayManager.instance.audioPlayer.stop();
  }

  @override
  void whenShow() {
    // TODO: implement whenShow
    Get.log('ChatPage show');
  }
}

class ArcPainter extends CustomPainter {
  final double progress;
  final bool isMe;

  ArcPainter(this.progress, this.isMe);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = isMe ? Colors.white : Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final double centerX = size.width / 2;
    final double centerY = size.height / 2;

    // 计算当前需要绘制的弧线数量
    final int numArcs = (progress * 3).ceil();

    // 绘制从原点向外扩散的圆弧
    for (int i = 0; i < numArcs; i++) {
      final double radius = 1 + i * 5; // 控制圆弧半径，越往外越大
      // 1/4圆弧的起始角度
      double startAngle = isMe ? (3.14 / 4 + 3.14) : (3.14 / 4);
      // 1/4圆弧
      const double sweepAngle = -3.14 / 2;

      canvas.drawArc(
        Rect.fromCircle(center: Offset(centerX, centerY), radius: radius),
        startAngle,
        sweepAngle,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
