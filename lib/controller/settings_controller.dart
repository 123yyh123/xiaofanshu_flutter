import 'package:device_info/device_info.dart';
import 'package:get/get.dart';
import 'package:xiaofanshu_flutter/utils/store_util.dart';

import '../apis/app.dart';
import '../model/user.dart';
import '../static/custom_code.dart';
import '../static/default_data.dart';
import '../utils/snackbar_util.dart';

class SettingsController extends GetxController {
  var userInfo = DefaultData.user.obs;
  var deviceInfomation = ''.obs;
  var androidRelease = ''.obs;

  @override
  void onInit() async {
    super.onInit();
    int userId = Get.arguments as int;
    var response = await UserApi.getUserInfo(userId);
    if (response.code == StatusCode.getSuccess) {
      userInfo.value = User.fromJson(response.data);
    } else {
      SnackbarUtil.showError(response.msg);
    }
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
    deviceInfomation.value = '${androidInfo.brand} ${androidInfo.model}';
    androidRelease.value = 'Android ${androidInfo.version.release}';
  }

  void logout() {
    if (userInfo.value.id == 1) {
      return;
    }
    AuthApi.logout(userInfo.value.id).then((response) async {
      await removeData('token');
      await removeData('userInfo');
      Get.offAllNamed('/login');
    });
  }
}
