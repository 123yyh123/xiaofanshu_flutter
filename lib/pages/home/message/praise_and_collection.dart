import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:xiaofanshu_flutter/controller/praise_and_collection_controller.dart';
import 'package:xiaofanshu_flutter/static/custom_color.dart';
import 'package:xiaofanshu_flutter/utils/date_show_util.dart';

class PraiseAndCollection extends StatefulWidget {
  const PraiseAndCollection({super.key});

  @override
  State<PraiseAndCollection> createState() => _PraiseAndCollectionState();
}

class _PraiseAndCollectionState extends State<PraiseAndCollection> {
  PraiseAndCollectionController controller = Get.find();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            color: Colors.black,
          ),
          onPressed: () {
            Get.back();
          },
        ),
        title: const Text(
          '收到的赞和收藏',
          style: TextStyle(fontSize: 16),
        ),
        elevation: 1,
        shape: const Border(
          bottom: BorderSide(
            color: Color(0xffe5e5e5),
            width: 0.5,
          ),
        ),
      ),
      body: Obx(
        () => RefreshIndicator(
          onRefresh: () async {
            controller.onRefresh();
          },
          color: CustomColor.primaryColor,
          child: ListView.builder(
            controller: controller.scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            itemCount: controller.list.length,
            itemBuilder: (BuildContext context, int index) {
              return _messageItem(index);
            },
          ),
        ),
      ),
    );
  }

  Widget _messageItem(int index) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Color(0xffe5e5e5),
            width: 0.5,
          ),
        ),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: GestureDetector(
        onTap: () {
          int notesType =
              int.parse(controller.list[index]['notes_type'].toString());
          int notesId =
              int.parse(controller.list[index]['notes_id'].toString());
          notesType == 1
              ? Get.toNamed('/notes/detail/video', arguments: notesId)
              : notesType == 0
                  ? Get.toNamed('/notes/detail/image', arguments: notesId)
                  : null;
        },
        behavior: HitTestBehavior.opaque,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () {
                Get.toNamed('/other/mine',
                    arguments: controller.list[index]['user_id']);
              },
              child: Container(
                margin: const EdgeInsets.only(top: 10, bottom: 10),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(25),
                  child: Image.network(
                    controller.list[index]['avatar_url'],
                    width: 40,
                    height: 40,
                  ),
                ),
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () {
                      Get.toNamed('/other/mine',
                          arguments: controller.list[index]['user_id']);
                    },
                    child: Container(
                      margin: const EdgeInsets.only(left: 10),
                      child: Text(
                        controller.list[index]['user_name'],
                        style: const TextStyle(
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(left: 10),
                    child: Text(
                      '${controller.list[index]['content']}  ${DateShowUtil.showDateWithTime(controller.list[index]['time'])}',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(
                      controller.list[index]['notes_cover_picture'].toString()),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
