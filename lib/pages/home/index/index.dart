import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:xiaofanshu_flutter/config/custom_icon.dart';
import 'package:xiaofanshu_flutter/controller/attention_controller.dart';
import 'package:xiaofanshu_flutter/controller/near_notes_controller.dart';
import 'package:xiaofanshu_flutter/controller/recommend_controller.dart';
import 'package:xiaofanshu_flutter/mapper/recommend_tab_mapper.dart';
import 'package:xiaofanshu_flutter/pages/home/index/attention.dart';
import 'package:xiaofanshu_flutter/pages/home/index/near_notes.dart';
import 'package:xiaofanshu_flutter/pages/home/index/recommend.dart';
import 'package:xiaofanshu_flutter/static/custom_color.dart';
import 'package:xiaofanshu_flutter/static/custom_string.dart';

class IndexPage extends StatefulWidget {
  const IndexPage({super.key});

  @override
  State<IndexPage> createState() => _IndexPageState();
}

class _IndexPageState extends State<IndexPage> with TickerProviderStateMixin {
  AttentionController attentionController = Get.find();
  RecommendController recommendController = Get.find();
  NearNotesController nearNotesController = Get.find();
  late TabController _tabController;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _tabController = TabController(length: 3, vsync: this, initialIndex: 1);
    _tabController.addListener(() {
      Get.log('index: ${_tabController.index}');
      if (_tabController.indexIsChanging) {
        return;
      }
      if (_tabController.index == 0) {
        attentionController.onTap();
      } else if (_tabController.index == 1) {
        recommendController.onTap();
      } else if (_tabController.index == 2) {
        nearNotesController.onTap();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
          controller: _tabController,
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
            _tabController.animateTo(index);
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
            onPressed: () {
              Get.toNamed('/search');
            },
          ),
        ],
        backgroundColor: const Color(0xffffffff),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          AttentionPage(),
          RecommendPage(),
          NearNotesPage(),
        ],
      ),
    );
  }
}
