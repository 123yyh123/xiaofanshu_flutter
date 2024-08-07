import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:xiaofanshu_flutter/controller/home_controller.dart';
import 'package:xiaofanshu_flutter/pages/home/index/index.dart';
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
    Text('消息'),
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
                  onPressed: () {
                    SnackbarUtil.show(HomeTabName.release, SnackbarUtil.info);
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
                label: HomeTabName.message),
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
