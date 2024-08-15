import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart' as dio;
import 'package:animation_wrappers/animations/faded_slide_animation.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:extended_text_field/extended_text_field.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:image_pickers/image_pickers.dart';
import 'package:xiaofanshu_flutter/apis/app.dart';
import 'package:xiaofanshu_flutter/model/comment.dart';
import 'package:xiaofanshu_flutter/model/notes.dart';
import 'package:xiaofanshu_flutter/model/response.dart';
import 'package:xiaofanshu_flutter/static/custom_code.dart';
import 'package:xiaofanshu_flutter/static/default_data.dart';
import 'package:xiaofanshu_flutter/utils/date_show_util.dart';
import 'package:xiaofanshu_flutter/utils/loading_util.dart';
import 'package:xiaofanshu_flutter/utils/snackbar_util.dart';

import '../config/text_field_config.dart';
import '../model/emoji.dart';
import '../model/user.dart';
import '../static/custom_color.dart';
import '../static/emoji_map.dart';
import '../utils/Adapt.dart';
import '../utils/comment_util.dart';
import '../utils/store_util.dart';

class NoteDetailsImageController extends GetxController {
  var notes = DefaultData.notes.obs;
  var userInfo = DefaultData.user.obs;
  var swiperHeight = 200.0.obs;
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
  TextEditingController contentController = TextEditingController();
  ScrollController scrollController = ScrollController();
  TextEditingController commentController = TextEditingController();
  ScrollController attentionScrollController = ScrollController();

  @override
  Future<void> onInit() async {
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
        Size size = await getImageDimensions(notes.value.notesResources[0].url);
        setSwiperHeight(size.height, size.width);
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

  setSwiperHeight(double imageHeight, double imageWidth) {
    var itemHeight = 0.0;
    var itemWidth = 0.0;
    if (imageWidth >= imageHeight) {
      itemWidth = 750;
      itemHeight = 750 * imageHeight / imageWidth;
    } else {
      if (imageHeight > 1000) {
        itemHeight = 1000;
        itemWidth = 1000 * imageWidth / imageHeight;
        if (itemWidth > 750) {
          itemWidth = 750;
          itemHeight = 750 * imageHeight / imageWidth;
        }
      } else {
        if (imageWidth > 750) {
          itemWidth = 750;
          itemHeight = 750 * imageHeight / imageWidth;
        } else {
          itemWidth = imageWidth;
          itemHeight = imageHeight;
        }
      }
    }
    if (itemHeight > swiperHeight.value) {
      swiperHeight.value = itemHeight;
    }
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

  void loadSendComment(int notesId, String parentId) {
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

  void judgeSameReply(String replyUserInfo, String parentId) {
    if (commentParentId.value != parentId) {
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
                          showToast(
                            '评论成功',
                            context: Get.context,
                            position: const StyledToastPosition(
                              align: Alignment.center,
                            ),
                            animation: StyledToastAnimation.slideFromBottomFade,
                            duration: const Duration(milliseconds: 1500),
                            animDuration: const Duration(milliseconds: 200),
                          );
                        } else {
                          showToast(
                            '评论失败',
                            context: Get.context,
                            position: const StyledToastPosition(
                              align: Alignment.center,
                            ),
                            animation: StyledToastAnimation.slideFromBottomFade,
                            duration: const Duration(milliseconds: 1500),
                            animDuration: const Duration(milliseconds: 200),
                          );
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
}
