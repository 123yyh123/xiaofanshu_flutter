import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:xiaofanshu_flutter/apis/app.dart';
import 'package:xiaofanshu_flutter/model/response.dart';
import 'package:xiaofanshu_flutter/static/custom_code.dart';

import '../model/user.dart';
import '../static/default_data.dart';
import '../utils/store_util.dart';

class AttentionFansController extends GetxController {
  late TabController tabController;
  var userInfo = DefaultData.user.obs;
  var attentionList = [].obs;
  var fansList = [].obs;
  var attentionPage = 1.obs;
  var fansPage = 1.obs;
  var attentionSize = 10.obs;
  var fansSize = 10.obs;
  var attentionTotal = 0.obs;
  var fansTotal = 0.obs;
  var isLoading = false.obs;
  var hasMoreAttention = true.obs;
  var hasMoreFans = true.obs;
  ScrollController attentionScrollController = ScrollController();
  ScrollController fansScrollController = ScrollController();

  @override
  Future<void> onInit() async {
    // TODO: implement onInit
    super.onInit();
    userInfo.value = User.fromJson(
        jsonDecode(await readData('userInfo') ?? jsonEncode(DefaultData.user)));
    attentionTotal.value = userInfo.value.attentionNum;
    fansTotal.value = userInfo.value.fansNum;
    await loadAttentionList();
    await loadFansList();
    attentionScrollController.addListener(() {
      if (attentionScrollController.position.pixels ==
          attentionScrollController.position.maxScrollExtent) {
        loadAttentionList();
      }
    });
    fansScrollController.addListener(() {
      if (fansScrollController.position.pixels ==
          fansScrollController.position.maxScrollExtent) {
        loadFansList();
      }
    });
  }

  loadAttentionList() async {
    if (isLoading.value || !hasMoreAttention.value) {
      return;
    }
    isLoading.value = true;
    HttpResponse response = await UserApi.getAttentionList(
      userInfo.value.id,
      attentionPage.value,
      attentionSize.value,
    );
    if (response.code == StatusCode.getSuccess) {
      attentionList.addAll(response.data);
      if (attentionList.length < attentionSize.value) {
        hasMoreAttention.value = false;
      }
      attentionPage.value++;
    }
    isLoading.value = false;
  }

  loadFansList() async {
    if (isLoading.value || !hasMoreFans.value) {
      return;
    }
    isLoading.value = true;
    HttpResponse response = await UserApi.getFansList(
      userInfo.value.id,
      fansPage.value,
      fansSize.value,
    );
    if (response.code == StatusCode.getSuccess) {
      fansList.addAll(response.data);
      if (fansList.length < fansSize.value) {
        hasMoreFans.value = false;
      }
      fansPage.value++;
    }
    isLoading.value = false;
  }
}
