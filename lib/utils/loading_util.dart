import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:get/get.dart';

class LoadingUtil {
  // EasyLoading easyLoading = EasyLoading.instance
  //   ..displayDuration = const Duration(milliseconds: 2000)
  //   ..indicatorType = EasyLoadingIndicatorType.fadingCircle
  //   ..loadingStyle = EasyLoadingStyle.custom
  //   ..indicatorSize = 45.0
  //   ..radius = 10.0
  //   ..progressColor = Colors.blue
  //   ..backgroundColor = Colors.white
  //   ..indicatorColor = Colors.blue
  //   ..textColor = Colors.blue
  //   ..maskColor = Colors.blue.withOpacity(0.5)
  //   ..userInteractions = false
  //   ..dismissOnTap = false;

  // static void show() {
  //   EasyLoading.show();
  // }
  //
  // static void hide() {
  //   EasyLoading.dismiss();
  // }

  static void show() {
    // 显示loading，过了5秒没有关闭，就自动关闭
    Get.dialog(
      // 点击背景不关闭
      barrierDismissible: false,
      Center(
        child: LoadingAnimationWidget.halfTriangleDot(
          color: Colors.blue,
          size: 100,
        ),
      ),
    );
  }

  static void hide() {
    if (Get.isDialogOpen ?? false) navigator!.pop();
  }
}
