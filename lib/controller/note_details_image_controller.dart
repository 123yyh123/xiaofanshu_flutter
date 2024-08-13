import 'dart:convert';

import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:xiaofanshu_flutter/apis/app.dart';
import 'package:xiaofanshu_flutter/model/comment.dart';
import 'package:xiaofanshu_flutter/model/notes.dart';
import 'package:xiaofanshu_flutter/model/response.dart';
import 'package:xiaofanshu_flutter/static/custom_code.dart';
import 'package:xiaofanshu_flutter/static/default_data.dart';
import 'package:xiaofanshu_flutter/utils/date_show_util.dart';

import '../model/user.dart';
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
  TextEditingController contentController = TextEditingController();
  ScrollController scrollController = ScrollController();

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
    scrollController.addListener(() {
      if (scrollController.position.pixels ==
          scrollController.position.maxScrollExtent) {
        loadComment(notesId);
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
              element.childCommentList.add(Comment.fromJson(item));
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
}
