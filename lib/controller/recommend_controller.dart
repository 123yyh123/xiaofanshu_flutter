import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:xiaofanshu_flutter/mapper/recommend_tab_mapper.dart';
import 'package:xiaofanshu_flutter/model/response.dart';
import 'package:xiaofanshu_flutter/static/default_data.dart';

import '../apis/app.dart';
import '../model/recommend_tab.dart';
import '../static/custom_code.dart';

class RecommendController extends GetxController
    with GetTickerProviderStateMixin {
  var tabBarList = DefaultData.recommendTabList.map((e) => e).toList().obs;
  var tabIndex = 0.obs;
  late TabController tabController;

  @override
  void onInit() async {
    super.onInit();
    // 从本地数据库获取tabBarList
    tabController = TabController(length: tabBarList.length, vsync: this);
    List<RecommendTab> recommendTabList = await RecommendTabMapper.queryAll();
    if (recommendTabList.isNotEmpty) {
      tabBarList.value = recommendTabList.map((e) => e.name).toList();
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
          List<String> tabList = DefaultData.recommendTabList;
          for (var i = 0; i < tabList.length; i++) {
            RecommendTab recommendTab = RecommendTab(
              name: tabList[i],
              sort: i + 1,
            );
            list.add(recommendTab);
          }
        } else {
          list = result.map((item) {
            RecommendTab recommendTab = RecommendTab(
              name: item['categoryName'],
              sort: item['categorySort'],
            );
            return recommendTab;
          }).toList();
        }
        tabBarList.value = list.map((e) => e.name).toList();
        tabController.dispose();
        tabController = TabController(length: tabBarList.length, vsync: this);
        int l = await RecommendTabMapper.insertList(list);
      }
    }
  }
}
