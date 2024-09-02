import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:xiaofanshu_flutter/controller/websocket_controller.dart';
import 'package:xiaofanshu_flutter/mapper/recently_message_mapper.dart';
import 'package:xiaofanshu_flutter/mapper/system_message_mapper.dart';
import 'package:xiaofanshu_flutter/utils/permission_apply.dart';
import '../utils/db_util.dart';

class HomeController extends GetxController {
  var currentIndex = 0.obs;
  var unReadCount = 0.obs;

  @override
  Future<void> onInit() async {
    // TODO: implement onInit
    super.onInit();
    PermissionApply.requestPermission();
    await DBManager.instance.createMessageListTable();
    await refreshUnReadCount();
  }

  void changeIndex(int index) {
    currentIndex.value = index;
  }

  Future<void> refreshUnReadCount() async {
    // TODO 暂时只计算未读消息总数
    var messageCount = await RecentlyMessageMapper.countUnRead();
    var systemMessageCount = await SystemMessageMapper.getUnreadCount();
    unReadCount.value = messageCount + systemMessageCount;
  }
}
