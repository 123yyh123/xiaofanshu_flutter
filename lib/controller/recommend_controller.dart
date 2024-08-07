import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:xiaofanshu_flutter/mapper/recommend_tab_mapper.dart';
import 'package:xiaofanshu_flutter/model/response.dart';
import 'package:xiaofanshu_flutter/static/default_data.dart';

import '../apis/app.dart';
import '../model/recommend_tab.dart';
import '../static/custom_code.dart';
import '../static/custom_string.dart';
import '../utils/snackbar_util.dart';

class RecommendController extends GetxController
    with GetTickerProviderStateMixin {
  var tabBarList = DefaultData.recommendTabList.map((e) => e).toList().obs;
  var tabIndex = 0.obs;
  late TabController tabController;
  var recommendNotesList = [].obs;
  var page = 1.obs;
  var size = 10.obs;
  var isLoadMore = false.obs;
  var isRefresh = false.obs;
  var _lastPressedAt = DateTime.now();
  ScrollController scrollController = ScrollController();

  @override
  void onInit() async {
    super.onInit();
    // 从本地数据库获取tabBarList
    tabController = TabController(length: tabBarList.length, vsync: this);
    List<RecommendTab> recommendTabList = await RecommendTabMapper.queryAll();
    if (recommendTabList.isNotEmpty) {
      tabBarList.value = recommendTabList.map((e) => e).toList();
      tabController.dispose();
      tabController = TabController(length: tabBarList.length, vsync: this);
    } else {
      // 本地数据库为空，请求接口
      HttpResponse response = await NoteApi.getNoteCategory();
      if (response.code == StatusCode.getSuccess) {
        List<Map<String, dynamic>> result = (response.data as List<dynamic>)
            .map((item) => item as Map<String, dynamic>)
            .toList();
        List<RecommendTab> list = [];
        if (result.isEmpty) {
          list = DefaultData.recommendTabList.map((e) => e).toList();
        } else {
          list = result.map((item) {
            RecommendTab recommendTab = RecommendTab(
              id: item['id'],
              name: item['categoryName'],
              sort: item['categorySort'],
            );
            return recommendTab;
          }).toList();
        }
        list.add(RecommendTab(
          id: 1,
          name: '推荐',
          sort: 0,
        ));
        // 升序排序
        list.sort((a, b) => a.sort.compareTo(b.sort));
        tabBarList.value = list;
        tabController.dispose();
        tabController = TabController(length: tabBarList.length, vsync: this);
        await RecommendTabMapper.insertList(list);
      }
    }
    page.value = 1;
    size.value = 10;
    recommendNotesList.value = [];
    getRecommendNotesList();
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
    recommendNotesList.value = [];
    try {
      getRecommendNotesList();
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
      getRecommendNotesList();
    } catch (e) {
      SnackbarUtil.showError(ErrorString.networkError);
    } finally {
      isLoadMore.value = false;
    }
  }

  void getRecommendNotesList() {
    if (tabIndex.value == 0) {
      NoteApi.getRecommendNotesList(page.value, size.value).then((res) {
        if (res.code == StatusCode.getSuccess) {
          recommendNotesList.addAll(res.data['list']);
          page.value++;
        } else {
          SnackbarUtil.showError(res.msg);
        }
      });
    } else {
      var categoryId = tabBarList[tabIndex.value].id;
      NoteApi.getRecommendNotesListByCategory(
              page.value, size.value, categoryId ?? 0)
          .then((res) {
        if (res.code == StatusCode.getSuccess) {
          recommendNotesList.addAll(res.data['list']);
          page.value++;
        } else {
          SnackbarUtil.showError(res.msg);
        }
      });
    }
  }

  void test() {
    NoteApi.getAttentionUserNotes(1, size.value).then((res) {
      if (res.code == StatusCode.getSuccess) {
        recommendNotesList.addAll(res.data['list']);
        page.value++;
      } else {
        SnackbarUtil.showError(res.msg);
      }
    });
  }
}
