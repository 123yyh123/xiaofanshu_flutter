import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:xiaofanshu_flutter/controller/home_controller.dart';
import 'package:xiaofanshu_flutter/pages/home/index.dart';
import 'package:xiaofanshu_flutter/utils/snackbar_util.dart';

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
    Text('我的'),
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
                icon: Text("首页",
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xffafafb0),
                    )),
                activeIcon: Text("首页",
                    style: TextStyle(
                      fontSize: 22,
                      color: Color(0xff2b2b2b),
                    )),
                label: '首页'),
            const BottomNavigationBarItem(
                icon: Text("购物",
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xffafafb0),
                    )),
                activeIcon: Text("购物",
                    style: TextStyle(
                      fontSize: 22,
                      color: Color(0xff2b2b2b),
                    )),
                label: '购物'),
            BottomNavigationBarItem(
                icon: IconButton(
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  onPressed: () {
                    SnackbarUtil.show("发布", SnackbarUtil.info);
                  },
                  icon: Center(
                    child: Container(
                      width: 55,
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xffFF2E4D),
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
                label: '发布'),
            const BottomNavigationBarItem(
                icon: Text("消息",
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xffafafb0),
                    )),
                activeIcon: Text("消息",
                    style: TextStyle(
                      fontSize: 22,
                      color: Color(0xff2b2b2b),
                    )),
                label: '消息'),
            const BottomNavigationBarItem(
                icon: Text("我的",
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xffafafb0),
                    )),
                activeIcon: Text("我的",
                    style: TextStyle(
                      fontSize: 22,
                      color: Color(0xff2b2b2b),
                    )),
                label: '我的'),
          ],
          currentIndex: homeController.currentIndex.value,
          onTap: homeController.changeIndex,
        ),
      ),
    );
  }
}
