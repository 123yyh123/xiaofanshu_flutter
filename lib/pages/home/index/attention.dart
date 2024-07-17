import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get/get.dart';
import 'package:xiaofanshu_flutter/components/item.dart';
import 'package:xiaofanshu_flutter/controller/attention_controller.dart';
import 'package:xiaofanshu_flutter/static/custom_color.dart';

class AttentionPage extends StatefulWidget {
  const AttentionPage({super.key});

  @override
  State<AttentionPage> createState() => _AttentionPageState();
}

class _AttentionPageState extends State<AttentionPage> {
  AttentionController attentionController = Get.find();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff3f3f2),
      body: RefreshIndicator(
        onRefresh: () async {
          attentionController.onRefresh();
        },
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
                isLike: attentionController.attentionNotesList[index]['isLike'],
              );
            },
            staggeredTileBuilder: (int index) => const StaggeredTile.fit(1),
          ),
        ),
      ),
    );
  }
}
