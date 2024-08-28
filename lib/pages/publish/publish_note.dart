import 'dart:convert';
import 'dart:io';

import 'package:animation_wrappers/animations/faded_slide_animation.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:extended_text_field/extended_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';
import 'package:xiaofanshu_flutter/config/text_field_config.dart';
import 'package:xiaofanshu_flutter/controller/publish_notes_controller.dart';
import 'package:xiaofanshu_flutter/static/custom_color.dart';
import 'package:xiaofanshu_flutter/utils/comment_util.dart';

import '../../model/emoji.dart';
import '../../static/emoji_map.dart';
import '../../utils/Adapt.dart';

class PublishNotes extends StatefulWidget {
  const PublishNotes({super.key});

  @override
  State<PublishNotes> createState() => _PublishNotesState();
}

class _PublishNotesState extends State<PublishNotes> {
  PublishNotesController publishNotesController = Get.find();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        bool shouldPop = false;
        await Get.defaultDialog(
          title: "提示",
          middleText: "是否保存草稿",
          actions: [
            TextButton(
              onPressed: () {
                publishNotesController.saveDraft();
                shouldPop = true;
                Get.back();
              },
              child: const Text("保存"),
            ),
            TextButton(
              onPressed: () {
                shouldPop = true;
                Get.back();
              },
              child: const Text("不保存"),
            ),
          ],
        );
        return shouldPop;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
            backgroundColor: Colors.white,
            leading: IconButton(
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              icon: const Icon(
                Icons.arrow_back_ios,
                color: CustomColor.unselectedColor,
                size: 25,
              ),
              onPressed: () {
                Get.back();
              },
            ),
            leadingWidth: 28,
            title: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                GestureDetector(
                  onTap: () {
                    Get.dialog(
                      const AlertDialog(
                        title: Text("发帖小提示"),
                        content: Text('发帖小提示内容'),
                      ),
                    );
                  },
                  child: const Icon(
                    Icons.tips_and_updates_outlined,
                    color: CustomColor.unselectedColor,
                    size: 25,
                  ),
                ),
              ],
            )),
        body: Obx(
          () => SizedBox(
            height: MediaQuery.of(context).size.height,
            child: Stack(
              children: [
                SingleChildScrollView(
                  child: Column(
                    children: [
                      _resource(),
                      _titleInput(),
                      _contentInput(),
                      _toolBar(),
                      _atUser(),
                      _emoji(),
                      _selectLocation(),
                      _setPermission(),
                    ],
                  ).paddingOnly(bottom: 60),
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: _publishButton(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _resource() {
    return publishNotesController.type.value == 0
        ? SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.only(
                  left: 15, right: 15, top: 10, bottom: 10),
              itemCount: publishNotesController.files.length + 1,
              itemBuilder: (BuildContext context, int index) {
                return index == publishNotesController.files.length
                    ? GestureDetector(
                        onTap: () async {
                          // 添加图片
                          List<AssetEntity>? assets =
                              await AssetPicker.pickAssets(
                            context,
                            pickerConfig: AssetPickerConfig(
                              maxAssets:
                                  9 - publishNotesController.files.length,
                              requestType: RequestType.image,
                            ),
                          );
                          if (assets != null) {
                            for (int i = 0; i < assets.length; i++) {
                              File? file = await assets[i].file;
                              if (file != null) {
                                publishNotesController.files.add(file);
                              }
                            }
                          }
                        },
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: CustomColor.unselectedColor.withOpacity(0.2),
                          ),
                          child: const Icon(
                            Icons.add,
                            color: CustomColor.unselectedColor,
                          ),
                        ).paddingOnly(right: 10),
                      )
                    : Stack(
                        children: [
                          GestureDetector(
                            onTap: () {
                              List<File> files = publishNotesController.files;
                              List<String> urls = [];
                              for (int i = 0; i < files.length; i++) {
                                urls.add(files[i].path);
                              }
                              Get.toNamed(
                                '/image/simple/pre',
                                arguments: urls,
                                parameters: {'index': index.toString()},
                              );
                            },
                            child: Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                image: DecorationImage(
                                  image: FileImage(
                                      publishNotesController.files[index]),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            top: 0,
                            right: 0,
                            child: GestureDetector(
                              onTap: () {
                                publishNotesController.files.removeAt(index);
                              },
                              child: Container(
                                width: 15,
                                height: 15,
                                decoration: BoxDecoration(
                                  color: Colors.red.withOpacity(0.8),
                                  borderRadius: const BorderRadius.only(
                                    topRight: Radius.circular(8),
                                    bottomLeft: Radius.circular(3),
                                  ),
                                ),
                                child: const Center(
                                  child: Icon(
                                    Icons.close,
                                    color: Colors.white,
                                    size: 10,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ).paddingOnly(right: 10);
              },
            ),
          )
        : Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 120,
                width: 120,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  image: DecorationImage(
                    image: FileImage(publishNotesController.cover.value),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Row(
                children: [
                  GestureDetector(
                    onTap: () async {
                      Get.toNamed(
                        '/video/simple/pre',
                        arguments: publishNotesController.video.value.path,
                      );
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: CustomColor.unselectedColor.withOpacity(0.2),
                      ),
                      child: const Text(
                        "预览视频",
                        style: TextStyle(
                          color: CustomColor.unselectedColor,
                          fontSize: 12,
                        ),
                      ).paddingOnly(left: 10, right: 10, top: 5, bottom: 5),
                    ).paddingOnly(right: 10),
                  ),
                  GestureDetector(
                    onTap: () async {
                      List<AssetEntity>? assets = await AssetPicker.pickAssets(
                        context,
                        pickerConfig: const AssetPickerConfig(
                          maxAssets: 1,
                          requestType: RequestType.image,
                        ),
                      );
                      if (assets != null && assets.isNotEmpty) {
                        File? file = await assets[0].file;
                        if (file != null) {
                          publishNotesController.cover.value = file;
                        }
                      }
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: CustomColor.unselectedColor.withOpacity(0.2),
                      ),
                      child: const Text(
                        "设置其他封面",
                        style: TextStyle(
                          color: CustomColor.unselectedColor,
                          fontSize: 12,
                        ),
                      ).paddingOnly(left: 10, right: 10, top: 5, bottom: 5),
                    ).paddingOnly(right: 10),
                  ),
                ],
              ).marginOnly(top: 10),
            ],
          ).paddingOnly(left: 15, right: 15, top: 10, bottom: 10);
  }

  Widget _titleInput() {
    return Container(
      padding: const EdgeInsets.only(left: 15, right: 15, top: 10, bottom: 10),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: CustomColor.unselectedColor.withOpacity(0.2),
            width: 1,
          ),
        ),
      ),
      child: TextField(
        style: const TextStyle(
          fontSize: 20,
        ),
        enableInteractiveSelection: true,
        selectionControls: CustomTextSelectionControls(),
        maxLength: 20,
        cursorColor: CustomColor.primaryColor,
        cursorWidth: 3,
        decoration: InputDecoration(
          hintText: '添加标题',
          hintStyle: const TextStyle(
            color: CustomColor.unselectedColor,
            fontSize: 20,
          ),
          border: InputBorder.none,
          suffixIcon: IconButton(
            onPressed: () {
              publishNotesController.titleController.clear();
            },
            icon: const Icon(
              Icons.close,
              color: CustomColor.unselectedColor,
              size: 20,
            ),
          ),
        ),
        maxLines: 1,
        controller: publishNotesController.titleController,
      ),
    );
  }

  Widget _contentInput() {
    return Container(
      padding: const EdgeInsets.only(left: 15, right: 15, top: 10, bottom: 10),
      child: ExtendedTextField(
        specialTextSpanBuilder: MySpecialTextSpanBuilder(),
        controller: publishNotesController.contentController,
        maxLines: 5,
        minLines: 1,
        cursorColor: CustomColor.primaryColor,
        cursorWidth: 3,
        maxLength: 2000,
        selectionControls: CustomTextSelectionControls(),
        decoration: const InputDecoration(
          hintText: '添加正文',
          helperText: '最多输入2000字，添加话题时需要以空格结尾哦',
          helperStyle: TextStyle(
            color: CustomColor.unselectedColor,
            fontSize: 12,
          ),
          hintStyle: TextStyle(
            color: CustomColor.unselectedColor,
            fontSize: 16,
          ),
          border: InputBorder.none,
        ),
        style: const TextStyle(
          fontSize: 16,
        ),
      ),
    );
  }

  Widget _toolBar() {
    return Container(
      padding: const EdgeInsets.only(left: 15, right: 15, top: 10, bottom: 10),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: CustomColor.unselectedColor.withOpacity(0.2),
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () {
              insertText(" #", publishNotesController.contentController);
            },
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xffe5e4e6).withOpacity(0.6),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.group_work_outlined,
                    size: 16,
                  ),
                  Text(
                    "话题",
                    style: TextStyle(
                      fontSize: 14,
                    ),
                  ),
                ],
              ).paddingOnly(left: 10, right: 10, top: 5, bottom: 5),
            ),
          ),
          GestureDetector(
            onTap: () {
              publishNotesController.isShowAtUser.value =
                  !publishNotesController.isShowAtUser.value;
            },
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xffe5e4e6).withOpacity(0.6),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.alternate_email,
                    size: 16,
                  ),
                  Text(
                    "用户",
                    style: TextStyle(
                      fontSize: 14,
                    ),
                  ),
                ],
              ).paddingOnly(left: 10, right: 10, top: 5, bottom: 5),
            ).marginOnly(left: 10),
          ),
          GestureDetector(
            onTap: () {
              publishNotesController.isShowEmoji.value =
                  !publishNotesController.isShowEmoji.value;
            },
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xffe5e4e6).withOpacity(0.6),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.emoji_emotions_outlined,
                    size: 16,
                  ),
                  Text(
                    "表情",
                    style: TextStyle(
                      fontSize: 14,
                    ),
                  ),
                ],
              ).paddingOnly(left: 10, right: 10, top: 5, bottom: 5),
            ).marginOnly(left: 10),
          ),
        ],
      ),
    );
  }

  Widget _atUser() {
    return publishNotesController.isShowAtUser.value
        ? FadedSlideAnimation(
            beginOffset: const Offset(-1, 0),
            endOffset: Offset.zero,
            fadeDuration: const Duration(milliseconds: 300),
            slideDuration: const Duration(milliseconds: 300),
            child: Container(
              height: 120,
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Color(0xffe5e4e6),
              ),
              child: ListView.builder(
                controller: publishNotesController.attentionScrollController,
                padding: const EdgeInsets.only(
                  left: 10,
                  right: 10,
                  top: 8,
                ),
                scrollDirection: Axis.horizontal,
                itemCount: publishNotesController.attentionList.length,
                itemBuilder: (BuildContext context, int index) {
                  return GestureDetector(
                    onTap: () {
                      Map<String, String> map = {};
                      map['name'] = publishNotesController.attentionList[index]
                          ['nickname'];
                      map['id'] =
                          publishNotesController.attentionList[index]['userId'];
                      String attentionUserInfo = '@${jsonEncode(map)} ';
                      insertText(attentionUserInfo,
                          publishNotesController.contentController);
                    },
                    child: Column(
                      children: [
                        ClipOval(
                          child: Image.network(
                            publishNotesController.attentionList[index]
                                ['avatarUrl'],
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                          ),
                        ).paddingAll(10),
                        Text(
                          publishNotesController.attentionList[index]
                              ['nickname'],
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xff2b2b2b),
                          ),
                        ),
                      ],
                    ).marginOnly(right: 10),
                  );
                },
              ),
            ),
          )
        : const SizedBox();
  }

  Widget _emoji() {
    return publishNotesController.isShowEmoji.value
        ? FadedSlideAnimation(
            beginOffset: const Offset(1, 0),
            endOffset: Offset.zero,
            fadeDuration: const Duration(milliseconds: 300),
            slideDuration: const Duration(milliseconds: 300),
            child: Container(
              height: Adapt.setRpx(500),
              width: double.infinity,
              color: const Color(0xfff3f3f3),
              child: GridView.builder(
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
                      insertText(
                          text, publishNotesController.contentController);
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
            ),
          )
        : const SizedBox();
  }

  Widget _selectLocation() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: CustomColor.unselectedColor.withOpacity(0.2),
            width: 1,
          ),
        ),
      ),
      child: GestureDetector(
        onTap: () {
          // 选择位置
          Get.toNamed('/location/picker');
        },
        behavior: HitTestBehavior.opaque,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              flex: 1,
              child: Row(
                children: [
                  const Icon(
                    Icons.add_location_alt_outlined,
                    size: 16,
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    flex: 1,
                    child: publishNotesController.selectedLocationName.value ==
                            ''
                        ? const Text(
                            "添加地点",
                            maxLines: 1,
                            style: TextStyle(
                              fontSize: 14,
                              overflow: TextOverflow.ellipsis,
                            ),
                          )
                        : Text(
                            publishNotesController.selectedLocationName.value,
                            maxLines: 1,
                            style: const TextStyle(
                              fontSize: 14,
                              color: CustomColor.primaryColor,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              color: CustomColor.unselectedColor,
              size: 16,
            ),
          ],
        ).paddingOnly(left: 10, right: 10, top: 5, bottom: 5),
      ),
    );
  }

  Widget _setPermission() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: CustomColor.unselectedColor.withOpacity(0.2),
            width: 1,
          ),
        ),
      ),
      child: GestureDetector(
        onTap: () {
          // 设置权限
          Get.bottomSheet(
            Container(
              height: 160,
              padding: const EdgeInsets.only(
                left: 15,
                right: 15,
                top: 10,
                bottom: 10,
              ),
              decoration: const BoxDecoration(
                color: Color(0xfff3f3f2),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(10),
                  topRight: Radius.circular(10),
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    GestureDetector(
                      onTap: () {
                        publishNotesController.authority.value = 0;
                        Get.back();
                      },
                      behavior: HitTestBehavior.opaque,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Row(
                            children: [
                              Icon(
                                Icons.lock_open_rounded,
                                size: 20,
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Text(
                                "公开可见",
                                style: TextStyle(
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                          publishNotesController.authority.value == 0
                              ? const Icon(
                                  Icons.check,
                                  color: CustomColor.primaryColor,
                                  size: 20,
                                )
                              : const SizedBox(),
                        ],
                      ).paddingAll(15),
                    ),
                    Container(
                      height: 1,
                      color: CustomColor.unselectedColor.withOpacity(0.2),
                    ),
                    GestureDetector(
                      onTap: () {
                        publishNotesController.authority.value = 1;
                        Get.back();
                      },
                      behavior: HitTestBehavior.opaque,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Row(
                            children: [
                              Icon(
                                Icons.lock_rounded,
                                size: 20,
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Text(
                                "仅自己可见",
                                style: TextStyle(
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                          publishNotesController.authority.value == 1
                              ? const Icon(
                                  Icons.check,
                                  color: CustomColor.primaryColor,
                                  size: 20,
                                )
                              : const SizedBox(),
                        ],
                      ).paddingAll(15),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
        behavior: HitTestBehavior.opaque,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(
                  publishNotesController.authority.value == 0
                      ? Icons.lock_open_rounded
                      : Icons.lock_rounded,
                  size: 16,
                  color: publishNotesController.authority.value == 0
                      ? Colors.black
                      : CustomColor.primaryColor,
                ),
                const SizedBox(
                  width: 10,
                ),
                Text(
                  publishNotesController.authority.value == 0
                      ? "公开可见"
                      : "仅自己可见",
                  style: TextStyle(
                    fontSize: 14,
                    color: publishNotesController.authority.value == 0
                        ? Colors.black
                        : CustomColor.primaryColor,
                  ),
                ),
              ],
            ),
            const Icon(
              Icons.arrow_forward_ios,
              color: CustomColor.unselectedColor,
              size: 16,
            ),
          ],
        ).paddingOnly(left: 10, right: 10, top: 5, bottom: 5),
      ),
    );
  }

  Widget _publishButton() {
    return Container(
      color: Colors.white,
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              // 存草稿
              publishNotesController.saveDraft();
            },
            child: Container(
              height: 40,
              width: 40,
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: const Color(0xffe5e4e6),
                borderRadius: BorderRadius.circular(30),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.drafts_outlined,
                    color: Colors.black,
                    size: 20,
                  ),
                  Text(
                    "存草稿",
                    style: TextStyle(
                      fontSize: 8,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              height: 40,
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: CustomColor.primaryColor,
                borderRadius: BorderRadius.circular(30),
              ),
              child: GestureDetector(
                onTap: () {
                  // 发布
                  publishNotesController.publish();
                },
                behavior: HitTestBehavior.opaque,
                child: const Center(
                  child: Text(
                    "发布笔记",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ).paddingOnly(left: 15),
          ),
        ],
      ).paddingOnly(left: 15, right: 15, top: 10, bottom: 10),
    );
  }
}
