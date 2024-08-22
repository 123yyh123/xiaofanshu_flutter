import 'package:get/get.dart';
import 'package:xiaofanshu_flutter/controller/attention_controller.dart';
import 'package:xiaofanshu_flutter/controller/attention_fans_controller.dart';
import 'package:xiaofanshu_flutter/controller/location_controller.dart';
import 'package:xiaofanshu_flutter/controller/mine_controller.dart';
import 'package:xiaofanshu_flutter/controller/note_details_image_controller.dart';
import 'package:xiaofanshu_flutter/controller/note_details_video_controller.dart';
import 'package:xiaofanshu_flutter/controller/publish_notes_controller.dart';
import 'package:xiaofanshu_flutter/controller/recently_message_controller.dart';
import 'package:xiaofanshu_flutter/controller/recommend_controller.dart';
import '../controller/chat_controller.dart';
import '../controller/login_controller.dart';
import '../controller/home_controller.dart';
import '../controller/other_mine_controller.dart';

class ControllerBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => LoginController());
    Get.lazyPut(() => HomeController());
    Get.lazyPut(() => AttentionController());
    Get.lazyPut(() => RecommendController());
    Get.lazyPut(() => MineController());
    Get.lazyPut(() => NoteDetailsImageController());
    Get.lazyPut(() => NoteDetailsVideoController());
    Get.lazyPut(() => PublishNotesController());
    Get.lazyPut(() => LocationController());
    Get.lazyPut(() => AttentionFansController());
    Get.lazyPut(() => OtherMineController());
    Get.lazyPut(() => ChatController());
    Get.lazyPut(() => RecentlyMessageController());
  }
}
