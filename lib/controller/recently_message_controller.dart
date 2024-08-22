import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:xiaofanshu_flutter/mapper/recently_message_mapper.dart';
import 'package:xiaofanshu_flutter/model/recently_message.dart';

import '../utils/db_util.dart';

class RecentlyMessageController extends GetxController {
  var recentlyMessageList = List<RecentlyMessage>.empty().obs;
  static bool isInitialized = false;

  @override
  Future<void> onInit() async {
    // TODO: implement onInit
    super.onInit();
    isInitialized = true;
    await DBManager.instance.createMessageListTable();
    List<RecentlyMessage> all = await RecentlyMessageMapper.queryAll();
    recentlyMessageList.assignAll(all);
  }

  void updateRecentlyMessageList() {
    RecentlyMessageMapper.queryAll().then((value) {
      Get.log('更新最近消息列表');
      Get.log('最近消息列表数量：${value.length}');
      for (var element in value) {
        Get.log('最近消息列表：${element.toJson()}');
      }
      recentlyMessageList.assignAll(value);
    });
  }

  @override
  void onClose() {
    // TODO: implement onClose
    super.onClose();
    isInitialized = false;
  }

  void removeRecentlyMessage(int index) {
    RecentlyMessageMapper.delete(recentlyMessageList[index].id!);
    recentlyMessageList.removeAt(index);
  }

  void readRecentlyMessage(int index) {
    RecentlyMessageMapper.updateRead(recentlyMessageList[index].id!);
    recentlyMessageList[index].unreadNum = 0;
    recentlyMessageList.refresh();
  }
}
