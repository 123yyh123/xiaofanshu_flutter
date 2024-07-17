import 'package:flutter/material.dart';
import 'package:xiaofanshu_flutter/controller/recommend_controller.dart';
import 'package:get/get.dart';
import '../../../static/custom_color.dart';

class RecommendPage extends StatefulWidget {
  const RecommendPage({super.key});

  @override
  State<RecommendPage> createState() => _RecommendPageState();
}

class _RecommendPageState extends State<RecommendPage> {
  RecommendController recommendController = Get.find();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff3f3f2),
      body: RefreshIndicator(
        onRefresh: () async {},
        color: CustomColor.primaryColor,
        child: Column(
          children: [
            Obx(
              () => TabBar(
                tabAlignment: TabAlignment.start,
                overlayColor: WidgetStateProperty.all(Colors.transparent),
                enableFeedback: false,
                isScrollable: true,
                indicatorColor: CustomColor.primaryColor,
                labelColor: CustomColor.primaryColor,
                unselectedLabelColor: CustomColor.unselectedColor,
                indicatorSize: TabBarIndicatorSize.label,
                labelStyle: const TextStyle(fontSize: 13),
                onTap: (index) {},
                tabs: recommendController.tabBarList.isEmpty
                    ? []
                    : recommendController.tabBarList
                        .map((e) => Tab(text: e))
                        .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
