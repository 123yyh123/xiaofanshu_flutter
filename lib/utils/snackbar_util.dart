import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

class SnackbarUtil {
  static const String error = 'error';
  static const String success = 'success';
  static const String info = 'info';
  static AnimationController? localAnimationController;

  static void show(String message, String type) {
    showTopSnackBar(
      Overlay.of(Get.context!),
      displayDuration: const Duration(milliseconds: 500),
      type == error
          ? CustomSnackBar.error(
              message: message,
            )
          : type == success
              ? CustomSnackBar.success(
                  message: message,
                )
              : CustomSnackBar.info(
                  message: message,
                ),
      onAnimationControllerInit: (controller) =>
          localAnimationController = controller,
    );
  }

  static void showInfo(String message) {
    show(message, info);
  }

  static void showError(String message) {
    show(message, error);
  }

  static void showSuccess(String message) {
    show(message, success);
  }

  static void hide() {
    localAnimationController?.reverse();
  }
}
