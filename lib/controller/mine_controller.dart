import 'dart:convert';

import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:xiaofanshu_flutter/apis/app.dart';
import 'package:xiaofanshu_flutter/model/response.dart';
import 'package:xiaofanshu_flutter/model/user.dart';
import 'package:xiaofanshu_flutter/static/custom_code.dart';
import 'package:xiaofanshu_flutter/static/default_data.dart';
import 'package:xiaofanshu_flutter/utils/store_util.dart';

class MineController extends GetxController {
  var userInfo = DefaultData.user.obs;
  final ScrollController scrollController = ScrollController();
  var appBarOpacity = 0.0.obs;
  var tabs = ["笔记", "收藏", "赞过"];
  // 0: 公开 1: 私密 3: 草稿
  var notesPublishType = 0.obs;

  @override
  void onInit() async {
    // TODO: implement onInit
    super.onInit();
    int userId = int.parse(jsonDecode(
            await readData('userInfo') ?? jsonEncode(DefaultData.user))['id']
        .toString());
    Get.log('userId: $userId');
    if (userId == 1) {
      userInfo.value = DefaultData.user;
    } else {
      HttpResponse httpResponse = await UserApi.getUserInfo(userId);
      if (httpResponse.code == StatusCode.getSuccess) {
        userInfo.value = User.fromJson(httpResponse.data);
        // 保存最新的用户信息
        await saveData('userInfo', jsonEncode(userInfo.value));
      } else {
        userInfo.value = DefaultData.user;
      }
    }
    userInfo.refresh();
  }

  Future<void> onRefresh() async {
    HttpResponse httpResponse = await UserApi.getUserInfo(userInfo.value.id);
    if (httpResponse.code == StatusCode.getSuccess) {
      userInfo.value = User.fromJson(httpResponse.data);
      // 保存最新的用户信息
      await saveData('userInfo', jsonEncode(userInfo.value));
    }
    userInfo.refresh();
  }
}
