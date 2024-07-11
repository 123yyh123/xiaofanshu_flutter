import 'package:get/get.dart';
import '../controller/login_controller.dart';
import '../controller/home_controller.dart';

class ControllerBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => LoginController());
    Get.lazyPut(() => HomeController());
  }
}
