import 'package:get/get.dart';
import 'package:xiaofanshu_flutter/controller/attention_controller.dart';
import 'package:xiaofanshu_flutter/controller/recommend_controller.dart';
import '../controller/login_controller.dart';
import '../controller/home_controller.dart';

class ControllerBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => LoginController());
    Get.lazyPut(() => HomeController());
    Get.lazyPut(() => AttentionController());
    Get.lazyPut(() => RecommendController());
  }
}
