import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:xiaofanshu_flutter/apis/app.dart';
import 'package:xiaofanshu_flutter/controller/websocket_controller.dart';
import 'package:xiaofanshu_flutter/model/response.dart';
import 'package:xiaofanshu_flutter/pages/home/home.dart';
import 'package:xiaofanshu_flutter/static/custom_code.dart';
import 'package:xiaofanshu_flutter/static/custom_string.dart';
import 'package:xiaofanshu_flutter/utils/db_util.dart';
import 'package:xiaofanshu_flutter/utils/parameter_verification.dart';
import 'package:xiaofanshu_flutter/utils/snackbar_util.dart';
import 'package:xiaofanshu_flutter/utils/store_util.dart';

import '../bindings/controller_binding.dart';
import '../model/user.dart';

class LoginController extends GetxController {
  var phoneController = TextEditingController();
  var codeController = TextEditingController();
  var passwordController = TextEditingController();

  var phone = ''.obs;
  var code = ''.obs;
  var password = ''.obs;
  var passwordVisible = false.obs;

  var isAllowLogin = false.obs;
  var loginType = 'code'.obs;

  @override
  void onInit() {
    super.onInit();
    phoneController.addListener(() {
      phone.value = phoneController.text;
      if (phone.value.isNotEmpty &&
          ((loginType.value == 'code' && code.value.isNotEmpty) ||
              (loginType.value == 'password' && password.value.isNotEmpty))) {
        isAllowLogin.value = true;
      } else {
        isAllowLogin.value = false;
      }
    });
    codeController.addListener(() {
      code.value = codeController.text;
      if (phone.value.isNotEmpty &&
          ((loginType.value == 'code' && code.value.isNotEmpty) ||
              (loginType.value == 'password' && password.value.isNotEmpty))) {
        isAllowLogin.value = true;
      } else {
        isAllowLogin.value = false;
      }
    });
    passwordController.addListener(() {
      password.value = passwordController.text;
      if (phone.value.isNotEmpty &&
          ((loginType.value == 'code' && code.value.isNotEmpty) ||
              (loginType.value == 'password' && password.value.isNotEmpty))) {
        isAllowLogin.value = true;
      } else {
        isAllowLogin.value = false;
      }
    });
  }

  void changeLoginType() {
    loginType.value == 'code'
        ? codeController.clear()
        : passwordController.clear();
    loginType.value = loginType.value == 'code' ? 'password' : 'code';
  }

  Future<void> login() async {
    // 校验值
    if (phone.value.isEmpty) {
      SnackbarUtil.show(LoginErrorString.phoneEmpty, SnackbarUtil.error);
      return;
    }
    if (!ParameterVerification.isPhoneNumber(phone.value)) {
      SnackbarUtil.show(LoginErrorString.phoneError, SnackbarUtil.error);
      return;
    }
    if (loginType.value == 'code' && code.value.isEmpty) {
      SnackbarUtil.show(LoginErrorString.codeEmpty, SnackbarUtil.error);
      return;
    }
    if (loginType.value == 'password' && password.value.isEmpty) {
      SnackbarUtil.show(LoginErrorString.passwordEmpty, SnackbarUtil.error);
      return;
    }
    // 请求登录接口
    HttpResponse response = HttpResponse.defaultResponse();
    switch (loginType.value) {
      case 'code':
        response = await AuthApi.loginByCode(phone.value, code.value);
        break;
      case 'password':
        response = await AuthApi.loginByPassword(phone.value, password.value);
        break;
    }
    if (response.code == StatusCode.postSuccess) {
      // 登录成功
      SnackbarUtil.show(LoginString.loginSuccess, SnackbarUtil.success);
      if (response.data['token'] != null) {
        // 保存token
        await saveData('token', response.data['token']);
        await saveData('userInfo', jsonEncode(response.data));
        DBManager.dispose();
        // 初始化websocket
        Get.find<WebsocketController>().connect();
        Get.log('userInfo: ${jsonEncode(response.data)}');
      } else {
        SnackbarUtil.showError(ErrorString.unknownError);
      }
      // 跳转到首页
      Get.off(const HomePage(), binding: ControllerBinding());
    } else {
      // 登录失败
      SnackbarUtil.show(response.msg, SnackbarUtil.error);
    }
  }
}
