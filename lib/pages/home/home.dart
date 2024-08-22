import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_pickers/image_pickers.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';
import 'package:xiaofanshu_flutter/controller/home_controller.dart';
import 'package:xiaofanshu_flutter/pages/home/index/index.dart';
import 'package:xiaofanshu_flutter/pages/home/message/recently_message.dart';
import 'package:xiaofanshu_flutter/pages/home/mine/mine.dart';
import 'package:xiaofanshu_flutter/static/custom_string.dart';
import 'package:xiaofanshu_flutter/utils/snackbar_util.dart';

import '../../static/custom_color.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  HomeController homeController = Get.find();
  List<Widget> pages = const [
    IndexPage(),
    Text('购物'),
    Text('发布'),
    RecentlyMessage(),
    MinePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() => pages[homeController.currentIndex.value]),
      bottomNavigationBar: Obx(
        () => BottomNavigationBar(
          backgroundColor: Colors.white,
          type: BottomNavigationBarType.fixed,
          elevation: 3,
          selectedFontSize: 0,
          unselectedFontSize: 0,
          showSelectedLabels: false,
          showUnselectedLabels: false,
          items: [
            const BottomNavigationBarItem(
                icon: Text(HomeTabName.index,
                    style: TextStyle(
                      fontSize: 16,
                      color: CustomColor.unselectedColor,
                    )),
                activeIcon: Text(HomeTabName.index,
                    style: TextStyle(
                      fontSize: 22,
                      color: Color(0xff2b2b2b),
                    )),
                label: HomeTabName.index),
            const BottomNavigationBarItem(
                icon: Text(HomeTabName.shopping,
                    style: TextStyle(
                      fontSize: 16,
                      color: CustomColor.unselectedColor,
                    )),
                activeIcon: Text(HomeTabName.shopping,
                    style: TextStyle(
                      fontSize: 22,
                      color: Color(0xff2b2b2b),
                    )),
                label: HomeTabName.shopping),
            BottomNavigationBarItem(
                icon: IconButton(
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  onPressed: () async {
                    // 选择发布图文还是视频
                    Get.bottomSheet(
                      SizedBox(
                        height: 160,
                        width: double.infinity,
                        child: Column(
                          children: [
                            GestureDetector(
                              onTap: () async {
                                Get.back();
                                List<AssetEntity>? result =
                                    await AssetPicker.pickAssets(
                                  context,
                                  pickerConfig: const AssetPickerConfig(
                                    maxAssets: 9,
                                    requestType: RequestType.image,
                                  ),
                                );
                                if (result != null && result.isNotEmpty) {
                                  List<File> files = [];
                                  for (var asset in result) {
                                    File? file = await asset.originFile;
                                    if (file != null) {
                                      files.add(file);
                                    }
                                  }
                                  Get.toNamed(
                                    '/publish/notes',
                                    arguments: {
                                      'type': 0,
                                      'files': files,
                                    },
                                  );
                                }
                              },
                              child: Container(
                                height: 50,
                                width: double.infinity,
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  border: Border(
                                    bottom: BorderSide(
                                      color: Color(0xffe5e5e5),
                                      width: 0.5,
                                    ),
                                  ),
                                ),
                                child: const Center(
                                  child: Text(
                                    '图文',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () async {
                                Get.back();
                                List<AssetEntity>? results =
                                    await AssetPicker.pickAssets(
                                  context,
                                  pickerConfig: const AssetPickerConfig(
                                    maxAssets: 1,
                                    requestType: RequestType.video,
                                  ),
                                );
                                if (results != null && results.isNotEmpty) {
                                  AssetEntity asset = results.first;
                                  File? file = await asset.originFile;
                                  if (file != null) {
                                    Get.toNamed(
                                      '/video/clip',
                                      arguments: {
                                        'file': file,
                                        'aspectRatio':
                                            asset.height / asset.width,
                                      },
                                    );
                                  }
                                }
                              },
                              child: Container(
                                height: 50,
                                width: double.infinity,
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  border: Border(
                                    bottom: BorderSide(
                                      color: Color(0xffe5e5e5),
                                      width: 0.5,
                                    ),
                                  ),
                                ),
                                child: const Center(
                                  child: Text(
                                    '视频',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            GestureDetector(
                              onTap: () {
                                Get.back();
                              },
                              child: Container(
                                height: 50,
                                width: double.infinity,
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  border: Border(
                                    bottom: BorderSide(
                                      color: Color(0xffe5e5e5),
                                      width: 0.5,
                                    ),
                                  ),
                                ),
                                child: const Center(
                                  child: Text(
                                    '取消',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                    // List<AssetEntity>? pickAssets =
                    //     await AssetPicker.pickAssets(
                    //   context,
                    //   pickerConfig: const AssetPickerConfig(
                    //     maxAssets: 9,
                    //   ),
                    // );
                  },
                  icon: Center(
                    child: Container(
                      width: 55,
                      height: 40,
                      decoration: BoxDecoration(
                        color: CustomColor.primaryColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.add,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                  ),
                ),
                label: HomeTabName.release),
            const BottomNavigationBarItem(
              icon: Text(HomeTabName.message,
                  style: TextStyle(
                    fontSize: 16,
                    color: CustomColor.unselectedColor,
                  )),
              activeIcon: Text(HomeTabName.message,
                  style: TextStyle(
                    fontSize: 22,
                    color: Color(0xff2b2b2b),
                  )),
              label: HomeTabName.message,
            ),
            const BottomNavigationBarItem(
                icon: Text(HomeTabName.mine,
                    style: TextStyle(
                      fontSize: 16,
                      color: CustomColor.unselectedColor,
                    )),
                activeIcon: Text(HomeTabName.mine,
                    style: TextStyle(
                      fontSize: 22,
                      color: Color(0xff2b2b2b),
                    )),
                label: HomeTabName.mine),
          ],
          currentIndex: homeController.currentIndex.value,
          onTap: homeController.changeIndex,
        ),
      ),
    );
  }
}
