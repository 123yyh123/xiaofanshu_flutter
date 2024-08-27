import 'package:get/get.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:tencent_calls_uikit/tencent_calls_uikit.dart';
import 'package:xiaofanshu_flutter/utils/websocket_manager.dart';

class WebsocketController extends GetxController {
  late WebSocketManager webSocketManager;

  @override
  Future<void> onInit() async {
    // TODO: implement onInit
    super.onInit();
    // 初始化websocket
    webSocketManager = WebSocketManager();
    TUICallEngine.instance.addObserver(TUICallObserver(
        onError: (int code, String message) {
          Get.log('错误码：$code, 错误信息：$message');
        },
        onCallReceived: (String callerId, List<String> calleeIdList,
            String groupId, TUICallMediaType callMediaType, String? userData) {
          Get.log('onCallReceived');
        },
        onCallCancelled: (String callerId) {},
        onCallBegin: (TUIRoomId roomId, TUICallMediaType callMediaType,
            TUICallRole callRole) {},
        onCallEnd: (TUIRoomId roomId, TUICallMediaType callMediaType,
            TUICallRole callRole, double totalTime) {},
        onCallMediaTypeChanged: (TUICallMediaType oldCallMediaType,
            TUICallMediaType newCallMediaType) {},
        onUserReject: (String userId) {},
        onUserNoResponse: (String userId) {},
        onUserLineBusy: (String onUserLineBusy) {},
        onUserJoin: (String userId) {},
        onUserLeave: (String userId) {},
        onUserVideoAvailable: (String userId, bool isVideoAvailable) {},
        onUserAudioAvailable: (String userId, bool isAudioAvailable) {},
        onUserNetworkQualityChanged:
            (List<TUINetworkQualityInfo> networkQualityList) {},
        onUserVoiceVolumeChanged: (Map<String, int> volumeMap) {},
        onKickedOffline: () {},
        onUserSigExpired: () {
          webSocketManager.loginTrtc();
        }));
  }

  void disconnect() {
    webSocketManager.disconnect();
  }

  void connect() {
    webSocketManager.disconnect();
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
