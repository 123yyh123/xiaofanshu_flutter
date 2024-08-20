import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:xiaofanshu_flutter/utils/permission_apply.dart';

class HomeController extends GetxController {
  var currentIndex = 0.obs;

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    PermissionApply.requestPermission();
  }

  void changeIndex(int index) {
    currentIndex.value = index;
  }
}
