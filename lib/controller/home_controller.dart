import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomeController extends GetxController {
  var currentIndex = 4.obs;

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
  }

  void changeIndex(int index) {
    currentIndex.value = index;
  }
}
