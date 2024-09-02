import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:xiaofanshu_flutter/apis/app.dart';
import 'package:xiaofanshu_flutter/model/response.dart';
import 'package:xiaofanshu_flutter/static/custom_code.dart';
import 'package:xiaofanshu_flutter/utils/snackbar_util.dart';

import '../static/custom_string.dart';
import '../static/default_data.dart';
import '../utils/store_util.dart';

class OtherMineController extends GetxController {
  var userInfo = {}.obs;
  var myUserId = 0.obs;
  final ScrollController scrollController = ScrollController();
  var appBarOpacity = 0.0.obs;
  var tabs = ["笔记", "收藏"];
  var tabsEn = ["notes", "collects"];

  // 0: 我的笔记 1: 我的收藏
  var notesTabType = 0.obs;
  var myNotes = [].obs;
  var lastPressedAt = DateTime.now();
  var lastPressedInfo = '';
  var myNotesPage = 1;
  var myNotesSize = 10;
  var isNotesLoadMore = false;
  var isHasMyNotesMore = true;
  var isShowTopAvatar = false.obs;

  @override
  Future<void> onInit() async {
    // TODO: implement onInit
    super.onInit();
    myUserId.value = int.parse(jsonDecode(
            await readData('userInfo') ?? jsonEncode(DefaultData.user))['id']
        .toString());
    int userId = int.parse(Get.arguments.toString());
    HttpResponse response = await UserApi.viewUserInfo(userId);
    if (response.code == StatusCode.getSuccess) {
      userInfo.value = response.data;
    } else {
      SnackbarUtil.showError('获取用户信息失败');
    }
    userInfo.refresh();
    if (myNotes.isEmpty) {
      myNotesPage = 1;
      getNotesList();
    }
    scrollController.addListener(() {
      // appBar透明度最大值为0.9
      double offset = scrollController.offset;
      Get.log('offset: $offset');
      double opacity = offset / 100;
      if (offset > 100) {
        isShowTopAvatar.value = true;
      } else {
        isShowTopAvatar.value = false;
      }
      appBarOpacity.value = opacity > 0.9 ? 0.9 : opacity;
      if (scrollController.position.pixels ==
          scrollController.position.maxScrollExtent) {
        getNotesList();
      }
    });
  }

  void getNotesList() {
    if (isNotesLoadMore) {
      return;
    }
    isNotesLoadMore = true;
    try {
      if (!isHasMyNotesMore) {
        return;
      }
      NoteApi.getNotesByView(
              myNotesPage, myNotesSize, 0, int.parse(userInfo['id'].toString()))
          .then((res) {
        if (res.code == StatusCode.getSuccess) {
          if (res.data['list'].length < myNotesSize) {
            isHasMyNotesMore = false;
          }
          myNotes.addAll(res.data['list']);
          myNotesPage++;
        }
      });
    } catch (e) {
      SnackbarUtil.showError(ErrorString.networkError);
    } finally {
      isNotesLoadMore = false;
    }
  }
}
