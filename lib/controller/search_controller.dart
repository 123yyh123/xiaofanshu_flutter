import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:xiaofanshu_flutter/controller/search_result_controller.dart';
import 'package:xiaofanshu_flutter/mapper/search_history_mapper.dart';

import '../utils/db_util.dart';

class SearchController extends GetxController {
  var searchHistoryList = List<String>.empty().obs;
  var searchTextFieldController = TextEditingController();
  var keyword = ''.obs;
  var isShowClearButton = false.obs;

  @override
  void onInit() async {
    super.onInit();
    await DBManager.instance.createSearchHistoryTable();
    await _loadSearchHistory();
    searchTextFieldController.addListener(() {
      keyword.value = searchTextFieldController.text;
    });
  }

  Future<void> _loadSearchHistory() async {
    List<String> list = await SearchHistoryMapper.queryAll();
    searchHistoryList.assignAll(list);
  }

  void addSearchHistory(String keyword) async {
    await SearchHistoryMapper.updateIfExist(keyword);
    await _loadSearchHistory();
  }

  void clearSearchHistory() async {
    await SearchHistoryMapper.deleteAll();
    await _loadSearchHistory();
  }

  void deleteSearchHistory(String keyword) async {
    await SearchHistoryMapper.delete(keyword);
    await _loadSearchHistory();
  }

  void search() {
    if (keyword.value.isNotEmpty) {
      Get.log('搜索关键词：${keyword.value}');
      addSearchHistory(keyword.value);
      var routeName = Get.previousRoute;
      if (routeName == '/search/result') {
        // 从搜索结果页返回搜索页
        int count = 1;
        Get.offNamedUntil('/search/result', (route) {
          if (count < 3) {
            count++;
            return false;
          } else {
            return true;
          }
        }, arguments: keyword.value);
      }
      Get.toNamed('/search/result', arguments: keyword.value);
    }
  }
}
