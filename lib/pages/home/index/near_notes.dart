import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get/get.dart';
import 'package:xiaofanshu_flutter/components/item.dart';
import 'package:xiaofanshu_flutter/controller/attention_controller.dart';
import 'package:xiaofanshu_flutter/controller/near_notes_controller.dart';
import 'package:xiaofanshu_flutter/static/custom_color.dart';

class NearNotesPage extends StatefulWidget {
  const NearNotesPage({super.key});

  @override
  State<NearNotesPage> createState() => _NearNotesPageState();
}

class _NearNotesPageState extends State<NearNotesPage> {
  NearNotesController nearNotesController = Get.find();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff3f3f2),
      body: RefreshIndicator(
        onRefresh: () async {
          nearNotesController.onRefresh();
        },
        color: CustomColor.primaryColor,
        child: Obx(
          () => nearNotesController.isRefresh.value &&
                  nearNotesController.nearNotesList.isEmpty
              ? const Center(
                  child: CircularProgressIndicator(
                      color: CustomColor.primaryColor),
                )
              : nearNotesController.nearNotesList.isEmpty
                  ? const Center(
                      child: Text('暂无数据'),
                    )
                  : StaggeredGridView.countBuilder(
                      controller: nearNotesController.scrollController,
                      crossAxisCount: 2,
                      itemCount: nearNotesController.nearNotesList.length,
                      mainAxisSpacing: 6,
                      crossAxisSpacing: 8,
                      padding: const EdgeInsets.all(10),
                      itemBuilder: (BuildContext context, int index) {
                        return ItemView(
                          id: nearNotesController.nearNotesList[index]['id'],
                          authorId: nearNotesController.nearNotesList[index]
                              ['belongUserId'],
                          coverPicture: nearNotesController.nearNotesList[index]
                              ['coverPicture'],
                          noteTitle: nearNotesController.nearNotesList[index]
                              ['title'],
                          authorAvatar: nearNotesController.nearNotesList[index]
                              ['avatarUrl'],
                          authorName: nearNotesController.nearNotesList[index]
                              ['nickname'],
                          notesLikeNum: nearNotesController.nearNotesList[index]
                              ['notesLikeNum'],
                          notesType: nearNotesController.nearNotesList[index]
                              ['notesType'],
                          isLike: nearNotesController.nearNotesList[index]
                              ['isLike'],
                        );
                      },
                      staggeredTileBuilder: (int index) =>
                          const StaggeredTile.fit(1),
                    ),
        ),
      ),
    );
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}
