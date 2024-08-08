import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:xiaofanshu_flutter/config/custom_icon.dart';
import 'package:xiaofanshu_flutter/controller/attention_controller.dart';
import 'package:xiaofanshu_flutter/controller/recommend_controller.dart';
import 'package:xiaofanshu_flutter/mapper/recommend_tab_mapper.dart';
import 'package:xiaofanshu_flutter/pages/home/index/attention.dart';
import 'package:xiaofanshu_flutter/pages/home/index/recommend.dart';
import 'package:xiaofanshu_flutter/static/custom_color.dart';
import 'package:xiaofanshu_flutter/static/custom_string.dart';

class IndexPage extends StatefulWidget {
  const IndexPage({super.key});

  @override
  State<IndexPage> createState() => _IndexPageState();
}

class _IndexPageState extends State<IndexPage> {
  AttentionController attentionController = Get.find();
  RecommendController recommendController = Get.find();

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        initialIndex: 1,
        length: 3,
        child: Scaffold(
          drawer: Drawer(
            child: ListView(
              children: [
                DrawerHeader(
                  child: Text('Drawer Header'),
                  decoration: BoxDecoration(
                    color: Colors.blue,
                  ),
                ),
                ListTile(
                  title: Text('Item 1'),
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  title: Text('Item 2'),
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
          appBar: AppBar(
            leading: Builder(
              builder: (BuildContext context) {
                return IconButton(
                  icon: const Icon(
                    CustomIcon.menu,
                    color: Colors.black87,
                    size: 30,
                  ),
                  onPressed: () {
                    Scaffold.of(context).openDrawer();
                  },
                );
              },
            ),
            leadingWidth: 40,
            centerTitle: true,
            title: TabBar(
              tabAlignment: TabAlignment.center,
              overlayColor: WidgetStateProperty.all(Colors.transparent),
              enableFeedback: false,
              isScrollable: true,
              indicatorColor: CustomColor.primaryColor,
              labelColor: CustomColor.primaryColor,
              unselectedLabelColor: CustomColor.unselectedColor,
              indicatorSize: TabBarIndicatorSize.label,
              labelStyle: const TextStyle(fontSize: 16),
              onTap: (index) {
                if (index == 0) {
                  attentionController.onTap();
                } else if (index == 1) {
                  recommendController.onTap();
                } else if (index == 2) {
                  print('南京');
                }
              },
              tabs: const [
                Tab(text: IndexTabName.attention),
                Tab(text: IndexTabName.recommend),
                Tab(text: IndexTabName.nearBy)
              ],
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.search, color: Colors.black87, size: 30),
                onPressed: () {},
              ),
            ],
            backgroundColor: const Color(0xffffffff),
          ),
          body: const TabBarView(children: [
            AttentionPage(),
            RecommendPage(),
            Center(child: Text('南京')),
          ]),
        ));
  }
}
