import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:xiaofanshu_flutter/components/timer_count.dart';
import 'package:xiaofanshu_flutter/config/custom_icon.dart';
import 'package:xiaofanshu_flutter/controller/login_controller.dart';
import 'package:xiaofanshu_flutter/utils/Adapt.dart';
import 'package:xiaofanshu_flutter/utils/snackbar_util.dart';
import '../../static/custom_color.dart';
import '../../utils/request.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  LoginController loginController = Get.find();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              '帮助',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
              textAlign: TextAlign.end,
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          children: [
            const Text('手机号登录', style: TextStyle(fontSize: 25)).marginOnly(
              bottom: Adapt.setRpx(20),
            ),
            const Text(
              '未注册的手机号验证后自动创建小番薯账号',
              style: TextStyle(
                color: Color(0xff999999),
                fontSize: 12,
              ),
            ),
            Padding(
              padding: EdgeInsets.only(
                  left: Adapt.setRpx(100),
                  right: Adapt.setRpx(100),
                  top: Adapt.setRpx(40)),
              child: Column(
                children: [
                  Obx(() => TextField(
                        controller: loginController.phoneController,
                        decoration: InputDecoration(
                          hintText: '请输入手机号',
                          hintStyle: const TextStyle(
                            color: Color(0xffCDCDCD),
                            fontSize: 18,
                          ),
                          enabledBorder: const UnderlineInputBorder(
                              borderSide: BorderSide(color: Color(0xffEDEDED))),
                          focusedBorder: const UnderlineInputBorder(
                              borderSide: BorderSide(color: Color(0xffEDEDED))),
                          suffixIcon: loginController.phone.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: () {
                                    loginController.phoneController.clear();
                                  },
                                )
                              : null,
                        ),
                        style: const TextStyle(
                            fontSize: 20, color: Color(0xff333333)),
                        cursorColor: CustomColor.primaryColor,
                        keyboardType: TextInputType.phone,
                        inputFormatters: [
                          // 手机号校验，只允许输入数字
                          FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                        ],
                      )),
                  Obx(() => loginController.loginType.value == 'code'
                      ? TextField(
                          controller: loginController.codeController,
                          keyboardType: TextInputType.phone,
                          decoration: InputDecoration(
                            hintText: '请输入验证码',
                            hintStyle: const TextStyle(
                              color: Color(0xffCDCDCD),
                              fontSize: 18,
                            ),
                            labelStyle: const TextStyle(
                              color: Color(0xffCDCDCD),
                              fontSize: 20,
                            ),
                            enabledBorder: const UnderlineInputBorder(
                                borderSide:
                                    BorderSide(color: Color(0xffEDEDED))),
                            focusedBorder: const UnderlineInputBorder(
                                borderSide:
                                    BorderSide(color: Color(0xffEDEDED))),
                            suffixIcon: SendSmsBtn(
                              onTap: () async {
                                return true;
                              },
                            ),
                          ),
                          style: const TextStyle(
                            fontSize: 20,
                            color: Color(0xff333333),
                          ),
                          cursorColor: CustomColor.primaryColor,
                        )
                      : TextField(
                          controller: loginController.passwordController,
                          keyboardType: TextInputType.visiblePassword,
                          obscureText: !loginController.passwordVisible.value,
                          decoration: InputDecoration(
                            hintText: '请输入密码',
                            hintStyle: const TextStyle(
                              color: Color(0xffCDCDCD),
                              fontSize: 18,
                            ),
                            labelStyle: const TextStyle(
                              color: Color(0xffCDCDCD),
                              fontSize: 20,
                            ),
                            enabledBorder: const UnderlineInputBorder(
                                borderSide:
                                    BorderSide(color: Color(0xffEDEDED))),
                            focusedBorder: const UnderlineInputBorder(
                                borderSide:
                                    BorderSide(color: Color(0xffEDEDED))),
                            suffixIcon: IconButton(
                              onPressed: () {
                                loginController.passwordVisible.value =
                                    !loginController.passwordVisible.value;
                              },
                              icon: loginController.passwordVisible.value
                                  ? const Icon(Icons.visibility)
                                  : const Icon(Icons.visibility_off),
                            ),
                          ),
                          style: const TextStyle(
                            fontSize: 20,
                            color: Color(0xff333333),
                          ),
                          cursorColor: CustomColor.primaryColor,
                        )),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Obx(
                        () => TextButton(
                          style: ButtonStyle(
                            overlayColor: WidgetStateProperty.all(
                              Colors.transparent,
                            ),
                          ),
                          onPressed: () {
                            loginController.changeLoginType();
                          },
                          child: Text(
                            loginController.loginType.value == 'code'
                                ? '密码登录'
                                : '验证码登录',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xff052583),
                            ),
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () {},
                        style: ButtonStyle(
                          overlayColor: WidgetStateProperty.all(
                            Colors.transparent,
                          ),
                        ),
                        child: const Text(
                          '手机号无法使用',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xff052583),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Obx(
                    () => TextButton(
                      onPressed: () {
                        loginController.isAllowLogin.value
                            ? loginController.login()
                            : SnackbarUtil.show(
                                loginController.loginType.value == 'code'
                                    ? '请填写手机号和验证码'
                                    : '请填写手机号和密码',
                                SnackbarUtil.info);
                      },
                      style: ButtonStyle(
                        backgroundColor: WidgetStateProperty.all(
                          loginController.isAllowLogin.value
                              ? CustomColor.primaryColor
                              : const Color(0xffF5F5F5),
                        ),
                        fixedSize: WidgetStateProperty.all(
                          Size(Adapt.setRpx(700), Adapt.setRpx(100)),
                        ),
                      ),
                      child: const Text('登录',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: Icon(
                          CustomIcon.weixin,
                          size: Adapt.setRpx(100),
                          color: const Color(0xff28DC70),
                        ),
                        onPressed: () {},
                      ),
                      Icon(
                        CustomIcon.qq,
                        size: Adapt.setRpx(100),
                        color: const Color(0xff08A9F7),
                      ),
                      Icon(
                        CustomIcon.weibo,
                        size: Adapt.setRpx(100),
                        color: CustomColor.primaryColor,
                      ),
                    ],
                  ).marginOnly(top: 60),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
