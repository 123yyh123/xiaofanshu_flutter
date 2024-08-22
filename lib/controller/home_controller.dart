import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:xiaofanshu_flutter/controller/websocket_controller.dart';
import 'package:xiaofanshu_flutter/utils/permission_apply.dart';

import '../static/default_data.dart';
import '../utils/db_util.dart';
import '../utils/store_util.dart';

class HomeController extends GetxController {
  var currentIndex = 0.obs;

  @override
  Future<void> onInit() async {
    // TODO: implement onInit
    super.onInit();
    PermissionApply.requestPermission();
    if (!Get.isPrepared()) {
      Get.put(WebsocketController(), permanent: true);
    }
    await DBManager.instance.createMessageListTable();
  }

  void changeIndex(int index) {
    currentIndex.value = index;
  }
}
