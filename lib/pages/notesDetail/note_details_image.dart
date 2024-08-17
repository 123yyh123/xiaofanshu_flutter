import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:card_swiper/card_swiper.dart';
import 'package:extended_text_field/extended_text_field.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:like_button/like_button.dart';
import 'package:xiaofanshu_flutter/apis/app.dart';
import 'package:xiaofanshu_flutter/config/custom_icon.dart';
import 'package:xiaofanshu_flutter/controller/note_details_image_controller.dart';
import 'package:get/get.dart';
import 'package:xiaofanshu_flutter/static/custom_code.dart';
import 'package:xiaofanshu_flutter/static/custom_color.dart';
import 'package:xiaofanshu_flutter/utils/Adapt.dart';
import 'package:xiaofanshu_flutter/utils/comment_util.dart';
import 'package:xiaofanshu_flutter/utils/toast_util.dart';

import '../../config/text_field_config.dart';
import '../../model/emoji.dart';

class NoteDetailsImage extends StatefulWidget {
  const NoteDetailsImage({super.key});

  @override
  State<NoteDetailsImage> createState() => _NoteDetailsImageState();
}

class _NoteDetailsImageState extends State<NoteDetailsImage> {
  NoteDetailsImageController noteDetailsImageController = Get.find();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            size: 25,
          ),
          onPressed: () {
            Get.back();
          },
        ).marginOnly(left: 5),
        leadingWidth: 28,
        title: Obx(
          () => Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      image: DecorationImage(
                        image: NetworkImage(
                            noteDetailsImageController.notes.value.avatarUrl,
                            scale: 1.0),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: Adapt.setRpx(200),
                    ),
                    child: Text(
                      noteDetailsImageController.notes.value.nickname,
                      maxLines: 1,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              noteDetailsImageController.notes.value.belongUserId ==
                      noteDetailsImageController.userInfo.value.id
                  ? GestureDetector(
                      onTap: () {},
                      child: const Icon(
                        Icons.more_horiz,
                        size: 25,
                        color: Colors.black,
                      ))
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        GestureDetector(
                          onTap: () {
                            noteDetailsImageController.notes.value.isFollow =
                                !noteDetailsImageController
                                    .notes.value.isFollow;
                            noteDetailsImageController.notes.refresh();
                            UserApi.attentionUser(
                              noteDetailsImageController.userInfo.value.id,
                              noteDetailsImageController
                                  .notes.value.belongUserId,
                            );
                          },
                          child: Container(
                            height: 30,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: noteDetailsImageController
                                        .notes.value.isFollow
                                    ? CustomColor.unselectedColor
                                    : CustomColor.primaryColor,
                                width: 1,
                              ),
                            ),
                            child: Text(
                              noteDetailsImageController.notes.value.isFollow
                                  ? '已关注'
                                  : '关注',
                              style: TextStyle(
                                fontSize: 12,
                                color: noteDetailsImageController
                                        .notes.value.isFollow
                                    ? CustomColor.unselectedColor
                                    : CustomColor.primaryColor,
                              ),
                            ).paddingOnly(
                                left: 20, right: 20, top: 5, bottom: 5),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {},
                          child: const Icon(
                            CustomIcon.share,
                            size: 25,
                            color: Colors.black,
                          ),
                        ).paddingOnly(left: 15, right: 10),
                      ],
                    ),
            ],
          ),
        ),
      ),
      body: Obx(
        () => SizedBox(
          width: double.infinity,
          height: double.infinity,
          child: Stack(
            children: [
              SingleChildScrollView(
                controller: noteDetailsImageController.scrollController,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 图片轮播
                    Center(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxHeight: Adapt.setRpx(
                              noteDetailsImageController.swiperHeight.value),
                          maxWidth: double.infinity,
                        ),
                        child: Swiper(
                          itemBuilder: (context, index) {
                            return noteDetailsImageController.notes.value
                                        .notesResources[index].url ==
                                    ''
                                ? const Center(
                                    child: CircularProgressIndicator(),
                                  )
                                : GestureDetector(
                                    onTap: () {
                                      Get.toNamed(
                                        '/image/simple/pre',
                                        arguments: noteDetailsImageController
                                            .notes
                                            .value
                                            .notesResources[index]
                                            .url,
                                      );
                                    },
                                    child: CachedNetworkImage(
                                      fit: BoxFit.contain,
                                      imageUrl: noteDetailsImageController.notes
                                          .value.notesResources[index].url,
                                      progressIndicatorBuilder:
                                          (context, url, downloadProgress) {
                                        return Center(
                                          child: CircularProgressIndicator(
                                            value: downloadProgress.progress,
                                          ),
                                        );
                                      },
                                      errorWidget: (context, url, error) =>
                                          const Icon(
                                        Icons.error,
                                        size: 50,
                                      ),
                                    ),
                                  );
                          },
                          indicatorLayout: PageIndicatorLayout.WARM,
                          itemCount: noteDetailsImageController
                              .notes.value.notesResources.length,
                          pagination: const SwiperPagination(),
                          loop: false,
                        ),
                      ),
                    ),
                    // 文字内容
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          noteDetailsImageController.notes.value.title
                              .fixAutoLines(),
                          textAlign: TextAlign.left,
                          style: const TextStyle(
                              fontSize: 18, color: Colors.black),
                        ).paddingAll(10),
                        ExtendedTextField(
                          decoration: const InputDecoration(
                            isCollapsed: true,
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.all(0),
                          ),
                          style: const TextStyle(
                              fontSize: 16, color: Colors.black),
                          readOnly: true,
                          maxLines: null,
                          controller:
                              noteDetailsImageController.contentController,
                          specialTextSpanBuilder: MySpecialTextSpanBuilder(),
                        ).paddingOnly(left: 10, right: 10, bottom: 10),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              maxLines: 1,
                              "${noteDetailsImageController.notes.value.createTime}   ${noteDetailsImageController.notes.value.province}",
                              textAlign: TextAlign.end,
                              style: const TextStyle(
                                height: 1.2,
                                fontSize: 12,
                                color: CustomColor.unselectedColor,
                              ),
                            ),
                          ],
                        ).paddingOnly(left: 10, right: 10),
                      ],
                    ),
                    // 分割线
                    Container(
                      height: 1,
                      decoration: const BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: Color(0xffe5e5e5),
                            width: 0.5,
                          ),
                        ),
                      ),
                    ).paddingOnly(left: 10, right: 10, top: 10, bottom: 10),
                    // 评论
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          noteDetailsImageController.commentCount.value == 0
                              ? '暂无评论'
                              : '共${noteDetailsImageController.commentCount.value}条评论',
                          style: const TextStyle(
                              fontSize: 14, color: Colors.black),
                        ).paddingAll(10),
                        Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                image: DecorationImage(
                                  image: NetworkImage(
                                      noteDetailsImageController
                                          .userInfo.value.avatarUrl,
                                      scale: 1.0),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            Expanded(
                              flex: 1,
                              child: GestureDetector(
                                onTap: () {
                                  noteDetailsImageController.judgeSameReply(
                                      '', '', '');
                                  noteDetailsImageController.showBottomInput();
                                },
                                child: Container(
                                    height: 40,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20),
                                      color: const Color(0xfff3f3f2),
                                    ),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text(
                                          "爱评论的人运气都不差",
                                          style: TextStyle(
                                            color: Color(0xffafafb0),
                                          ),
                                        ),
                                        Row(
                                          children: [
                                            const Icon(
                                              Icons.alternate_email,
                                              color: Color(0xffafafb0),
                                              size: 28,
                                            ).marginOnly(right: 10),
                                            const Icon(
                                              Icons.emoji_emotions_outlined,
                                              color: Color(0xffafafb0),
                                              size: 28,
                                            ).marginOnly(right: 10),
                                            const Icon(
                                              Icons.broken_image_outlined,
                                              color: Color(0xffafafb0),
                                              size: 28,
                                            ),
                                          ],
                                        ),
                                      ],
                                    ).paddingOnly(left: 10, right: 10)),
                              ),
                            ),
                          ],
                        ).paddingOnly(left: 10, right: 10, bottom: 10),
                        Column(
                          children: [
                            ListView.builder(
                              physics: const NeverScrollableScrollPhysics(),
                              itemBuilder: (context, index) {
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          width: 40,
                                          height: 40,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(20),
                                            image: DecorationImage(
                                              image: NetworkImage(
                                                  noteDetailsImageController
                                                      .commentList[index]
                                                      .comment
                                                      .commentUserAvatar,
                                                  scale: 1.0),
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(
                                          width: 10,
                                        ),
                                        Expanded(
                                          flex: 1,
                                          child: GestureDetector(
                                            onTap: () {
                                              Map<String, String> map = {};
                                              map['id'] =
                                                  noteDetailsImageController
                                                      .commentList[index]
                                                      .comment
                                                      .commentUserId
                                                      .toString();
                                              map['name'] =
                                                  noteDetailsImageController
                                                      .commentList[index]
                                                      .comment
                                                      .commentUserName;
                                              noteDetailsImageController
                                                  .judgeSameReply(
                                                      jsonEncode(map),
                                                      noteDetailsImageController
                                                          .commentList[index]
                                                          .comment
                                                          .id,
                                                      noteDetailsImageController
                                                          .commentList[index]
                                                          .comment
                                                          .id);
                                              noteDetailsImageController
                                                  .replyUserInfo.value = '';
                                              noteDetailsImageController
                                                  .showBottomInput();
                                            },
                                            onLongPress: () {
                                              Get.bottomSheet(
                                                SingleChildScrollView(
                                                  child: Container(
                                                    width: double.infinity,
                                                    decoration:
                                                        const BoxDecoration(
                                                      color: Colors.white,
                                                      borderRadius:
                                                          BorderRadius.only(
                                                        topLeft:
                                                            Radius.circular(10),
                                                        topRight:
                                                            Radius.circular(10),
                                                      ),
                                                    ),
                                                    child: Column(
                                                      children: [
                                                        noteDetailsImageController
                                                                    .notes
                                                                    .value
                                                                    .belongUserId ==
                                                                noteDetailsImageController
                                                                    .userInfo
                                                                    .value
                                                                    .id
                                                            ? GestureDetector(
                                                                onTap: () {
                                                                  if (Get
                                                                      .isBottomSheetOpen!) {
                                                                    Get.back();
                                                                  }
                                                                  CommentApi.setTopComment(noteDetailsImageController
                                                                          .commentList[
                                                                              index]
                                                                          .comment
                                                                          .id)
                                                                      .then(
                                                                          (value) {
                                                                    if (value
                                                                            .code ==
                                                                        StatusCode
                                                                            .postSuccess) {
                                                                      noteDetailsImageController
                                                                          .commentList[
                                                                              0]
                                                                          .comment
                                                                          .isTop = false;
                                                                      noteDetailsImageController
                                                                          .commentList[
                                                                              index]
                                                                          .comment
                                                                          .isTop = true;
                                                                      noteDetailsImageController
                                                                          .commentList
                                                                          .insert(
                                                                              0,
                                                                              noteDetailsImageController.commentList.removeAt(index));
                                                                      noteDetailsImageController
                                                                          .commentList
                                                                          .refresh();
                                                                      ToastUtil
                                                                          .showSimpleToast(
                                                                              '置顶成功');
                                                                    } else {
                                                                      ToastUtil
                                                                          .showSimpleToast(
                                                                              '置顶失败');
                                                                    }
                                                                  });
                                                                },
                                                                child:
                                                                    Container(
                                                                  width: double
                                                                      .infinity,
                                                                  decoration:
                                                                      const BoxDecoration(
                                                                    border:
                                                                        Border(
                                                                      bottom:
                                                                          BorderSide(
                                                                        color: Color(
                                                                            0xffe5e5e5),
                                                                        width:
                                                                            0.5,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  child:
                                                                      Expanded(
                                                                    flex: 1,
                                                                    child:
                                                                        const Text(
                                                                      "置顶",
                                                                      textAlign:
                                                                          TextAlign
                                                                              .center,
                                                                      style:
                                                                          TextStyle(
                                                                        fontSize:
                                                                            16,
                                                                        color: Colors
                                                                            .black,
                                                                      ),
                                                                    ).paddingAll(
                                                                            10),
                                                                  ),
                                                                ),
                                                              )
                                                            : const SizedBox(),
                                                        GestureDetector(
                                                          onTap: () {
                                                            if (Get
                                                                .isBottomSheetOpen!) {
                                                              Get.back();
                                                            }
                                                            Map<String, String>
                                                                map = {};
                                                            map['id'] =
                                                                noteDetailsImageController
                                                                    .commentList[
                                                                        index]
                                                                    .comment
                                                                    .commentUserId
                                                                    .toString();
                                                            map['name'] =
                                                                noteDetailsImageController
                                                                    .commentList[
                                                                        index]
                                                                    .comment
                                                                    .commentUserName;
                                                            noteDetailsImageController.judgeSameReply(
                                                                jsonEncode(map),
                                                                noteDetailsImageController
                                                                    .commentList[
                                                                        index]
                                                                    .comment
                                                                    .id,
                                                                noteDetailsImageController
                                                                    .commentList[
                                                                        index]
                                                                    .comment
                                                                    .id);
                                                            noteDetailsImageController
                                                                .replyUserInfo
                                                                .value = '';
                                                            noteDetailsImageController
                                                                .showBottomInput();
                                                          },
                                                          child: Container(
                                                            width:
                                                                double.infinity,
                                                            decoration:
                                                                const BoxDecoration(
                                                              border: Border(
                                                                bottom:
                                                                    BorderSide(
                                                                  color: Color(
                                                                      0xffe5e5e5),
                                                                  width: 0.5,
                                                                ),
                                                              ),
                                                            ),
                                                            child: Expanded(
                                                              flex: 1,
                                                              child: const Text(
                                                                "回复",
                                                                textAlign:
                                                                    TextAlign
                                                                        .center,
                                                                style:
                                                                    TextStyle(
                                                                  fontSize: 16,
                                                                  color: Colors
                                                                      .black,
                                                                ),
                                                              ).paddingAll(10),
                                                            ),
                                                          ),
                                                        ),
                                                        GestureDetector(
                                                          onTap: () {
                                                            if (Get
                                                                .isBottomSheetOpen!) {
                                                              Get.back();
                                                            }
                                                            copyToClipboard(parseSpecialText(
                                                                noteDetailsImageController
                                                                    .commentList[
                                                                        index]
                                                                    .comment
                                                                    .content));
                                                          },
                                                          child: Container(
                                                            width:
                                                                double.infinity,
                                                            decoration:
                                                                const BoxDecoration(
                                                              border: Border(
                                                                bottom:
                                                                    BorderSide(
                                                                  color: Color(
                                                                      0xffe5e5e5),
                                                                  width: 0.5,
                                                                ),
                                                              ),
                                                            ),
                                                            child: Expanded(
                                                              flex: 1,
                                                              child: const Text(
                                                                "复制",
                                                                textAlign:
                                                                    TextAlign
                                                                        .center,
                                                                style:
                                                                    TextStyle(
                                                                  fontSize: 16,
                                                                  color: Colors
                                                                      .black,
                                                                ),
                                                              ).paddingAll(10),
                                                            ),
                                                          ),
                                                        ),
                                                        (noteDetailsImageController
                                                                        .notes
                                                                        .value
                                                                        .belongUserId ==
                                                                    noteDetailsImageController
                                                                        .userInfo
                                                                        .value
                                                                        .id) ||
                                                                (noteDetailsImageController
                                                                        .commentList[
                                                                            index]
                                                                        .comment
                                                                        .commentUserId ==
                                                                    noteDetailsImageController
                                                                        .userInfo
                                                                        .value
                                                                        .id)
                                                            ? GestureDetector(
                                                                onTap: () {
                                                                  if (Get
                                                                      .isBottomSheetOpen!) {
                                                                    Get.back();
                                                                  }
                                                                  CommentApi.deleteComment(noteDetailsImageController
                                                                      .commentList[
                                                                          index]
                                                                      .comment
                                                                      .id);
                                                                  noteDetailsImageController
                                                                      .commentList
                                                                      .removeAt(
                                                                          index);
                                                                  noteDetailsImageController
                                                                      .commentList
                                                                      .refresh();
                                                                },
                                                                child:
                                                                    Container(
                                                                  width: double
                                                                      .infinity,
                                                                  decoration:
                                                                      const BoxDecoration(
                                                                    border:
                                                                        Border(
                                                                      bottom:
                                                                          BorderSide(
                                                                        color: Color(
                                                                            0xffe5e5e5),
                                                                        width:
                                                                            0.5,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  child:
                                                                      Expanded(
                                                                    flex: 1,
                                                                    child:
                                                                        const Text(
                                                                      "删除",
                                                                      textAlign:
                                                                          TextAlign
                                                                              .center,
                                                                      style:
                                                                          TextStyle(
                                                                        fontSize:
                                                                            16,
                                                                        color: Colors
                                                                            .black,
                                                                      ),
                                                                    ).paddingAll(
                                                                            10),
                                                                  ),
                                                                ),
                                                              )
                                                            : const SizedBox(),
                                                        Container(
                                                          height: 15,
                                                          width:
                                                              double.infinity,
                                                          color: const Color(
                                                              0xfff3f3f2),
                                                        ),
                                                        GestureDetector(
                                                          onTap: () {
                                                            Get.back();
                                                          },
                                                          child: Container(
                                                            width:
                                                                double.infinity,
                                                            decoration:
                                                                const BoxDecoration(
                                                              border: Border(
                                                                bottom:
                                                                    BorderSide(
                                                                  color: Color(
                                                                      0xffe5e5e5),
                                                                  width: 0.5,
                                                                ),
                                                              ),
                                                            ),
                                                            child: Expanded(
                                                              flex: 1,
                                                              child: const Text(
                                                                "取消",
                                                                textAlign:
                                                                    TextAlign
                                                                        .center,
                                                                style:
                                                                    TextStyle(
                                                                  fontSize: 16,
                                                                  color: Colors
                                                                      .black,
                                                                ),
                                                              ).paddingAll(10),
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              );
                                            },
                                            behavior: HitTestBehavior.opaque,
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      noteDetailsImageController
                                                          .commentList[index]
                                                          .comment
                                                          .commentUserName,
                                                      style: const TextStyle(
                                                        fontSize: 14,
                                                        color: CustomColor
                                                            .unselectedColor,
                                                      ),
                                                    ),
                                                    const SizedBox(
                                                      width: 10,
                                                    ),
                                                    (noteDetailsImageController
                                                                    .commentList[
                                                                        index]
                                                                    .comment
                                                                    .commentUserId !=
                                                                noteDetailsImageController
                                                                    .notes
                                                                    .value
                                                                    .belongUserId) &&
                                                            (noteDetailsImageController
                                                                    .commentList[
                                                                        index]
                                                                    .comment
                                                                    .commentUserId !=
                                                                noteDetailsImageController
                                                                    .userInfo
                                                                    .value
                                                                    .id)
                                                        ? const SizedBox()
                                                        : Container(
                                                            decoration:
                                                                BoxDecoration(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          10),
                                                              color: const Color(
                                                                  0xfff3f3f2),
                                                            ),
                                                            child: Text(
                                                              noteDetailsImageController
                                                                          .commentList[
                                                                              index]
                                                                          .comment
                                                                          .commentUserId ==
                                                                      noteDetailsImageController
                                                                          .notes
                                                                          .value
                                                                          .belongUserId
                                                                  ? '作者'
                                                                  : '我',
                                                              style:
                                                                  const TextStyle(
                                                                fontSize: 14,
                                                                color: Color(
                                                                    0xffafafb0),
                                                              ),
                                                            ).paddingOnly(
                                                                left: 10,
                                                                right: 10),
                                                          ),
                                                  ],
                                                ),
                                                ExtendedTextField(
                                                  onTap: () {
                                                    Map<String, String> map =
                                                        {};
                                                    map['id'] =
                                                        noteDetailsImageController
                                                            .commentList[index]
                                                            .comment
                                                            .commentUserId
                                                            .toString();
                                                    map['name'] =
                                                        noteDetailsImageController
                                                            .commentList[index]
                                                            .comment
                                                            .commentUserName;
                                                    noteDetailsImageController
                                                        .judgeSameReply(
                                                            jsonEncode(map),
                                                            noteDetailsImageController
                                                                .commentList[
                                                                    index]
                                                                .comment
                                                                .id,
                                                            noteDetailsImageController
                                                                .commentList[
                                                                    index]
                                                                .comment
                                                                .id);
                                                    noteDetailsImageController
                                                        .replyUserInfo
                                                        .value = '';
                                                    noteDetailsImageController
                                                        .showBottomInput();
                                                  },
                                                  readOnly: true,
                                                  maxLines: null,
                                                  textAlignVertical:
                                                      TextAlignVertical.top,
                                                  decoration:
                                                      const InputDecoration(
                                                    isCollapsed: true,
                                                    border: InputBorder.none,
                                                    contentPadding:
                                                        EdgeInsets.all(0),
                                                  ),
                                                  style: const TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.black,
                                                  ),
                                                  textAlign: TextAlign.start,
                                                  scrollPadding:
                                                      const EdgeInsets.all(0),
                                                  controller:
                                                      TextEditingController()
                                                        ..text =
                                                            noteDetailsImageController
                                                                .commentList[
                                                                    index]
                                                                .comment
                                                                .content
                                                                .fixAutoLines(),
                                                  specialTextSpanBuilder:
                                                      MySpecialTextSpanBuilder(),
                                                ),
                                                noteDetailsImageController
                                                            .commentList[index]
                                                            .comment
                                                            .pictureUrl ==
                                                        ''
                                                    ? const SizedBox()
                                                    : GestureDetector(
                                                        onTap: () {
                                                          Get.toNamed(
                                                            '/image/simple/pre',
                                                            arguments:
                                                                noteDetailsImageController
                                                                    .commentList[
                                                                        index]
                                                                    .comment
                                                                    .pictureUrl,
                                                          );
                                                        },
                                                        child: ConstrainedBox(
                                                          constraints:
                                                              BoxConstraints(
                                                                  maxWidth: Adapt
                                                                      .setRpx(
                                                                          450),
                                                                  maxHeight: Adapt
                                                                      .setRpx(
                                                                          500)),
                                                          child: ClipRRect(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        10),
                                                            child: Builder(
                                                                builder:
                                                                    (context) {
                                                              return CachedNetworkImage(
                                                                fit: BoxFit
                                                                    .contain,
                                                                imageUrl: noteDetailsImageController
                                                                    .commentList[
                                                                        index]
                                                                    .comment
                                                                    .pictureUrl,
                                                                maxWidthDiskCache:
                                                                    context
                                                                        .width
                                                                        .toInt(),
                                                                maxHeightDiskCache:
                                                                    context
                                                                        .height
                                                                        .toInt(),
                                                                progressIndicatorBuilder:
                                                                    (context,
                                                                        url,
                                                                        downloadProgress) {
                                                                  return Center(
                                                                    child:
                                                                        CircularProgressIndicator(
                                                                      value: downloadProgress
                                                                          .progress,
                                                                    ),
                                                                  );
                                                                },
                                                                errorWidget:
                                                                    (context,
                                                                        url,
                                                                        error) {
                                                                  return const Center(
                                                                    child:
                                                                        Column(
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .center,
                                                                      children: [
                                                                        Icon(
                                                                          Icons
                                                                              .running_with_errors_sharp,
                                                                          color:
                                                                              Colors.black45,
                                                                        ),
                                                                        Text(
                                                                          '加载失败了',
                                                                          style:
                                                                              TextStyle(
                                                                            color:
                                                                                Colors.black45,
                                                                            fontSize:
                                                                                12,
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  );
                                                                },
                                                              );
                                                            }),
                                                          ),
                                                        ).paddingOnly(top: 10),
                                                      ),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.end,
                                                  children: [
                                                    Text(
                                                      maxLines: 1,
                                                      "${noteDetailsImageController.commentList[index].comment.showTime}   ${noteDetailsImageController.commentList[index].comment.province}   回复",
                                                      textAlign: TextAlign.end,
                                                      style: const TextStyle(
                                                        height: 1.2,
                                                        fontSize: 12,
                                                        color: CustomColor
                                                            .unselectedColor,
                                                      ),
                                                    ),
                                                  ],
                                                ).paddingOnly(top: 10),
                                                noteDetailsImageController
                                                        .commentList[index]
                                                        .comment
                                                        .isTop
                                                    ? Container(
                                                        decoration:
                                                            const BoxDecoration(
                                                          color:
                                                              Color(0xfffdeff2),
                                                          borderRadius:
                                                              BorderRadius.all(
                                                            Radius.circular(20),
                                                          ),
                                                        ),
                                                        child: const Text(
                                                          '置顶评论',
                                                          style: TextStyle(
                                                            color: CustomColor
                                                                .primaryColor,
                                                            fontSize: 12,
                                                          ),
                                                        ).paddingOnly(
                                                            left: 10,
                                                            right: 10,
                                                            top: 2,
                                                            bottom: 2),
                                                      ).paddingOnly(top: 8)
                                                    : const SizedBox(),
                                              ],
                                            ),
                                          ),
                                        ),
                                        const SizedBox(
                                          width: 10,
                                        ),
                                        LikeButton(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          likeCountPadding:
                                              const EdgeInsets.all(0),
                                          countPostion: CountPostion.bottom,
                                          likeBuilder: (bool isLiked) {
                                            return Icon(
                                              isLiked
                                                  ? Icons.favorite
                                                  : Icons.favorite_border,
                                              color: isLiked
                                                  ? CustomColor.primaryColor
                                                  : Colors.black54,
                                              size: 20,
                                            );
                                          },
                                          isLiked: noteDetailsImageController
                                              .commentList[index]
                                              .comment
                                              .isLike,
                                          likeCount: noteDetailsImageController
                                              .commentList[index]
                                              .comment
                                              .commentLikeNum,
                                          onTap: (bool isLiked) async {
                                            noteDetailsImageController
                                                .commentList[index]
                                                .comment
                                                .isLike = !isLiked;
                                            noteDetailsImageController
                                                    .commentList[index]
                                                    .comment
                                                    .isLike
                                                ? noteDetailsImageController
                                                    .commentList[index]
                                                    .comment
                                                    .commentLikeNum++
                                                : noteDetailsImageController
                                                    .commentList[index]
                                                    .comment
                                                    .commentLikeNum--;
                                            CommentApi.praiseComment(
                                                noteDetailsImageController
                                                    .commentList[index]
                                                    .comment
                                                    .id,
                                                noteDetailsImageController
                                                    .userInfo.value.id,
                                                noteDetailsImageController
                                                    .commentList[index]
                                                    .comment
                                                    .commentUserId);
                                            return !isLiked;
                                          },
                                        ),
                                      ],
                                    ),
                                    ListView.builder(
                                      padding: const EdgeInsets.only(
                                          top: 10, left: 50),
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      itemBuilder: (context, i) {
                                        return Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                              width: 30,
                                              height: 30,
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                                image: DecorationImage(
                                                  image: NetworkImage(
                                                      noteDetailsImageController
                                                          .commentList[index]
                                                          .childCommentList[i]
                                                          .commentUserAvatar,
                                                      scale: 1.0),
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(
                                              width: 10,
                                            ),
                                            Expanded(
                                              flex: 1,
                                              child: GestureDetector(
                                                onTap: () {
                                                  // 回复
                                                  Map<String, String> map = {};
                                                  map['id'] =
                                                      noteDetailsImageController
                                                          .commentList[index]
                                                          .childCommentList[i]
                                                          .commentUserId
                                                          .toString();
                                                  map['name'] =
                                                      noteDetailsImageController
                                                          .commentList[index]
                                                          .childCommentList[i]
                                                          .commentUserName;
                                                  noteDetailsImageController
                                                      .judgeSameReply(
                                                          jsonEncode(map),
                                                          noteDetailsImageController
                                                              .commentList[
                                                                  index]
                                                              .comment
                                                              .id,
                                                          noteDetailsImageController
                                                              .commentList[
                                                                  index]
                                                              .childCommentList[
                                                                  i]
                                                              .id);
                                                  noteDetailsImageController
                                                      .showBottomInput();
                                                },
                                                onLongPress: () {
                                                  Get.bottomSheet(
                                                    SingleChildScrollView(
                                                      child: Container(
                                                        width: double.infinity,
                                                        decoration:
                                                            const BoxDecoration(
                                                          color: Colors.white,
                                                          borderRadius:
                                                              BorderRadius.only(
                                                            topLeft:
                                                                Radius.circular(
                                                                    10),
                                                            topRight:
                                                                Radius.circular(
                                                                    10),
                                                          ),
                                                        ),
                                                        child: Column(
                                                          children: [
                                                            GestureDetector(
                                                              onTap: () {
                                                                if (Get
                                                                    .isBottomSheetOpen!) {
                                                                  Get.back();
                                                                }
                                                                Map<String,
                                                                        String>
                                                                    map = {};
                                                                map['id'] = noteDetailsImageController
                                                                    .commentList[
                                                                        index]
                                                                    .childCommentList[
                                                                        i]
                                                                    .commentUserId
                                                                    .toString();
                                                                map['name'] = noteDetailsImageController
                                                                    .commentList[
                                                                        index]
                                                                    .childCommentList[
                                                                        i]
                                                                    .commentUserName;
                                                                noteDetailsImageController.judgeSameReply(
                                                                    jsonEncode(
                                                                        map),
                                                                    noteDetailsImageController
                                                                        .commentList[
                                                                            index]
                                                                        .comment
                                                                        .id,
                                                                    noteDetailsImageController
                                                                        .commentList[
                                                                            index]
                                                                        .childCommentList[
                                                                            i]
                                                                        .id);
                                                                noteDetailsImageController
                                                                    .showBottomInput();
                                                              },
                                                              child: Container(
                                                                width: double
                                                                    .infinity,
                                                                decoration:
                                                                    const BoxDecoration(
                                                                  border:
                                                                      Border(
                                                                    bottom:
                                                                        BorderSide(
                                                                      color: Color(
                                                                          0xffe5e5e5),
                                                                      width:
                                                                          0.5,
                                                                    ),
                                                                  ),
                                                                ),
                                                                child: Expanded(
                                                                  flex: 1,
                                                                  child:
                                                                      const Text(
                                                                    "回复",
                                                                    textAlign:
                                                                        TextAlign
                                                                            .center,
                                                                    style:
                                                                        TextStyle(
                                                                      fontSize:
                                                                          16,
                                                                      color: Colors
                                                                          .black,
                                                                    ),
                                                                  ).paddingAll(
                                                                          10),
                                                                ),
                                                              ),
                                                            ),
                                                            GestureDetector(
                                                              onTap: () {
                                                                if (Get
                                                                    .isBottomSheetOpen!) {
                                                                  Get.back();
                                                                }
                                                                copyToClipboard(parseSpecialText(noteDetailsImageController
                                                                    .commentList[
                                                                        index]
                                                                    .childCommentList[
                                                                        i]
                                                                    .content));
                                                              },
                                                              child: Container(
                                                                width: double
                                                                    .infinity,
                                                                decoration:
                                                                    const BoxDecoration(
                                                                  border:
                                                                      Border(
                                                                    bottom:
                                                                        BorderSide(
                                                                      color: Color(
                                                                          0xffe5e5e5),
                                                                      width:
                                                                          0.5,
                                                                    ),
                                                                  ),
                                                                ),
                                                                child: Expanded(
                                                                  flex: 1,
                                                                  child:
                                                                      const Text(
                                                                    "复制",
                                                                    textAlign:
                                                                        TextAlign
                                                                            .center,
                                                                    style:
                                                                        TextStyle(
                                                                      fontSize:
                                                                          16,
                                                                      color: Colors
                                                                          .black,
                                                                    ),
                                                                  ).paddingAll(
                                                                          10),
                                                                ),
                                                              ),
                                                            ),
                                                            (noteDetailsImageController
                                                                            .notes
                                                                            .value
                                                                            .belongUserId ==
                                                                        noteDetailsImageController
                                                                            .userInfo
                                                                            .value
                                                                            .id) ||
                                                                    (noteDetailsImageController
                                                                            .commentList[
                                                                                index]
                                                                            .childCommentList[
                                                                                i]
                                                                            .commentUserId ==
                                                                        noteDetailsImageController
                                                                            .userInfo
                                                                            .value
                                                                            .id)
                                                                ? GestureDetector(
                                                                    onTap: () {
                                                                      if (Get
                                                                          .isBottomSheetOpen!) {
                                                                        Get.back();
                                                                      }
                                                                      CommentApi.deleteComment(noteDetailsImageController
                                                                          .commentList[
                                                                              index]
                                                                          .childCommentList[
                                                                              i]
                                                                          .id);
                                                                      noteDetailsImageController
                                                                          .commentList[
                                                                              index]
                                                                          .childCommentList
                                                                          .removeAt(
                                                                              i);
                                                                      noteDetailsImageController
                                                                          .commentList
                                                                          .refresh();
                                                                    },
                                                                    child:
                                                                        Container(
                                                                      width: double
                                                                          .infinity,
                                                                      decoration:
                                                                          const BoxDecoration(
                                                                        border:
                                                                            Border(
                                                                          bottom:
                                                                              BorderSide(
                                                                            color:
                                                                                Color(0xffe5e5e5),
                                                                            width:
                                                                                0.5,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      child:
                                                                          Expanded(
                                                                        flex: 1,
                                                                        child:
                                                                            const Text(
                                                                          "删除",
                                                                          textAlign:
                                                                              TextAlign.center,
                                                                          style:
                                                                              TextStyle(
                                                                            fontSize:
                                                                                16,
                                                                            color:
                                                                                Colors.black,
                                                                          ),
                                                                        ).paddingAll(10),
                                                                      ),
                                                                    ),
                                                                  )
                                                                : const SizedBox(),
                                                            Container(
                                                              height: 15,
                                                              width: double
                                                                  .infinity,
                                                              color: const Color(
                                                                  0xfff3f3f2),
                                                            ),
                                                            GestureDetector(
                                                              onTap: () {
                                                                Get.back();
                                                              },
                                                              child: Container(
                                                                width: double
                                                                    .infinity,
                                                                decoration:
                                                                    const BoxDecoration(
                                                                  border:
                                                                      Border(
                                                                    bottom:
                                                                        BorderSide(
                                                                      color: Color(
                                                                          0xffe5e5e5),
                                                                      width:
                                                                          0.5,
                                                                    ),
                                                                  ),
                                                                ),
                                                                child: Expanded(
                                                                  flex: 1,
                                                                  child:
                                                                      const Text(
                                                                    "取消",
                                                                    textAlign:
                                                                        TextAlign
                                                                            .center,
                                                                    style:
                                                                        TextStyle(
                                                                      fontSize:
                                                                          16,
                                                                      color: Colors
                                                                          .black,
                                                                    ),
                                                                  ).paddingAll(
                                                                          10),
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  );
                                                },
                                                behavior:
                                                    HitTestBehavior.opaque,
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          noteDetailsImageController
                                                              .commentList[
                                                                  index]
                                                              .childCommentList[
                                                                  i]
                                                              .commentUserName,
                                                          style:
                                                              const TextStyle(
                                                            fontSize: 14,
                                                            color: CustomColor
                                                                .unselectedColor,
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                          width: 10,
                                                        ),
                                                        (noteDetailsImageController
                                                                        .commentList[
                                                                            index]
                                                                        .childCommentList[
                                                                            i]
                                                                        .commentUserId !=
                                                                    noteDetailsImageController
                                                                        .notes
                                                                        .value
                                                                        .belongUserId) &&
                                                                (noteDetailsImageController
                                                                        .commentList[
                                                                            index]
                                                                        .childCommentList[
                                                                            i]
                                                                        .commentUserId !=
                                                                    noteDetailsImageController
                                                                        .userInfo
                                                                        .value
                                                                        .id)
                                                            ? const SizedBox()
                                                            : Container(
                                                                decoration:
                                                                    BoxDecoration(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              10),
                                                                  color: const Color(
                                                                      0xfff3f3f2),
                                                                ),
                                                                child: Text(
                                                                  noteDetailsImageController
                                                                              .commentList[
                                                                                  index]
                                                                              .childCommentList[
                                                                                  i]
                                                                              .commentUserId ==
                                                                          noteDetailsImageController
                                                                              .notes
                                                                              .value
                                                                              .belongUserId
                                                                      ? '作者'
                                                                      : '我',
                                                                  style:
                                                                      const TextStyle(
                                                                    fontSize:
                                                                        14,
                                                                    color: Color(
                                                                        0xffafafb0),
                                                                  ),
                                                                ).paddingOnly(
                                                                    left: 10,
                                                                    right: 10),
                                                              ),
                                                      ],
                                                    ),
                                                    ExtendedTextField(
                                                      onTap: () {
                                                        Map<String, String>
                                                            map = {};
                                                        map['id'] =
                                                            noteDetailsImageController
                                                                .commentList[
                                                                    index]
                                                                .childCommentList[
                                                                    i]
                                                                .commentUserId
                                                                .toString();
                                                        map['name'] =
                                                            noteDetailsImageController
                                                                .commentList[
                                                                    index]
                                                                .childCommentList[
                                                                    i]
                                                                .commentUserName;
                                                        noteDetailsImageController
                                                            .judgeSameReply(
                                                                jsonEncode(map),
                                                                noteDetailsImageController
                                                                    .commentList[
                                                                        index]
                                                                    .comment
                                                                    .id,
                                                                noteDetailsImageController
                                                                    .commentList[
                                                                        index]
                                                                    .childCommentList[
                                                                        i]
                                                                    .id);
                                                        noteDetailsImageController
                                                            .showBottomInput();
                                                      },
                                                      readOnly: true,
                                                      maxLines: null,
                                                      textAlignVertical:
                                                          TextAlignVertical.top,
                                                      decoration:
                                                          const InputDecoration(
                                                        isCollapsed: true,
                                                        border:
                                                            InputBorder.none,
                                                        contentPadding:
                                                            EdgeInsets.all(0),
                                                      ),
                                                      style: const TextStyle(
                                                        fontSize: 14,
                                                        color: Colors.black,
                                                      ),
                                                      textAlign:
                                                          TextAlign.start,
                                                      scrollPadding:
                                                          const EdgeInsets.all(
                                                              0),
                                                      controller: TextEditingController()
                                                        ..text =
                                                            noteDetailsImageController
                                                                .commentList[
                                                                    index]
                                                                .childCommentList[
                                                                    i]
                                                                .content
                                                                .fixAutoLines(),
                                                      specialTextSpanBuilder:
                                                          MySpecialTextSpanBuilder(),
                                                    ),
                                                    noteDetailsImageController
                                                                .commentList[
                                                                    index]
                                                                .childCommentList[
                                                                    i]
                                                                .pictureUrl ==
                                                            ''
                                                        ? const SizedBox()
                                                        : GestureDetector(
                                                            onTap: () {
                                                              Get.toNamed(
                                                                '/image/simple/pre',
                                                                arguments: noteDetailsImageController
                                                                    .commentList[
                                                                        index]
                                                                    .childCommentList[
                                                                        i]
                                                                    .pictureUrl,
                                                              );
                                                            },
                                                            child:
                                                                ConstrainedBox(
                                                              constraints: BoxConstraints(
                                                                  maxWidth: Adapt
                                                                      .setRpx(
                                                                          300),
                                                                  maxHeight: Adapt
                                                                      .setRpx(
                                                                          500)),
                                                              child: ClipRRect(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            10),
                                                                child: Builder(
                                                                    builder:
                                                                        (context) {
                                                                  return CachedNetworkImage(
                                                                    fit: BoxFit
                                                                        .contain,
                                                                    imageUrl: noteDetailsImageController
                                                                        .commentList[
                                                                            index]
                                                                        .childCommentList[
                                                                            i]
                                                                        .pictureUrl,
                                                                    maxWidthDiskCache:
                                                                        context
                                                                            .width
                                                                            .toInt(),
                                                                    maxHeightDiskCache:
                                                                        context
                                                                            .height
                                                                            .toInt(),
                                                                    progressIndicatorBuilder:
                                                                        (context,
                                                                            url,
                                                                            downloadProgress) {
                                                                      return Center(
                                                                        child:
                                                                            CircularProgressIndicator(
                                                                          value:
                                                                              downloadProgress.progress,
                                                                        ),
                                                                      );
                                                                    },
                                                                    errorWidget:
                                                                        (context,
                                                                            url,
                                                                            error) {
                                                                      return const Center(
                                                                        child:
                                                                            Column(
                                                                          mainAxisAlignment:
                                                                              MainAxisAlignment.center,
                                                                          children: [
                                                                            Icon(
                                                                              Icons.running_with_errors_sharp,
                                                                              color: Colors.black45,
                                                                            ),
                                                                            Text(
                                                                              '加载失败了',
                                                                              style: TextStyle(
                                                                                color: Colors.black45,
                                                                                fontSize: 12,
                                                                              ),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      );
                                                                    },
                                                                  );
                                                                }),
                                                              ),
                                                            ).paddingOnly(
                                                                    top: 10),
                                                          ),
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .start,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .end,
                                                      children: [
                                                        Text(
                                                          maxLines: 1,
                                                          "${noteDetailsImageController.commentList[index].childCommentList[i].showTime}   ${noteDetailsImageController.commentList[index].childCommentList[i].province}   回复",
                                                          textAlign:
                                                              TextAlign.end,
                                                          style:
                                                              const TextStyle(
                                                            height: 1.2,
                                                            fontSize: 12,
                                                            color: CustomColor
                                                                .unselectedColor,
                                                          ),
                                                        ),
                                                      ],
                                                    ).paddingOnly(top: 10),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            const SizedBox(
                                              width: 10,
                                            ),
                                            LikeButton(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.end,
                                              likeCountPadding:
                                                  const EdgeInsets.all(0),
                                              countPostion: CountPostion.bottom,
                                              likeBuilder: (bool isLiked) {
                                                return Icon(
                                                  isLiked
                                                      ? Icons.favorite
                                                      : Icons.favorite_border,
                                                  color: isLiked
                                                      ? CustomColor.primaryColor
                                                      : Colors.black54,
                                                  size: 20,
                                                );
                                              },
                                              isLiked:
                                                  noteDetailsImageController
                                                      .commentList[index]
                                                      .childCommentList[i]
                                                      .isLike,
                                              likeCount:
                                                  noteDetailsImageController
                                                      .commentList[index]
                                                      .childCommentList[i]
                                                      .commentLikeNum,
                                              onTap: (bool isLiked) async {
                                                noteDetailsImageController
                                                    .commentList[index]
                                                    .childCommentList[i]
                                                    .isLike = !isLiked;
                                                noteDetailsImageController
                                                        .commentList[index]
                                                        .childCommentList[i]
                                                        .isLike
                                                    ? noteDetailsImageController
                                                        .commentList[index]
                                                        .childCommentList[i]
                                                        .commentLikeNum++
                                                    : noteDetailsImageController
                                                        .commentList[index]
                                                        .childCommentList[i]
                                                        .commentLikeNum--;
                                                CommentApi.praiseComment(
                                                    noteDetailsImageController
                                                        .commentList[index]
                                                        .childCommentList[i]
                                                        .id,
                                                    noteDetailsImageController
                                                        .userInfo.value.id,
                                                    noteDetailsImageController
                                                        .commentList[index]
                                                        .childCommentList[i]
                                                        .commentUserId);
                                                return !isLiked;
                                              },
                                            ),
                                          ],
                                        ).paddingOnly(bottom: 10);
                                      },
                                      itemCount: noteDetailsImageController
                                          .commentList[index]
                                          .childCommentList
                                          .length,
                                      shrinkWrap: true,
                                    ),
                                    noteDetailsImageController
                                                    .commentList[index]
                                                    .comment
                                                    .commentReplyNum !=
                                                0 &&
                                            noteDetailsImageController
                                                    .commentList[index].page ==
                                                1 &&
                                            noteDetailsImageController
                                                .commentList[index].hasMore &&
                                            !noteDetailsImageController
                                                .commentList[index].isLoadMore
                                        ? GestureDetector(
                                            onTap: () {
                                              noteDetailsImageController
                                                  .loadSecondComment(
                                                noteDetailsImageController
                                                    .notes.value.id,
                                                noteDetailsImageController
                                                    .commentList[index]
                                                    .comment
                                                    .id,
                                              );
                                            },
                                            child: Text(
                                              "—— 展开${noteDetailsImageController.commentList[index].comment.commentReplyNum}条回复 ——",
                                              style: const TextStyle(
                                                  color: Color(0xff89c3eb),
                                                  fontSize: 14),
                                            ).paddingOnly(top: 10, left: 60),
                                          )
                                        : noteDetailsImageController
                                                .commentList[index].isLoadMore
                                            ? const Text(
                                                "—— 正在加载 ——",
                                                style: TextStyle(
                                                    color: Color(0xff89c3eb),
                                                    fontSize: 14),
                                              ).paddingOnly(top: 10, left: 60)
                                            : noteDetailsImageController
                                                            .commentList[index]
                                                            .page !=
                                                        1 &&
                                                    noteDetailsImageController
                                                        .commentList[index]
                                                        .hasMore
                                                ? GestureDetector(
                                                    onTap: () {
                                                      noteDetailsImageController
                                                          .loadSecondComment(
                                                        noteDetailsImageController
                                                            .notes.value.id,
                                                        noteDetailsImageController
                                                            .commentList[index]
                                                            .comment
                                                            .id,
                                                      );
                                                    },
                                                    child: const Text(
                                                      "—— 展开更多 ——",
                                                      style: TextStyle(
                                                          color:
                                                              Color(0xff89c3eb),
                                                          fontSize: 14),
                                                    ).paddingOnly(
                                                        top: 10, left: 60),
                                                  )
                                                : const SizedBox(),
                                    Container(
                                      height: 1,
                                      decoration: const BoxDecoration(
                                        border: Border(
                                          bottom: BorderSide(
                                            color: Color(0xffe5e5e5),
                                            width: 0.5,
                                          ),
                                        ),
                                      ),
                                    ).paddingOnly(
                                        top: 10,
                                        bottom: 10,
                                        left: 50,
                                        right: 50),
                                  ],
                                );
                              },
                              itemCount:
                                  noteDetailsImageController.commentList.length,
                              shrinkWrap: true,
                            ),
                          ],
                        ).paddingOnly(left: 10, right: 10, bottom: 10),
                      ],
                    ),
                    !noteDetailsImageController.hasMore.value
                        ? const SizedBox(
                            height: 30,
                            child: Center(
                              child: Text(
                                '没有更多了',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: CustomColor.unselectedColor,
                                ),
                              ),
                            ),
                          )
                        : noteDetailsImageController.isLoadMore.value
                            ? const SizedBox(
                                child: Center(
                                  child: CircularProgressIndicator(),
                                ),
                              )
                            : const SizedBox()
                  ],
                ).paddingOnly(bottom: 70),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: 56,
                  color: Colors.white,
                  child: Row(
                    children: [
                      Expanded(
                        flex: 1,
                        child: GestureDetector(
                          onTap: () {
                            noteDetailsImageController.judgeSameReply(
                                '', '', '');
                            noteDetailsImageController.showBottomInput();
                          },
                          child: Container(
                            height: 56,
                            decoration: BoxDecoration(
                              color: const Color(0xfff3f3f2),
                              borderRadius: BorderRadius.circular(25),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.edit_note_rounded,
                                  size: 20,
                                  color: Color(0xffafafb0),
                                ).paddingOnly(left: 5),
                                const Text(
                                  '说点什么...',
                                  style: TextStyle(
                                    color: Color(0xffafafb0),
                                    fontSize: 16,
                                  ),
                                ).paddingOnly(left: 5, right: 15),
                              ],
                            ),
                          ).paddingAll(10),
                        ),
                      ),
                      LikeButton(
                        mainAxisAlignment: MainAxisAlignment.center,
                        countPostion: CountPostion.right,
                        likeCountPadding: const EdgeInsets.all(10),
                        likeBuilder: (bool isLiked) {
                          return Icon(
                            isLiked ? Icons.favorite : Icons.favorite_border,
                            color: isLiked
                                ? CustomColor.primaryColor
                                : const Color(0xff2b2b2b),
                            size: 32,
                          );
                        },
                        countBuilder: (int? count, bool isLiked, String text) {
                          count ??= 0;
                          return count == 0
                              ? const SizedBox()
                              : Text(
                                  text,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Color(0xff2b2b2b),
                                  ),
                                );
                        },
                        isLiked: noteDetailsImageController.notes.value.isLike,
                        likeCount:
                            noteDetailsImageController.notes.value.notesLikeNum,
                        onTap: (bool isLiked) async {
                          noteDetailsImageController.notes.value.isLike =
                              !isLiked;
                          noteDetailsImageController.notes.value.isLike
                              ? noteDetailsImageController
                                  .notes.value.notesLikeNum++
                              : noteDetailsImageController
                                  .notes.value.notesLikeNum--;
                          NoteApi.praiseNotes(
                              noteDetailsImageController.notes.value.id,
                              noteDetailsImageController.userInfo.value.id,
                              noteDetailsImageController
                                  .notes.value.belongUserId);
                          return !isLiked;
                        },
                      ),
                      LikeButton(
                        mainAxisAlignment: MainAxisAlignment.center,
                        countPostion: CountPostion.right,
                        likeCountPadding: const EdgeInsets.all(10),
                        likeBuilder: (bool isLiked) {
                          return Icon(
                            isLiked ? Icons.star : Icons.star_border,
                            color: isLiked
                                ? const Color(0xfffbd26b)
                                : const Color(0xff2b2b2b),
                            size: 32,
                          );
                        },
                        countBuilder: (int? count, bool isLiked, String text) {
                          count ??= 0;
                          return count == 0
                              ? const SizedBox()
                              : Text(
                                  text,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                      fontSize: 14, color: Color(0xff2b2b2b)),
                                );
                        },
                        isLiked:
                            noteDetailsImageController.notes.value.isCollect,
                        likeCount: noteDetailsImageController
                            .notes.value.notesCollectNum,
                        onTap: (bool isLiked) async {
                          noteDetailsImageController.notes.value.isCollect =
                              !isLiked;
                          noteDetailsImageController.notes.value.isCollect
                              ? noteDetailsImageController
                                  .notes.value.notesCollectNum++
                              : noteDetailsImageController
                                  .notes.value.notesCollectNum--;
                          NoteApi.collectNotes(
                              noteDetailsImageController.notes.value.id,
                              noteDetailsImageController.userInfo.value.id,
                              noteDetailsImageController
                                  .notes.value.belongUserId);
                          return !isLiked;
                        },
                      ),
                      LikeButton(
                        mainAxisAlignment: MainAxisAlignment.center,
                        countPostion: CountPostion.right,
                        likeCountPadding: const EdgeInsets.all(10),
                        likeBuilder: (bool isLiked) {
                          return const Icon(
                            CustomIcon.comment,
                            color: Color(0xff2b2b2b),
                            size: 31,
                          );
                        },
                        countBuilder: (int? count, bool isLiked, String text) {
                          count ??= 0;
                          return count == 0
                              ? const SizedBox()
                              : Text(
                                  text,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                      fontSize: 14, color: Color(0xff2b2b2b)),
                                );
                        },
                        isLiked: false,
                        likeCount:
                            noteDetailsImageController.commentCount.value,
                        onTap: (bool isLiked) async {
                          noteDetailsImageController.judgeSameReply('', '', '');
                          noteDetailsImageController.showBottomInput();
                        },
                      ),
                    ],
                  ).paddingOnly(right: 3),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
