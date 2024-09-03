import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:xiaofanshu_flutter/apis/app.dart';
import 'package:xiaofanshu_flutter/static/custom_code.dart';
import 'package:xiaofanshu_flutter/utils/loading_util.dart';

class SearchResultController extends GetxController {
  late String keyword;
  late TabController tabController;
  ScrollController notesScrollController = ScrollController();
  ScrollController userScrollController = ScrollController();
  var tabIndex = 0.obs;

  var notesList = [].obs;
  var userList = [].obs;

  // 0：图片笔记，1：视频笔记，2：全部
  var notesType = 2.obs;

  // 0：最新，1：最热，2：全部
  var hotType = 2.obs;

  var notesPage = 1;
  var userPage = 1;
  var notesSize = 10;
  var userSize = 10;
  var isNotesLoading = false.obs;
  var isUserLoading = false.obs;
  var hasMoreNotes = true.obs;
  var hasMoreUser = true.obs;

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    keyword = Get.arguments as String;
    _loadNotes();
    notesScrollController.addListener(() {
      if (notesScrollController.position.pixels ==
          notesScrollController.position.maxScrollExtent) {
        _loadNotes();
      }
    });
    userScrollController.addListener(() {
      if (userScrollController.position.pixels ==
          userScrollController.position.maxScrollExtent) {}
    });
  }

  onTabChange() {
    Get.log('tabIndex: ${tabIndex.value}');
    if (tabIndex.value == 0) {
      if (notesList.isEmpty) {
        _loadNotes();
      }
    } else {
      if (userList.isEmpty) {
        _loadUsers();
      }
    }
  }

  _loadNotes() {
    if (isNotesLoading.value) {
      return;
    }
    if (!hasMoreNotes.value) {
      return;
    }
    isNotesLoading.value = true;
    SearchApi.searchNotes(
            keyword, notesPage, userSize, notesType.value, hotType.value)
        .then((res) {
      if (res.code == StatusCode.getSuccess) {
        notesPage++;
        if (res.data['list'].length < notesSize) {
          hasMoreNotes.value = false;
        }
        notesList.addAll(res.data['list']);
      }
    }).whenComplete(() {
      isNotesLoading.value = false;
    });
  }

  _loadUsers() {
    if (isUserLoading.value) {
      return;
    }
    if (!hasMoreUser.value) {
      return;
    }
    isUserLoading.value = true;
    SearchApi.searchUser(keyword, userPage, userSize).then((res) {
      if (res.code == StatusCode.getSuccess) {
        userPage++;
        Get.log('userList: ${res.data}');
        if (res.data.length < userSize) {
          hasMoreUser.value = false;
        }
        userList.addAll(res.data);
      }
    }).whenComplete(() {
      isUserLoading.value = false;
    });
  }

  void onNotesRefresh() {
    notesPage = 1;
    hasMoreNotes.value = true;
    notesList.clear();
    _loadNotes();
  }

  void onUserRefresh() {
    userPage = 1;
    hasMoreUser.value = true;
    userList.clear();
    _loadUsers();
  }
}
