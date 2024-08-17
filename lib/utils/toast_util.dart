import 'package:flutter/cupertino.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:get/get.dart';

class ToastUtil {
  static void showSimpleToast(String message) {
    showToast(
      message,
      context: Get.context,
      position: const StyledToastPosition(
        align: Alignment.center,
      ),
      animation: StyledToastAnimation.slideFromBottomFade,
      duration: const Duration(milliseconds: 1500),
      animDuration: const Duration(milliseconds: 200),
    );
  }
}
