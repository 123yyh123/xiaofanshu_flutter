import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:xiaofanshu_flutter/config/custom_icon.dart';
import 'package:xiaofanshu_flutter/controller/settings_controller.dart';
import 'package:xiaofanshu_flutter/static/custom_color.dart';
import 'package:xiaofanshu_flutter/utils/snackbar_util.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  SettingsController settingsController = Get.find();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: GestureDetector(
          onTap: () {
            Get.back();
          },
          child: const Icon(
            Icons.arrow_back_ios,
            color: Colors.black,
            size: 25,
          ).marginOnly(left: 10),
        ),
        leadingWidth: 28,
        title: const Text('账号与安全',
            style: TextStyle(color: Colors.black, fontSize: 16)),
        centerTitle: true,
      ),
      body: Obx(
        () => Column(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(
                  Radius.circular(20),
                ),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Row(
                        children: [
                          Icon(
                            Icons.phone_iphone_rounded,
                            color: Color(0xffafafb0),
                            size: 25,
                          ),
                          SizedBox(width: 10),
                          Text(
                            '手机号',
                            style: TextStyle(color: Colors.black, fontSize: 16),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Text(
                            '+86 ${settingsController.userInfo.value.phoneNumber.substring(0, 3)}****${settingsController.userInfo.value.phoneNumber.substring(7, 11)}',
                            style: const TextStyle(
                                color: Color(0xff2b2b2b), fontSize: 16),
                          ),
                          const SizedBox(width: 10),
                          const Icon(
                            Icons.arrow_forward_ios,
                            color: Color(0xffafafb0),
                            size: 20,
                          ),
                        ],
                      ),
                    ],
                  ).paddingAll(10),
                  const Divider(
                    height: 1,
                    color: Color(0xffe5e5e5),
                  ),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.lock_outline_rounded,
                            color: Color(0xffafafb0),
                            size: 25,
                          ),
                          SizedBox(width: 10),
                          Text(
                            '修改密码',
                            style: TextStyle(color: Colors.black, fontSize: 16),
                          ),
                        ],
                      ),
                      Icon(
                        Icons.arrow_forward_ios,
                        color: Color(0xffafafb0),
                        size: 20,
                      ),
                    ],
                  ).paddingAll(10),
                ],
              ),
            ).paddingAll(20),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(
                  Radius.circular(20),
                ),
              ),
              child: Column(
                children: [
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      SnackbarUtil.showInfo('暂未开放');
                    },
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              CustomIcon.weixin,
                              color: Color(0xffafafb0),
                              size: 25,
                            ),
                            SizedBox(width: 10),
                            Text(
                              '微信账号',
                              style:
                                  TextStyle(color: Colors.black, fontSize: 16),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Text(
                              '未绑定',
                              style: TextStyle(
                                  color: Color(0xff2b2b2b), fontSize: 16),
                            ),
                            SizedBox(width: 10),
                            Icon(
                              Icons.arrow_forward_ios,
                              color: Color(0xffafafb0),
                              size: 20,
                            ),
                          ],
                        ),
                      ],
                    ).paddingAll(10),
                  ),
                  const Divider(
                    height: 1,
                    color: Color(0xffe5e5e5),
                  ),
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      SnackbarUtil.showInfo('暂未开放');
                    },
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              CustomIcon.qq,
                              color: Color(0xffafafb0),
                              size: 25,
                            ),
                            SizedBox(width: 10),
                            Text(
                              'QQ账号',
                              style:
                                  TextStyle(color: Colors.black, fontSize: 16),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Text(
                              '未绑定',
                              style: TextStyle(
                                  color: Color(0xff2b2b2b), fontSize: 16),
                            ),
                            SizedBox(width: 10),
                            Icon(
                              Icons.arrow_forward_ios,
                              color: Color(0xffafafb0),
                              size: 20,
                            ),
                          ],
                        ),
                      ],
                    ).paddingAll(10),
                  ),
                  const Divider(
                    height: 1,
                    color: Color(0xffe5e5e5),
                  ),
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      SnackbarUtil.showInfo('暂未开放');
                    },
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              CustomIcon.weibo,
                              color: Color(0xffafafb0),
                              size: 25,
                            ),
                            SizedBox(width: 10),
                            Text(
                              '微博账号',
                              style:
                                  TextStyle(color: Colors.black, fontSize: 16),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Text(
                              '未绑定',
                              style: TextStyle(
                                  color: Color(0xff2b2b2b), fontSize: 16),
                            ),
                            SizedBox(width: 10),
                            Icon(
                              Icons.arrow_forward_ios,
                              color: Color(0xffafafb0),
                              size: 20,
                            ),
                          ],
                        ),
                      ],
                    ).paddingAll(10),
                  ),
                ],
              ),
            ).paddingOnly(left: 20, right: 20, bottom: 20),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(
                  Radius.circular(20),
                ),
              ),
              child: Column(
                children: [
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      Get.defaultDialog(
                        backgroundColor: Colors.white,
                        title: '设备信息',
                        titleStyle: const TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                        ),
                        content: Column(
                          children: [
                            Text(
                              '设备名称：${settingsController.deviceInfomation.value}',
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              '系统版本：${settingsController.androidRelease.value}',
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Text(
                              '登录设备信息',
                              style:
                                  TextStyle(color: Colors.black, fontSize: 16),
                            ),
                          ],
                        ),
                        Icon(
                          Icons.arrow_forward_ios,
                          color: Color(0xffafafb0),
                          size: 20,
                        ),
                      ],
                    ).paddingAll(10),
                  ),
                ],
              ),
            ).paddingOnly(left: 20, right: 20, bottom: 20),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(
                  Radius.circular(20),
                ),
              ),
              child: Center(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    showCupertinoDialog(
                      context: context,
                      builder: (context) {
                        return CupertinoAlertDialog(
                          title: const Text('退出登录'),
                          content: const Text('确定要退出登录吗？'),
                          actions: [
                            CupertinoDialogAction(
                              child: const Text(
                                '取消',
                                style: TextStyle(
                                    color: CustomColor.primaryColor,
                                    fontSize: 16),
                              ),
                              onPressed: () {
                                Get.back();
                              },
                            ),
                            CupertinoDialogAction(
                              child: const Text(
                                '确定',
                                style: TextStyle(
                                    color: CustomColor.primaryColor,
                                    fontSize: 16),
                              ),
                              onPressed: () {
                                Get.back();
                                settingsController.logout();
                              },
                            ),
                          ],
                        );
                      },
                    );
                  },
                  child: const Text(
                    '退出登录',
                    style: TextStyle(
                        color: CustomColor.primaryColor, fontSize: 16),
                  ),
                ),
              ),
            ).paddingOnly(left: 20, right: 20, bottom: 20),
          ],
        ),
      ),
    );
  }
}
