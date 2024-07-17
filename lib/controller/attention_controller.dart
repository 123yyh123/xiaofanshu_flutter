import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:xiaofanshu_flutter/apis/app.dart';
import 'package:xiaofanshu_flutter/static/custom_code.dart';
import 'package:xiaofanshu_flutter/static/custom_string.dart';
import 'package:xiaofanshu_flutter/utils/snackbar_util.dart';

class AttentionController extends GetxController {
  var attentionNotesList = [].obs;
  var page = 1.obs;
  var size = 10.obs;
  var isLoadMore = false.obs;
  var isRefresh = false.obs;
  var _lastPressedAt = DateTime.now();
  ScrollController scrollController = ScrollController();

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    page.value = 1;
    size.value = 10;
    attentionNotesList.value = [];
    getAttentionNotesList();
    // 监听滚动事件
    scrollController.addListener(() {
      if (scrollController.position.pixels ==
          scrollController.position.maxScrollExtent) {
        onLoading();
      }
    });
  }

  // 处理点击事件
  void onTap() {
    // 判断是否为双击
    if (DateTime.now().difference(_lastPressedAt) < const Duration(milliseconds: 500)) {
      // 刷新
      onRefresh();
    }
    _lastPressedAt = DateTime.now();
  }

  void onRefresh() {
    if (isRefresh.value) {
      return;
    }
    isRefresh.value = true;
    page.value = 1;
    size.value = 10;
    attentionNotesList.value = [];
    try {
      getAttentionNotesList();
    } catch (e) {
      SnackbarUtil.showError(ErrorString.networkError);
    } finally {
      isRefresh.value = false;
    }
  }

  void onLoading() {
    if (isLoadMore.value) {
      return;
    }
    isLoadMore.value = true;
    try {
      test();
    } catch (e) {
      SnackbarUtil.showError(ErrorString.networkError);
    } finally {
      isLoadMore.value = false;
    }
  }

  void getAttentionNotesList() {
    NoteApi.getAttentionUserNotes(page.value, size.value).then((res) {
      if (res.code == StatusCode.getSuccess) {
        attentionNotesList.addAll(res.data['list']);
        page.value++;
      } else {
        SnackbarUtil.showError(res.msg);
      }
    });
  }

  void test() {
    NoteApi.getAttentionUserNotes(1, size.value).then((res) {
      if (res.code == StatusCode.getSuccess) {
        attentionNotesList.addAll(res.data['list']);
        page.value++;
      } else {
        SnackbarUtil.showError(res.msg);
      }
    });
  }

}
