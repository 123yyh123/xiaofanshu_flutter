import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:xiaofanshu_flutter/mapper/recommend_tab_mapper.dart';
import 'package:xiaofanshu_flutter/model/response.dart';
import 'package:xiaofanshu_flutter/static/default_data.dart';

import '../apis/app.dart';
import '../model/recommend_tab.dart';
import '../static/custom_code.dart';

class RecommendController extends GetxController {
  var tabBarList = [].obs;
  var tabIndex = 0.obs;

  @override
  void onInit() {
    super.onInit();
    // 从本地数据库获取tabBarList
    RecommendTabMapper.queryAll().then((value) {
      if (value.isNotEmpty) {
        tabBarList.value = value.map((e) => e.name).toList();
      } else {
        // 本地数据库为空，请求接口
        NoteApi.getNoteCategory().then((HttpResponse response) {
          if (response.code == StatusCode.getSuccess) {
            List<Map<String, dynamic>> result = response.data;
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
            RecommendTabMapper.insertList(list);
          }
        });
      }
    });
  }
}
