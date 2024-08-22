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

  static void showNewMessage(
      String avatar, String nickname, String message, String userId) {
    showTopSnackBar(
      Overlay.of(Get.context!),
      _messageWidget(avatar, nickname, message),
      onTap: () {
        Get.log('userId: $userId');
        Get.toNamed('/chat', arguments: userId);
      },
      displayDuration: const Duration(milliseconds: 500),
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

  static Widget _messageWidget(String avatar, String nickname, String message) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundImage: NetworkImage(avatar),
          ),
          const SizedBox(width: 10),
          Expanded(
            flex: 1,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  nickname,
                  maxLines: 1,
                  style: const TextStyle(
                    fontSize: 16,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  message,
                  maxLines: 1,
                  style: const TextStyle(
                    fontSize: 14,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
