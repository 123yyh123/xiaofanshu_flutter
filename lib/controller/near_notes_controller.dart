import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:xiaofanshu_flutter/apis/app.dart';
import 'package:xiaofanshu_flutter/static/custom_code.dart';
import 'package:xiaofanshu_flutter/static/custom_string.dart';
import 'package:xiaofanshu_flutter/utils/comment_util.dart';
import 'package:xiaofanshu_flutter/utils/snackbar_util.dart';

class NearNotesController extends GetxController {
  var nearNotesList = [].obs;
  var page = 1.obs;
  var size = 10.obs;
  var isLoadMore = false.obs;
  var isRefresh = false.obs;
  var isHasMore = true;
  var _lastPressedAt = DateTime.now();
  double latitude = 0.0;
  double longitude = 0.0;
  ScrollController scrollController = ScrollController();

  @override
  Future<void> onInit() async {
    // TODO: implement onInit
    super.onInit();
    page.value = 1;
    size.value = 10;
    nearNotesList.value = [];
    try {
      String location = await getLocation();
      List<String> locations = location.split(',');
      latitude = double.parse(locations[0]);
      longitude = double.parse(locations[1]);
      Get.log('latitude: $latitude, longitude: $longitude');
    } catch (e) {
      SnackbarUtil.showError('定位失败');
    }
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
    if (DateTime.now().difference(_lastPressedAt) <
        const Duration(milliseconds: 500)) {
      // 刷新
      onRefresh();
    } else if (nearNotesList.isEmpty) {
      onRefresh();
    }
    _lastPressedAt = DateTime.now();
  }

  Future<void> onRefresh() async {
    if (isRefresh.value) {
      return;
    }
    isRefresh.value = true;
    page.value = 1;
    size.value = 10;
    isHasMore = true;
    nearNotesList.value = [];
    try {
      String location = await getLocation();
      List<String> locations = location.split(',');
      latitude = double.parse(locations[0]);
      longitude = double.parse(locations[1]);
      Get.log('latitude: $latitude, longitude: $longitude');
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
      getAttentionNotesList();
    } catch (e) {
      SnackbarUtil.showError(ErrorString.networkError);
    } finally {
      isLoadMore.value = false;
    }
  }

  void getAttentionNotesList() {
    if (!isHasMore) {
      return;
    }
    SearchApi.getNotesNearBy(latitude, longitude, page.value, size.value)
        .then((res) {
      if (res.code == StatusCode.getSuccess) {
        if (res.data['list'].length < size.value) {
          isHasMore = false;
        }
        nearNotesList.addAll(res.data['list']);
        page.value++;
      } else {
        SnackbarUtil.showError(res.msg);
      }
    });
  }
}
