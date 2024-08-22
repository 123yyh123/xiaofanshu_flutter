import 'package:get/get.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:xiaofanshu_flutter/utils/websocket_manager.dart';

class WebsocketController extends GetxController {
  late WebSocketManager webSocketManager;

  @override
  Future<void> onInit() async {
    // TODO: implement onInit
    super.onInit();
    // 初始化websocket
    webSocketManager = WebSocketManager();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    webSocketManager.disconnect();
    super.dispose();
  }

  @override
  void onClose() {
    // TODO: implement onClose
    webSocketManager.disconnect();
    super.onClose();
  }
}
