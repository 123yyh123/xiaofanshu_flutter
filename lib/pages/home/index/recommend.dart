import 'package:flutter/material.dart';
import 'package:xiaofanshu_flutter/controller/attention_controller.dart';
import 'package:xiaofanshu_flutter/controller/recommend_controller.dart';
import 'package:get/get.dart';
import 'package:xiaofanshu_flutter/static/default_data.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../../../components/item.dart';
import '../../../static/custom_color.dart';

class RecommendPage extends StatefulWidget {
  const RecommendPage({super.key});

  @override
  State<RecommendPage> createState() => _RecommendPageState();
}

class _RecommendPageState extends State<RecommendPage> {
  RecommendController recommendController = Get.find();
  AttentionController attentionController = Get.find();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff3f3f2),
      body: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return <Widget>[
            SliverAppBar(
              floating: false,
              pinned: true,
              backgroundColor: Colors.white,
              title: Obx(
                () => TabBar(
                  controller: recommendController.tabController,
                  tabAlignment: TabAlignment.start,
                  overlayColor: WidgetStateProperty.all(Colors.transparent),
                  enableFeedback: false,
                  isScrollable: true,
                  indicatorColor: CustomColor.primaryColor,
                  labelColor: CustomColor.primaryColor,
                  unselectedLabelColor: CustomColor.unselectedColor,
                  indicatorSize: TabBarIndicatorSize.label,
                  labelStyle: const TextStyle(fontSize: 13),
                  onTap: (index) {
                    recommendController.tabIndex.value = index;
                  },
                  tabs: recommendController.tabBarList.map((e) {
                    return Tab(
                      text: e,
                    );
                  }).toList(),
                ),
              ),
              titleSpacing: 0,
              toolbarHeight: 40,
            ),
          ];
        },
        body: RefreshIndicator(
          onRefresh: () async {},
          color: CustomColor.primaryColor,
          child: Obx(
            () => StaggeredGridView.countBuilder(
              controller: attentionController.scrollController,
              crossAxisCount: 2,
              itemCount: attentionController.attentionNotesList.length,
              mainAxisSpacing: 6,
              crossAxisSpacing: 8,
              padding: const EdgeInsets.all(10),
              itemBuilder: (BuildContext context, int index) {
                return ItemView(
                  coverPicture: attentionController.attentionNotesList[index]
                      ['coverPicture'],
                  noteTitle: attentionController.attentionNotesList[index]
                      ['title'],
                  authorAvatar: attentionController.attentionNotesList[index]
                      ['avatarUrl'],
                  authorName: attentionController.attentionNotesList[index]
                      ['nickname'],
                  notesLikeNum: attentionController.attentionNotesList[index]
                      ['notesLikeNum'],
                  notesType: attentionController.attentionNotesList[index]
                      ['notesType'],
                  isLike: attentionController.attentionNotesList[index]
                      ['isLike'],
                );
              },
              staggeredTileBuilder: (int index) => const StaggeredTile.fit(1),
            ),
          ),
        ),
      ),
    );
  }
}
