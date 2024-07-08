import 'package:get/get.dart';
import 'package:xiaofanshu_flutter/controller/login_controller.dart';

class ControllerBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => LoginController());
  }
}
