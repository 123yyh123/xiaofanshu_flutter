import 'package:get/get.dart';

class PublishNotesController extends GetxController {
  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    Map<String, dynamic> args = Get.arguments;
    Get.log(args.toString());
  }
}
