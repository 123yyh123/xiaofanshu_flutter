import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:xiaofanshu_flutter/mapper/recently_message_mapper.dart';
import 'package:xiaofanshu_flutter/mapper/system_message_mapper.dart';
import 'package:xiaofanshu_flutter/model/recently_message.dart';

import '../utils/db_util.dart';
import 'home_controller.dart';

class RecentlyMessageController extends GetxController {
  var recentlyMessageList = List<RecentlyMessage>.empty().obs;
  var praiseAndCollectionUnreadNum = 0.obs;
  var attentionUnreadNum = 0.obs;
  var commentUnreadNum = 0.obs;
  static bool isInitialized = false;

  @override
  Future<void> onInit() async {
    // TODO: implement onInit
    super.onInit();
    isInitialized = true;
    await DBManager.instance.createMessageListTable();
    await DBManager.instance.createPraiseAndCollectionTable();
    await DBManager.instance.createSystemMessageTable();
    await DBManager.instance.createAttentionMessageTable();
    List<RecentlyMessage> all = await RecentlyMessageMapper.queryAll();
    recentlyMessageList.assignAll(all);
    updateSystemMessageUnreadNum();
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

  // 更新系统消息未读数量
  Future<void> updateSystemMessageUnreadNum() async {
    List<Map<String, dynamic>> list = await SystemMessageMapper.getAll();
    if (list.isNotEmpty) {
      praiseAndCollectionUnreadNum.value = list[0]['unread_num'];
      attentionUnreadNum.value = list[1]['unread_num'];
      commentUnreadNum.value = list[2]['unread_num'];
    }
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
    // 通知HomeController更新角标
    Get.find<HomeController>().refreshUnReadCount();
  }

  void readRecentlyMessage(int index) {
    RecentlyMessageMapper.updateRead(recentlyMessageList[index].id!);
    recentlyMessageList[index].unreadNum = 0;
    recentlyMessageList.refresh();
    // 通知HomeController更新角标
    Get.find<HomeController>().refreshUnReadCount();
  }

  Future<void> clearPraiseAndCollectionUnreadNum() async {
    await SystemMessageMapper.clearUnreadCount(1);
    praiseAndCollectionUnreadNum.value = 0;
    // 通知HomeController更新角标
    Get.find<HomeController>().refreshUnReadCount();
  }
}
