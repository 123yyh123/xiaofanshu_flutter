import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_swipe_action_cell/core/cell.dart';
import 'package:get/get.dart';
import 'package:xiaofanshu_flutter/controller/recently_message_controller.dart';
import 'package:xiaofanshu_flutter/utils/date_show_util.dart';
import 'package:xiaofanshu_flutter/utils/snackbar_util.dart';

import '../../../static/custom_color.dart';

class RecentlyMessage extends StatefulWidget {
  const RecentlyMessage({super.key});

  @override
  State<RecentlyMessage> createState() => _RecentlyMessageState();
}

class _RecentlyMessageState extends State<RecentlyMessage> {
  RecentlyMessageController controller = Get.find();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          '消息',
          style: TextStyle(fontSize: 20),
        ),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await Future.delayed(const Duration(seconds: 1));
          Get.snackbar('刷新成功', '刷新成功');
        },
        color: CustomColor.primaryColor,
        child: SingleChildScrollView(
          child: Column(
            children: [
              _topMessage(),
              _chatRecentlyMessage(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _topMessage() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Column(
          children: [
            Container(
              height: 50,
              width: 50,
              decoration: BoxDecoration(
                color: const Color(0xfffdeff2),
                borderRadius: BorderRadius.circular(15),
              ),
              child: const Center(
                child: Icon(
                  Icons.favorite_rounded,
                  color: Color(0xffe9546b),
                  size: 26,
                ),
              ),
            ),
            const Text(
              '赞和收藏',
              style: TextStyle(
                fontSize: 12,
                color: Color(0xff595857),
              ),
            ).marginOnly(top: 5)
          ],
        ),
        Column(
          children: [
            Container(
              height: 50,
              width: 50,
              decoration: BoxDecoration(
                color: const Color(0xffebf6f7),
                borderRadius: BorderRadius.circular(15),
              ),
              child: const Center(
                child: Icon(
                  Icons.person,
                  color: Color(0xff38a1db),
                  size: 26,
                ),
              ),
            ),
            const Text(
              '新增关注',
              style: TextStyle(
                fontSize: 12,
                color: Color(0xff595857),
              ),
            ).marginOnly(top: 5)
          ],
        ),
        Column(
          children: [
            Container(
              height: 50,
              width: 50,
              decoration: BoxDecoration(
                color: const Color(0xffd6e9ca).withOpacity(0.5),
                borderRadius: BorderRadius.circular(15),
              ),
              child: const Center(
                child: Icon(
                  Icons.maps_ugc,
                  color: Color(0xff68be8d),
                  size: 26,
                ),
              ),
            ),
            const Text(
              '评论和@',
              style: TextStyle(
                fontSize: 12,
                color: Color(0xff595857),
              ),
            ).marginOnly(top: 5)
          ],
        ),
      ],
    ).paddingOnly(top: 10, bottom: 10);
  }

  Widget _chatRecentlyMessage() {
    return Obx(
      () => Container(
        color: Colors.white,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: controller.recentlyMessageList.length,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () {
                Get.toNamed('/chat',
                    arguments: controller.recentlyMessageList[index].userId);
              },
              behavior: HitTestBehavior.opaque,
              child: SwipeActionCell(
                key: ObjectKey(index),
                trailingActions: <SwipeAction>[
                  SwipeAction(
                      title: "删除",
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                      onTap: (CompletionHandler handler) async {
                        controller.removeRecentlyMessage(index);
                        handler(true);
                      },
                      color: Colors.red),
                  SwipeAction(
                      title: "已读",
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                      onTap: (CompletionHandler handler) async {
                        controller.readRecentlyMessage(index);
                        handler(false);
                      },
                      color: Colors.orange),
                ],
                child: Row(
                  children: [
                    Container(
                      height: 50,
                      width: 50,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        image: DecorationImage(
                          image: NetworkImage(
                              controller.recentlyMessageList[index].avatarUrl),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                controller.recentlyMessageList[index].userName,
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Color(0xff595857),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                maxLines: 1,
                              ),
                              Text(
                                DateShowUtil.showDateWithTime(controller
                                    .recentlyMessageList[index].lastTime),
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xffadadad),
                                ),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                flex: 1,
                                child: Text(
                                  controller
                                      .recentlyMessageList[index].lastMessage,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Color(0xffadadad),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  maxLines: 1,
                                ),
                              ),
                              controller.recentlyMessageList[index].unreadNum ==
                                      0
                                  ? const SizedBox()
                                  : Container(
                                      height: 20,
                                      width: 20,
                                      decoration: BoxDecoration(
                                        color: const Color(0xffe9546b),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Center(
                                        child: Text(
                                          controller.recentlyMessageList[index]
                                                      .unreadNum >
                                                  99
                                              ? '99+'
                                              : controller
                                                  .recentlyMessageList[index]
                                                  .unreadNum
                                                  .toString(),
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                            ],
                          ),
                        ],
                      ).paddingOnly(left: 10),
                    ),
                  ],
                ).paddingAll(15),
              ),
            );
          },
        ),
      ),
    );
  }
}
