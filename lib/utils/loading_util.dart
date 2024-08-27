import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:get/get.dart';

class LoadingUtil {
  static void show() {
    // 显示loading，过了5秒没有关闭，就自动关闭
    if (Get.isDialogOpen ?? false) return;
    Get.dialog(
      // 点击背景不关闭
      barrierDismissible: false,
      Center(
        child: LoadingAnimationWidget.fourRotatingDots(
          color: Colors.white,
          size: 100,
        ),
      ),
    );
  }

  static void hide() {
    if (Get.isDialogOpen ?? false) navigator!.pop();
  }
}
