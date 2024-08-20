import 'dart:convert';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart' as dio;
import 'package:animation_wrappers/animations/faded_slide_animation.dart';
import 'package:cached_video_player_plus/cached_video_player_plus.dart';
import 'package:extended_text_field/extended_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animated_progress_bar/flutter_animated_progress_bar.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:get/get.dart';
import 'package:image_pickers/image_pickers.dart';
import 'package:like_button/like_button.dart';
import 'package:xiaofanshu_flutter/model/response.dart';
import '../apis/app.dart';
import '../config/text_field_config.dart';
import '../model/comment.dart';
import '../model/emoji.dart';
import '../model/notes.dart';
import '../model/user.dart';
import '../static/custom_code.dart';
import '../static/custom_color.dart';
import '../static/default_data.dart';
import '../static/emoji_map.dart';
import '../utils/Adapt.dart';
import '../utils/comment_util.dart';
import '../utils/date_show_util.dart';
import '../utils/loading_util.dart';
import '../utils/store_util.dart';
import '../utils/toast_util.dart';

class NoteDetailsVideoController extends GetxController {
  var notes = DefaultData.notes.obs;
  var userInfo = DefaultData.user.obs;
  var commentCount = 0.obs;
  var commentList = List<CommentVO>.empty().obs;
  var commentPage = 1.obs;
  var commentPageSize = 10.obs;
  var isLoadMore = false.obs;
  var hasMore = true.obs;
  var isAllowSendComment = false.obs;
  var isShowAtUser = false.obs;
  var attentionPage = 1.obs;
  var attentionPageSize = 10.obs;
  var attentionIsLoadMore = false.obs;
  var attentionHasMore = true.obs;
  var attentionList = List.empty().obs;
  var isShowEmoji = false.obs;
  var selectImage = ''.obs;
  var replyUserInfo = ''.obs;
  var hintText = '';
  var commentParentId = ''.obs;
  var lastChickCommentId = ''.obs;
  TextEditingController contentController = TextEditingController();
  ScrollController scrollController = ScrollController();
  TextEditingController commentController = TextEditingController();
  ScrollController attentionScrollController = ScrollController();
  late CachedVideoPlayerPlusController videoController;
  late ProgressBarController progressBarController;
  var isInitVideo = false.obs;
  var isVideoPause = false.obs;
  var videoTotalTime = Duration.zero.obs;
  var videoCurrentTime = Duration.zero.obs;
  var videoBuffered = Duration.zero.obs;
  var videoSpeed = 1.0.obs;

  // TODO 评论滚动控制监听

  @override
  void onInit() async {
    // TODO: implement onInit
    super.onInit();
    var notesId = Get.arguments as int;
    Get.log('controller init: $notesId');
    CommentApi.getCommentCountByNotesId(notesId).then((value) {
      if (value.code == StatusCode.getSuccess) {
        commentCount.value = value.data;
      }
    });
    loadComment(notesId);
    NoteApi.getNotesDetail(notesId).then((httpResponse) async {
      if (httpResponse.code == StatusCode.getSuccess) {
        notes.value = Notes.fromJson(httpResponse.data);
        if (notes.value.createTime == notes.value.updateTime) {
          notes.value.createTime = DateShowUtil.showDateWithTime(
            dateStringToTimestamp(notes.value.createTime),
          );
        } else {
          notes.value.createTime = '修改于 ${DateShowUtil.showDateWithTime(
            dateStringToTimestamp(notes.value.updateTime),
          )}';
        }
        contentController.text = notes.value.content.fixAutoLines();
        videoController = CachedVideoPlayerPlusController.networkUrl(
          Uri.parse(notes.value.notesResources[0].url),
        )..initialize().then((value) async {
            isInitVideo.value = true;
            videoController.play();
            videoController.setLooping(true);
            videoTotalTime.value = videoController.value.duration;
            videoController.addListener(() {
              videoCurrentTime.value = videoController.value.position;
              videoBuffered.value = videoController.value.buffered.isNotEmpty
                  ? videoController.value.buffered.last.end
                  : Duration.zero;
              videoSpeed.value = videoController.value.playbackSpeed;
              if (videoController.value.isPlaying) {
                isVideoPause.value = false;
              } else {
                isVideoPause.value = true;
              }
            });
          });
        notes.refresh();
      }
    });
    userInfo.value = User.fromJson(
        jsonDecode(await readData('userInfo') ?? jsonEncode(DefaultData.user)));
    userInfo.refresh();
    loadAttentionList();
    scrollController.addListener(() {
      if (scrollController.position.pixels ==
          scrollController.position.maxScrollExtent) {
        loadComment(notesId);
      }
    });
    commentController.addListener(() {
      if (commentController.text.isNotEmpty) {
        isAllowSendComment.value = true;
      } else {
        isAllowSendComment.value = false;
      }
    });
    attentionScrollController.addListener(() {
      if (attentionScrollController.offset ==
          attentionScrollController.position.maxScrollExtent) {
        loadAttentionList();
      }
    });
  }

  void loadComment(int notesId) {
    if (isLoadMore.value) {
      return;
    }
    isLoadMore.value = true;
    if (!hasMore.value) {
      isLoadMore.value = false;
      return;
    }
    CommentApi.getCommentFirstListByNotesId(
            notesId, commentPage.value, commentPageSize.value)
        .then((value) {
      if (value.code == StatusCode.getSuccess) {
        for (var item in value.data) {
          commentList.add(CommentVO(
            comment: Comment.fromJson(item),
          ));
        }
        commentPage.value++;
        if (value.data.length < commentPageSize.value) {
          hasMore.value = false;
        }
      }
    }).whenComplete(() {
      isLoadMore.value = false;
    });
  }

  void loadSecondComment(int notesId, String parentId) {
    for (var element in commentList) {
      if (element.comment.id == parentId) {
        if (element.isLoadMore) {
          return;
        }
        element.isLoadMore = true;
        commentList.refresh();
        if (!element.hasMore) {
          element.isLoadMore = false;
          commentList.refresh();
          return;
        }
        CommentApi.getCommentSecondListByNotesId(
                notesId, parentId, element.page, element.size)
            .then((value) {
          if (value.code == StatusCode.getSuccess) {
            for (var item in value.data) {
              Comment comment = Comment.fromJson(item);
              if (comment.replyUserId != 0 &&
                  comment.replyUserName.isNotEmpty) {
                Map<String, String> map = {};
                map['userId'] = comment.replyUserId.toString();
                map['name'] = comment.replyUserName;
                String replayInfo = jsonEncode(map);
                comment.content = '回复 ⟬$replayInfo⟭: ${comment.content}';
              }
              element.childCommentList.add(comment);
            }
            element.page++;
            if (value.data.length < element.size) {
              element.hasMore = false;
            }
          }
        }).whenComplete(() {
          element.isLoadMore = false;
          commentList.refresh();
          return;
        });
      }
    }
  }

  void loadAttentionList() {
    if (attentionIsLoadMore.value) {
      return;
    }
    attentionIsLoadMore.value = true;
    if (!attentionHasMore.value) {
      attentionIsLoadMore.value = false;
      return;
    }
    UserApi.getAttentionList(
            userInfo.value.id, attentionPage.value, attentionPageSize.value)
        .then((value) {
      if (value.code == StatusCode.getSuccess) {
        for (var item in value.data) {
          attentionList.add(item);
        }
        attentionPage.value++;
        if (value.data.length < attentionPageSize.value) {
          attentionHasMore.value = false;
        }
      }
    }).whenComplete(() {
      attentionIsLoadMore.value = false;
    });
  }

  void judgeSameReply(String replyUserInfo, String parentId, String commentId) {
    if (lastChickCommentId.value != commentId) {
      lastChickCommentId.value = commentId;
      this.replyUserInfo.value = replyUserInfo;
      commentParentId.value = parentId;
      commentController.text = '';
      selectImage.value = '';
    }
    if (replyUserInfo.isNotEmpty) {
      Map<String, dynamic> map = jsonDecode(replyUserInfo);
      hintText = '回复 ${map['name']}:';
    } else {
      hintText = '';
    }
  }

  void judgeVideoControllerIsInitialized() {
    try {
      isInitVideo.value = videoController.value.isInitialized;
    } catch (e) {
      isInitVideo.value = false;
    }
  }

  void showBottomInput() {
    isShowAtUser.value = false;
    isShowEmoji.value = false;
    Get.bottomSheet(
      Obx(
        () => SingleChildScrollView(
          child: Column(
            children: [
              isShowAtUser.value
                  ? FadedSlideAnimation(
                      beginOffset: const Offset(0, 1),
                      endOffset: Offset.zero,
                      fadeDuration: const Duration(milliseconds: 300),
                      slideDuration: const Duration(milliseconds: 300),
                      child: Container(
                        height: 120,
                        width: double.infinity,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(20),
                            topRight: Radius.circular(20),
                          ),
                        ),
                        child: ListView.builder(
                          controller: attentionScrollController,
                          padding: const EdgeInsets.only(
                            left: 10,
                            right: 10,
                            top: 8,
                          ),
                          scrollDirection: Axis.horizontal,
                          itemCount: attentionList.length,
                          itemBuilder: (BuildContext context, int index) {
                            return GestureDetector(
                              onTap: () {
                                Map<String, String> map = {};
                                map['name'] = attentionList[index]['nickname'];
                                map['id'] = attentionList[index]['userId'];
                                String attentionUserInfo =
                                    '@${jsonEncode(map)} ';
                                insertText(
                                    attentionUserInfo, commentController);
                              },
                              child: Column(
                                children: [
                                  ClipOval(
                                    child: Image.network(
                                      attentionList[index]['avatarUrl'],
                                      width: 50,
                                      height: 50,
                                      fit: BoxFit.cover,
                                    ),
                                  ).paddingAll(10),
                                  Text(
                                    attentionList[index]['nickname'],
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
                  : const SizedBox(),
              Container(
                width: double.infinity,
                color: Colors.white,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 1,
                      child: Container(
                        // height: 56,
                        width: double.infinity,
                        decoration: const BoxDecoration(
                          color: Color(0xfff3f3f2),
                          borderRadius: BorderRadius.all(
                            Radius.circular(20),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 1,
                              child: ExtendedTextField(
                                onTap: () {
                                  isShowAtUser.value = false;
                                  isShowEmoji.value = false;
                                },
                                selectionControls:
                                    CustomTextSelectionControls(),
                                decoration: InputDecoration(
                                  hintText:
                                      hintText == '' ? '说点什么...' : hintText,
                                  isCollapsed: true,
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.all(10),
                                ),
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.black,
                                ),
                                autofocus: true,
                                minLines: 1,
                                maxLines: 3,
                                controller: commentController,
                                specialTextSpanBuilder:
                                    MySpecialTextSpanBuilder(),
                              ).paddingOnly(left: 10, right: 10),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ).paddingOnly(top: 8, bottom: 8, left: 10, right: 10),
              ),
              Container(
                height: 40,
                width: double.infinity,
                color: Colors.white,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GestureDetector(
                          onTap: () {
                            // 显示关注用户
                            isShowAtUser.value = !isShowAtUser.value;
                          },
                          child: const Icon(
                            Icons.alternate_email,
                            color: Color(0xffafafb0),
                            size: 28,
                          ).marginOnly(right: 10),
                        ),
                        GestureDetector(
                          onTap: () {
                            if (isShowEmoji.value) {
                              showKeyboard();
                            } else {
                              closeKeyboardButKeepFocus();
                            }
                            isShowEmoji.value = !isShowEmoji.value;
                          },
                          child: Icon(
                            isShowEmoji.value
                                ? Icons.keyboard_alt_outlined
                                : Icons.emoji_emotions_outlined,
                            color: const Color(0xffafafb0),
                            size: 28,
                          ).marginOnly(right: 10),
                        ),
                        GestureDetector(
                          onTap: () async {
                            List<Media> listImagePaths =
                                await ImagePickers.pickerPaths(
                              galleryMode: GalleryMode.image,
                              selectCount: 1,
                              showCamera: true,
                            );
                            if (listImagePaths.isNotEmpty) {
                              selectImage.value = listImagePaths[0].path!;
                            }
                            showKeyboard();
                          },
                          child: const Icon(
                            Icons.broken_image_outlined,
                            color: Color(0xffafafb0),
                            size: 28,
                          ),
                        ),
                      ],
                    ).paddingOnly(right: 10, top: 5),
                    GestureDetector(
                      onTap: () async {
                        if (commentController.text.isEmpty &&
                            selectImage.value.isEmpty) {
                          return;
                        }
                        LoadingUtil.show();
                        Future.delayed(const Duration(seconds: 6), () {
                          LoadingUtil.hide();
                        });
                        if (selectImage.value.isNotEmpty) {
                          File file = File(selectImage.value);
                          dio.FormData formData = dio.FormData.fromMap({
                            'file': await dio.MultipartFile.fromFile(
                              file.path,
                              filename: file.path.split('/').last,
                            ),
                          });
                          HttpResponse urlResponse =
                              await ThirdApi.uploadImage(formData);
                          if (urlResponse.code == StatusCode.postSuccess) {
                            selectImage.value = urlResponse.data;
                          } else {
                            showToast(
                              '图片上传失败',
                              context: Get.context,
                              position: const StyledToastPosition(
                                align: Alignment.center,
                              ),
                              animation:
                                  StyledToastAnimation.slideFromBottomFade,
                              duration: const Duration(milliseconds: 1500),
                              animDuration: const Duration(milliseconds: 200),
                            );
                          }
                        }
                        var replyUserId;
                        var replyUsername;
                        if (replyUserInfo.isNotEmpty) {
                          Map<String, dynamic> map =
                              jsonDecode(replyUserInfo.value);
                          replyUserId = map['id'] as String;
                          replyUsername = map['name'] as String;
                        } else {
                          replyUserId = 0;
                          replyUsername = '';
                        }
                        Map<String, dynamic> map = {};
                        map['content'] = commentController.text;
                        map['commentUserId'] = userInfo.value.id;
                        map['parentId'] = commentParentId.value == ''
                            ? '0'
                            : commentParentId.value;
                        map['replyUserId'] = replyUserId;
                        map['replyUserName'] = replyUsername;
                        map['pictureUrl'] = selectImage.value;
                        map['notesId'] = notes.value.id;
                        HttpResponse httpResponse =
                            await CommentApi.addComment(map);
                        if (httpResponse.code == StatusCode.postSuccess) {
                          commentCount.value++;
                          Comment comment = Comment.fromJson(httpResponse.data);
                          if (comment.parentId == '0') {
                            // 添加在commentList的头部
                            commentList.insert(
                              0,
                              CommentVO(
                                comment: comment,
                              ),
                            );
                          } else {
                            // 添加在commentList的子评论中
                            for (var element in commentList) {
                              if (element.comment.id == comment.parentId) {
                                if (comment.replyUserId != 0 &&
                                    comment.replyUserName.isNotEmpty) {
                                  Map<String, String> map = {};
                                  map['userId'] =
                                      comment.replyUserId.toString();
                                  map['name'] = comment.replyUserName;
                                  String replayInfo = jsonEncode(map);
                                  comment.content =
                                      '回复 ⟬$replayInfo⟭: ${comment.content}';
                                }
                                if (element.comment.commentReplyNum == 0) {
                                  element.comment.commentReplyNum = 1;
                                  element.hasMore = false;
                                  element.childCommentList.insert(0, comment);
                                } else if (element.page != 1) {
                                  element.childCommentList.insert(0, comment);
                                } else if (element.childCommentList.length <
                                        commentPageSize.value &&
                                    element.childCommentList.isNotEmpty) {
                                  element.childCommentList.insert(0, comment);
                                } else {
                                  element.comment.commentReplyNum++;
                                }
                              }
                            }
                          }
                          commentList.refresh();
                          LoadingUtil.hide();
                          ToastUtil.showSimpleToast('评论成功');
                        } else {
                          ToastUtil.showSimpleToast('评论失败');
                        }
                        commentController.text = '';
                        selectImage.value = '';
                        Get.isBottomSheetOpen ?? false ? Get.back() : null;
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: isAllowSendComment.value ||
                                  selectImage.value.isNotEmpty
                              ? CustomColor.primaryColor
                              : const Color(0xff89c3eb),
                        ),
                        child: const Text(
                          '发送',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white,
                          ),
                        ).paddingOnly(left: 20, right: 20, top: 8, bottom: 8),
                      ).paddingOnly(left: 10),
                    )
                  ],
                ).paddingOnly(left: 10, right: 10),
              ),
              selectImage.value != ''
                  ? Container(
                      color: Colors.white,
                      width: double.infinity,
                      alignment: Alignment.centerLeft,
                      child: SizedBox(
                        height: 70,
                        width: 70,
                        child: Stack(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                image: DecorationImage(
                                  image: FileImage(File(selectImage.value)),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ).paddingAll(10),
                            Positioned(
                              right: 0,
                              top: 0,
                              child: GestureDetector(
                                onTap: () {
                                  selectImage.value = '';
                                },
                                child: Container(
                                  height: 15,
                                  width: 15,
                                  decoration: const BoxDecoration(
                                    color: Colors.black45,
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(10),
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.close,
                                    color: Colors.white,
                                    size: 10,
                                  ),
                                ).paddingAll(3),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : const SizedBox(),
              isShowEmoji.value
                  ? Container(
                      height: Adapt.setRpx(700),
                      width: double.infinity,
                      color: const Color(0xfff3f3f3),
                      child: GridView.builder(
                        padding: const EdgeInsets.all(10),
                        itemCount: EmojiMap.emojiList.length,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
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
                              insertText(text, commentController);
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
                    )
                  : const SizedBox()
            ],
          ),
        ),
      ),
    );
  }

  void openComment() {
    Get.bottomSheet(
      SizedBox(
        height: MediaQuery.of(Get.context!).size.height * 0.6,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 顶部
            Container(
              height: 40,
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.catching_pokemon_rounded,
                    color: Colors.transparent,
                    size: 20,
                  ),
                  Obx(
                    () => commentCount.value == 0
                        ? const Text(
                            "暂无评论",
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black,
                            ),
                          )
                        : Text(
                            "共${commentCount.value}条评论",
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.black,
                            ),
                          ),
                  ),
                  GestureDetector(
                    onTap: () {
                      if (Get.isBottomSheetOpen ?? false) {
                        Get.back();
                      }
                    },
                    child: const Icon(
                      Icons.close,
                      color: Colors.black,
                      size: 20,
                    ),
                  ),
                ],
              ).paddingOnly(left: 15, right: 15),
            ),
            Container(
              height: MediaQuery.of(Get.context!).size.height * 0.6 - 40,
              width: double.infinity,
              color: Colors.white,
              child: Obx(
                () => Stack(
                  children: [
                    SingleChildScrollView(
                      controller: scrollController,
                      child: Column(
                        children: [
                          // 笔记内容,采用评论的形式
                          Container(
                            color: const Color(0xfff3f3f2),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    image: DecorationImage(
                                      image: NetworkImage(notes.value.avatarUrl,
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
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          Text(
                                            notes.value.nickname,
                                            style: const TextStyle(
                                              fontSize: 14,
                                              color:
                                                  CustomColor.unselectedColor,
                                            ),
                                          ),
                                          const SizedBox(
                                            width: 10,
                                          ),
                                          Container(
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              color: const Color(0xffe5e4e6),
                                            ),
                                            child: const Text(
                                              '作者',
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Color(0xff949495),
                                              ),
                                            ).paddingOnly(left: 10, right: 10),
                                          ),
                                        ],
                                      ),
                                      ExtendedTextField(
                                        readOnly: true,
                                        maxLines: null,
                                        selectionControls:
                                            CustomTextSelectionControls(),
                                        textAlignVertical:
                                            TextAlignVertical.top,
                                        decoration: const InputDecoration(
                                          isCollapsed: true,
                                          border: InputBorder.none,
                                          contentPadding: EdgeInsets.all(0),
                                        ),
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: Colors.black,
                                        ),
                                        textAlign: TextAlign.start,
                                        scrollPadding: const EdgeInsets.all(0),
                                        controller: TextEditingController()
                                          ..text = notes.value.content
                                              .fixAutoLines(),
                                        specialTextSpanBuilder:
                                            MySpecialTextSpanBuilder(),
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          Text(
                                            maxLines: 1,
                                            '${notes.value.createTime}   ${notes.value.province}',
                                            textAlign: TextAlign.end,
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color:
                                                  CustomColor.unselectedColor,
                                            ),
                                          ).paddingAll(5),
                                        ],
                                      ).paddingOnly(top: 10),
                                    ],
                                  ),
                                ),
                              ],
                            ).paddingAll(15),
                          ),
                          // 评论区
                          Column(
                            children: [
                              ListView.builder(
                                physics: const NeverScrollableScrollPhysics(),
                                itemBuilder: (context, index) {
                                  return Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                                    commentList[index]
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
                                                map['id'] = commentList[index]
                                                    .comment
                                                    .commentUserId
                                                    .toString();
                                                map['name'] = commentList[index]
                                                    .comment
                                                    .commentUserName;
                                                judgeSameReply(
                                                    jsonEncode(map),
                                                    commentList[index]
                                                        .comment
                                                        .id,
                                                    commentList[index]
                                                        .comment
                                                        .id);
                                                replyUserInfo.value = '';
                                                showBottomInput();
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
                                                          notes.value.belongUserId ==
                                                                  userInfo
                                                                      .value.id
                                                              ? GestureDetector(
                                                                  onTap: () {
                                                                    if (Get
                                                                        .isBottomSheetOpen!) {
                                                                      Get.back();
                                                                    }
                                                                    CommentApi.setTopComment(commentList[index]
                                                                            .comment
                                                                            .id)
                                                                        .then(
                                                                            (value) {
                                                                      if (value
                                                                              .code ==
                                                                          StatusCode
                                                                              .postSuccess) {
                                                                        commentList[0]
                                                                            .comment
                                                                            .isTop = false;
                                                                        commentList[index]
                                                                            .comment
                                                                            .isTop = true;
                                                                        commentList.insert(
                                                                            0,
                                                                            commentList.removeAt(index));
                                                                        commentList
                                                                            .refresh();
                                                                        ToastUtil.showSimpleToast(
                                                                            '置顶成功');
                                                                      } else {
                                                                        ToastUtil.showSimpleToast(
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
                                                                        "置顶",
                                                                        textAlign:
                                                                            TextAlign.center,
                                                                        style:
                                                                            TextStyle(
                                                                          fontSize:
                                                                              16,
                                                                          color:
                                                                              Colors.black,
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
                                                              Map<String,
                                                                      String>
                                                                  map = {};
                                                              map['id'] = commentList[
                                                                      index]
                                                                  .comment
                                                                  .commentUserId
                                                                  .toString();
                                                              map['name'] =
                                                                  commentList[
                                                                          index]
                                                                      .comment
                                                                      .commentUserName;
                                                              judgeSameReply(
                                                                  jsonEncode(
                                                                      map),
                                                                  commentList[
                                                                          index]
                                                                      .comment
                                                                      .id,
                                                                  commentList[
                                                                          index]
                                                                      .comment
                                                                      .id);
                                                              replyUserInfo
                                                                  .value = '';
                                                              showBottomInput();
                                                            },
                                                            child: Container(
                                                              width: double
                                                                  .infinity,
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
                                                              copyToClipboard(parseSpecialText(
                                                                  commentList[
                                                                          index]
                                                                      .comment
                                                                      .content));
                                                            },
                                                            child: Container(
                                                              width: double
                                                                  .infinity,
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
                                                          (notes.value.belongUserId ==
                                                                      userInfo
                                                                          .value
                                                                          .id) ||
                                                                  (commentList[
                                                                              index]
                                                                          .comment
                                                                          .commentUserId ==
                                                                      userInfo
                                                                          .value
                                                                          .id)
                                                              ? GestureDetector(
                                                                  onTap: () {
                                                                    if (Get
                                                                        .isBottomSheetOpen!) {
                                                                      Get.back();
                                                                    }
                                                                    CommentApi.deleteComment(commentList[
                                                                            index]
                                                                        .comment
                                                                        .id);
                                                                    commentList
                                                                        .removeAt(
                                                                            index);
                                                                    commentList
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
                                                              width: double
                                                                  .infinity,
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
                                                        commentList[index]
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
                                                      (commentList[index]
                                                                      .comment
                                                                      .commentUserId !=
                                                                  notes.value
                                                                      .belongUserId) &&
                                                              (commentList[
                                                                          index]
                                                                      .comment
                                                                      .commentUserId !=
                                                                  userInfo
                                                                      .value.id)
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
                                                                commentList[index]
                                                                            .comment
                                                                            .commentUserId ==
                                                                        notes
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
                                                          commentList[index]
                                                              .comment
                                                              .commentUserId
                                                              .toString();
                                                      map['name'] =
                                                          commentList[index]
                                                              .comment
                                                              .commentUserName;
                                                      judgeSameReply(
                                                          jsonEncode(map),
                                                          commentList[index]
                                                              .comment
                                                              .id,
                                                          commentList[index]
                                                              .comment
                                                              .id);
                                                      replyUserInfo.value = '';
                                                      showBottomInput();
                                                    },
                                                    readOnly: true,
                                                    maxLines: null,
                                                    selectionControls:
                                                        CustomTextSelectionControls(),
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
                                                          ..text = commentList[
                                                                  index]
                                                              .comment
                                                              .content
                                                              .fixAutoLines(),
                                                    specialTextSpanBuilder:
                                                        MySpecialTextSpanBuilder(),
                                                  ),
                                                  commentList[index]
                                                              .comment
                                                              .pictureUrl ==
                                                          ''
                                                      ? const SizedBox()
                                                      : GestureDetector(
                                                          onTap: () {
                                                            List<String> list =
                                                                [];
                                                            list.add(commentList[
                                                                    index]
                                                                .comment
                                                                .pictureUrl);
                                                            Get.toNamed(
                                                              '/image/simple/pre',
                                                              arguments: list,
                                                            );
                                                          },
                                                          child: ConstrainedBox(
                                                            constraints: BoxConstraints(
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
                                                                  imageUrl: commentList[
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
                                                                            MainAxisAlignment.center,
                                                                        children: [
                                                                          Icon(
                                                                            Icons.running_with_errors_sharp,
                                                                            color:
                                                                                Colors.black45,
                                                                          ),
                                                                          Text(
                                                                            '加载失败了',
                                                                            style:
                                                                                TextStyle(
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
                                                        MainAxisAlignment.start,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment.end,
                                                    children: [
                                                      Text(
                                                        maxLines: 1,
                                                        "${commentList[index].comment.showTime}   ${commentList[index].comment.province}   回复",
                                                        textAlign:
                                                            TextAlign.end,
                                                        style: const TextStyle(
                                                          height: 1.2,
                                                          fontSize: 12,
                                                          color: CustomColor
                                                              .unselectedColor,
                                                        ),
                                                      ),
                                                    ],
                                                  ).paddingOnly(top: 10),
                                                  commentList[index]
                                                          .comment
                                                          .isTop
                                                      ? Container(
                                                          decoration:
                                                              const BoxDecoration(
                                                            color: Color(
                                                                0xfffdeff2),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .all(
                                                              Radius.circular(
                                                                  20),
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
                                            isLiked: commentList[index]
                                                .comment
                                                .isLike,
                                            likeCount: commentList[index]
                                                .comment
                                                .commentLikeNum,
                                            onTap: (bool isLiked) async {
                                              commentList[index]
                                                  .comment
                                                  .isLike = !isLiked;
                                              commentList[index].comment.isLike
                                                  ? commentList[index]
                                                      .comment
                                                      .commentLikeNum++
                                                  : commentList[index]
                                                      .comment
                                                      .commentLikeNum--;
                                              CommentApi.praiseComment(
                                                  commentList[index].comment.id,
                                                  userInfo.value.id,
                                                  commentList[index]
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
                                                        commentList[index]
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
                                                    Map<String, String> map =
                                                        {};
                                                    map['id'] =
                                                        commentList[index]
                                                            .childCommentList[i]
                                                            .commentUserId
                                                            .toString();
                                                    map['name'] =
                                                        commentList[index]
                                                            .childCommentList[i]
                                                            .commentUserName;
                                                    judgeSameReply(
                                                        jsonEncode(map),
                                                        commentList[index]
                                                            .comment
                                                            .id,
                                                        commentList[index]
                                                            .childCommentList[i]
                                                            .id);
                                                    showBottomInput();
                                                  },
                                                  onLongPress: () {
                                                    Get.bottomSheet(
                                                      SingleChildScrollView(
                                                        child: Container(
                                                          width:
                                                              double.infinity,
                                                          decoration:
                                                              const BoxDecoration(
                                                            color: Colors.white,
                                                            borderRadius:
                                                                BorderRadius
                                                                    .only(
                                                              topLeft: Radius
                                                                  .circular(10),
                                                              topRight: Radius
                                                                  .circular(10),
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
                                                                  map['id'] = commentList[
                                                                          index]
                                                                      .childCommentList[
                                                                          i]
                                                                      .commentUserId
                                                                      .toString();
                                                                  map['name'] = commentList[
                                                                          index]
                                                                      .childCommentList[
                                                                          i]
                                                                      .commentUserName;
                                                                  judgeSameReply(
                                                                      jsonEncode(
                                                                          map),
                                                                      commentList[
                                                                              index]
                                                                          .comment
                                                                          .id,
                                                                      commentList[
                                                                              index]
                                                                          .childCommentList[
                                                                              i]
                                                                          .id);
                                                                  showBottomInput();
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
                                                                  copyToClipboard(parseSpecialText(commentList[
                                                                          index]
                                                                      .childCommentList[
                                                                          i]
                                                                      .content));
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
                                                              (notes.value.belongUserId ==
                                                                          userInfo
                                                                              .value
                                                                              .id) ||
                                                                      (commentList[index]
                                                                              .childCommentList[
                                                                                  i]
                                                                              .commentUserId ==
                                                                          userInfo
                                                                              .value
                                                                              .id)
                                                                  ? GestureDetector(
                                                                      onTap:
                                                                          () {
                                                                        if (Get
                                                                            .isBottomSheetOpen!) {
                                                                          Get.back();
                                                                        }
                                                                        CommentApi.deleteComment(commentList[index]
                                                                            .childCommentList[i]
                                                                            .id);
                                                                        commentList[index]
                                                                            .childCommentList
                                                                            .removeAt(i);
                                                                        commentList
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
                                                                              color: Color(0xffe5e5e5),
                                                                              width: 0.5,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                        child:
                                                                            Expanded(
                                                                          flex:
                                                                              1,
                                                                          child:
                                                                              const Text(
                                                                            "删除",
                                                                            textAlign:
                                                                                TextAlign.center,
                                                                            style:
                                                                                TextStyle(
                                                                              fontSize: 16,
                                                                              color: Colors.black,
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
                                                        CrossAxisAlignment
                                                            .start,
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
                                                            commentList[index]
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
                                                          (commentList[index]
                                                                          .childCommentList[
                                                                              i]
                                                                          .commentUserId !=
                                                                      notes
                                                                          .value
                                                                          .belongUserId) &&
                                                                  (commentList[
                                                                              index]
                                                                          .childCommentList[
                                                                              i]
                                                                          .commentUserId !=
                                                                      userInfo
                                                                          .value
                                                                          .id)
                                                              ? const SizedBox()
                                                              : Container(
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            10),
                                                                    color: const Color(
                                                                        0xfff3f3f2),
                                                                  ),
                                                                  child: Text(
                                                                    commentList[index].childCommentList[i].commentUserId ==
                                                                            notes.value.belongUserId
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
                                                                      right:
                                                                          10),
                                                                ),
                                                        ],
                                                      ),
                                                      ExtendedTextField(
                                                        onTap: () {
                                                          Map<String, String>
                                                              map = {};
                                                          map['id'] = commentList[
                                                                  index]
                                                              .childCommentList[
                                                                  i]
                                                              .commentUserId
                                                              .toString();
                                                          map['name'] = commentList[
                                                                  index]
                                                              .childCommentList[
                                                                  i]
                                                              .commentUserName;
                                                          judgeSameReply(
                                                              jsonEncode(map),
                                                              commentList[index]
                                                                  .comment
                                                                  .id,
                                                              commentList[index]
                                                                  .childCommentList[
                                                                      i]
                                                                  .id);
                                                          showBottomInput();
                                                        },
                                                        readOnly: true,
                                                        maxLines: null,
                                                        selectionControls:
                                                            CustomTextSelectionControls(),
                                                        textAlignVertical:
                                                            TextAlignVertical
                                                                .top,
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
                                                            const EdgeInsets
                                                                .all(0),
                                                        controller: TextEditingController()
                                                          ..text = commentList[
                                                                  index]
                                                              .childCommentList[
                                                                  i]
                                                              .content
                                                              .fixAutoLines(),
                                                        specialTextSpanBuilder:
                                                            MySpecialTextSpanBuilder(),
                                                      ),
                                                      commentList[index]
                                                                  .childCommentList[
                                                                      i]
                                                                  .pictureUrl ==
                                                              ''
                                                          ? const SizedBox()
                                                          : GestureDetector(
                                                              onTap: () {
                                                                List<String>
                                                                    list = [];
                                                                list.add(commentList[
                                                                        index]
                                                                    .childCommentList[
                                                                        i]
                                                                    .pictureUrl);
                                                                Get.toNamed(
                                                                  '/image/simple/pre',
                                                                  arguments:
                                                                      list,
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
                                                                child:
                                                                    ClipRRect(
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
                                                                      imageUrl: commentList[
                                                                              index]
                                                                          .childCommentList[
                                                                              i]
                                                                          .pictureUrl,
                                                                      maxWidthDiskCache: context
                                                                          .width
                                                                          .toInt(),
                                                                      maxHeightDiskCache: context
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
                                                            "${commentList[index].childCommentList[i].showTime}   ${commentList[index].childCommentList[i].province}   回复",
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
                                                countPostion:
                                                    CountPostion.bottom,
                                                likeBuilder: (bool isLiked) {
                                                  return Icon(
                                                    isLiked
                                                        ? Icons.favorite
                                                        : Icons.favorite_border,
                                                    color: isLiked
                                                        ? CustomColor
                                                            .primaryColor
                                                        : Colors.black54,
                                                    size: 20,
                                                  );
                                                },
                                                isLiked: commentList[index]
                                                    .childCommentList[i]
                                                    .isLike,
                                                likeCount: commentList[index]
                                                    .childCommentList[i]
                                                    .commentLikeNum,
                                                onTap: (bool isLiked) async {
                                                  commentList[index]
                                                      .childCommentList[i]
                                                      .isLike = !isLiked;
                                                  commentList[index]
                                                          .childCommentList[i]
                                                          .isLike
                                                      ? commentList[index]
                                                          .childCommentList[i]
                                                          .commentLikeNum++
                                                      : commentList[index]
                                                          .childCommentList[i]
                                                          .commentLikeNum--;
                                                  CommentApi.praiseComment(
                                                      commentList[index]
                                                          .childCommentList[i]
                                                          .id,
                                                      userInfo.value.id,
                                                      commentList[index]
                                                          .childCommentList[i]
                                                          .commentUserId);
                                                  return !isLiked;
                                                },
                                              ),
                                            ],
                                          ).paddingOnly(bottom: 10);
                                        },
                                        itemCount: commentList[index]
                                            .childCommentList
                                            .length,
                                        shrinkWrap: true,
                                      ),
                                      commentList[index]
                                                      .comment
                                                      .commentReplyNum !=
                                                  0 &&
                                              commentList[index].page == 1 &&
                                              commentList[index].hasMore &&
                                              !commentList[index].isLoadMore
                                          ? GestureDetector(
                                              onTap: () {
                                                loadSecondComment(
                                                  notes.value.id,
                                                  commentList[index].comment.id,
                                                );
                                              },
                                              child: Text(
                                                "—— 展开${commentList[index].comment.commentReplyNum}条回复 ——",
                                                style: const TextStyle(
                                                    color: Color(0xff89c3eb),
                                                    fontSize: 14),
                                              ).paddingOnly(top: 10, left: 60),
                                            )
                                          : commentList[index].isLoadMore
                                              ? const Text(
                                                  "—— 正在加载 ——",
                                                  style: TextStyle(
                                                      color: Color(0xff89c3eb),
                                                      fontSize: 14),
                                                ).paddingOnly(top: 10, left: 60)
                                              : commentList[index].page != 1 &&
                                                      commentList[index].hasMore
                                                  ? GestureDetector(
                                                      onTap: () {
                                                        loadSecondComment(
                                                          notes.value.id,
                                                          commentList[index]
                                                              .comment
                                                              .id,
                                                        );
                                                      },
                                                      child: const Text(
                                                        "—— 展开更多 ——",
                                                        style: TextStyle(
                                                            color: Color(
                                                                0xff89c3eb),
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
                                itemCount: commentList.length,
                                shrinkWrap: true,
                              ),
                            ],
                          ).paddingAll(10),
                          !hasMore.value
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
                              : isLoadMore.value
                                  ? const SizedBox(
                                      child: Center(
                                        child: CircularProgressIndicator(),
                                      ),
                                    )
                                  : const SizedBox()
                        ],
                      ).paddingOnly(bottom: 60),
                    ),
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: Container(
                        color: Colors.white,
                        child: Container(
                                height: 40,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  color: const Color(0xfff3f3f2),
                                ),
                                child: GestureDetector(
                                  onTap: () {
                                    Get.log('点击了评论');
                                    Get.log(
                                        'replyUserInfo.value: ${replyUserInfo.value}');
                                    Get.log(
                                        'commentId: ${lastChickCommentId.value}');
                                    judgeSameReply('', '', '');
                                    showBottomInput();
                                  },
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
                                  ).paddingOnly(left: 10, right: 10),
                                ))
                            .paddingOnly(
                                top: 8, bottom: 8, left: 15, right: 15),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }
}
