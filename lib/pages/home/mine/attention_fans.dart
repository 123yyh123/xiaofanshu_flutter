import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:xiaofanshu_flutter/apis/app.dart';
import 'package:xiaofanshu_flutter/model/response.dart';

import '../../../controller/attention_fans_controller.dart';
import '../../../static/custom_code.dart';
import '../../../static/custom_color.dart';

class AttentionFans extends StatefulWidget {
  const AttentionFans({super.key});

  @override
  State<AttentionFans> createState() => _AttentionFansState();
}

class _AttentionFansState extends State<AttentionFans>
    with TickerProviderStateMixin {
  AttentionFansController attentionFansController = Get.find();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    int initIndex = Get.arguments;
    attentionFansController.tabController =
        TabController(length: 2, vsync: this, initialIndex: initIndex);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () {
            Get.back();
          },
        ),
        leadingWidth: 40,
        backgroundColor: Colors.white,
        title: TabBar(
          controller: attentionFansController.tabController,
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
            attentionFansController.tabController.animateTo(index);
          },
          tabs: const [Tab(text: "关注"), Tab(text: "粉丝")],
        ),
        centerTitle: true,
      ),
      body: TabBarView(
        controller: attentionFansController.tabController,
        children: [
          Obx(
            () => SingleChildScrollView(
              controller: attentionFansController.attentionScrollController,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "我的关注（${attentionFansController.attentionTotal.value}）",
                    style:
                        const TextStyle(fontSize: 14, color: Color(0xff949495)),
                  ).paddingOnly(top: 10, left: 10),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: attentionFansController.attentionList.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        leading: Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            image: DecorationImage(
                              image: NetworkImage(attentionFansController
                                  .attentionList[index]["avatarUrl"]),
                            ),
                          ),
                        ),
                        title: Text(
                          attentionFansController.attentionList[index]
                              ["nickname"],
                          style: const TextStyle(fontSize: 16),
                        ),
                        subtitle: Text(
                          attentionFansController.attentionList[index]
                              ["selfIntroduction"],
                          style: const TextStyle(
                              overflow: TextOverflow.ellipsis,
                              fontSize: 14,
                              color: Color(0xff949495)),
                          maxLines: 1,
                        ),
                        trailing: ElevatedButton(
                          style: ButtonStyle(
                            padding: WidgetStateProperty.all(
                              const EdgeInsets.symmetric(horizontal: 15),
                            ),
                            backgroundColor: WidgetStateProperty.all(
                              Colors.white,
                            ),
                            foregroundColor: WidgetStateProperty.all(
                              attentionFansController.attentionList[index]
                                      ["bidirectional"]
                                  ? CustomColor.unselectedColor
                                  : CustomColor.primaryColor,
                            ),
                            side: WidgetStateProperty.all(
                              BorderSide(
                                  color: attentionFansController
                                          .attentionList[index]["bidirectional"]
                                      ? CustomColor.unselectedColor
                                      : CustomColor.primaryColor),
                            ),
                          ),
                          onPressed: () async {
                            showCupertinoDialog(
                              context: context,
                              builder: (context) {
                                return CupertinoAlertDialog(
                                  title: const Text("提示"),
                                  content: const Text("确定要取消关注吗？"),
                                  actions: [
                                    CupertinoDialogAction(
                                      child: const Text("取消"),
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                    ),
                                    CupertinoDialogAction(
                                      child: const Text("确定"),
                                      onPressed: () async {
                                        HttpResponse response =
                                            await UserApi.attentionUser(
                                          attentionFansController
                                              .userInfo.value.id,
                                          int.parse(attentionFansController
                                              .attentionList[index]["userId"]),
                                        );
                                        if (response.code ==
                                            StatusCode.postSuccess) {
                                          attentionFansController.attentionList
                                              .removeAt(index);
                                        }
                                        Navigator.pop(context);
                                      },
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                          child: Text(
                            attentionFansController.attentionList[index]
                                    ["bidirectional"]
                                ? "互相关注"
                                : "已关注",
                            style: TextStyle(
                                fontSize: 14,
                                color: attentionFansController
                                        .attentionList[index]["bidirectional"]
                                    ? CustomColor.unselectedColor
                                    : CustomColor.primaryColor),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          Obx(
            () => SingleChildScrollView(
              controller: attentionFansController.fansScrollController,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "我的粉丝（${attentionFansController.fansTotal.value}）",
                    style:
                        const TextStyle(fontSize: 14, color: Color(0xff949495)),
                  ).paddingOnly(top: 10, left: 10),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: attentionFansController.fansList.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        leading: Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            image: DecorationImage(
                              image: NetworkImage(attentionFansController
                                  .fansList[index]["avatarUrl"]),
                            ),
                          ),
                        ),
                        title: Text(
                          attentionFansController.fansList[index]["nickname"],
                          style: const TextStyle(fontSize: 16),
                        ),
                        subtitle: Text(
                          attentionFansController.fansList[index]
                              ["selfIntroduction"],
                          style: const TextStyle(
                              overflow: TextOverflow.ellipsis,
                              fontSize: 14,
                              color: Color(0xff949495)),
                          maxLines: 1,
                        ),
                        trailing: ElevatedButton(
                          style: ButtonStyle(
                            padding: WidgetStateProperty.all(
                              const EdgeInsets.symmetric(horizontal: 15),
                            ),
                            backgroundColor: WidgetStateProperty.all(
                              Colors.white,
                            ),
                            foregroundColor: WidgetStateProperty.all(
                              attentionFansController.fansList[index]
                                      ["bidirectional"]
                                  ? CustomColor.unselectedColor
                                  : CustomColor.primaryColor,
                            ),
                            side: WidgetStateProperty.all(
                              BorderSide(
                                  color: attentionFansController.fansList[index]
                                          ["bidirectional"]
                                      ? CustomColor.unselectedColor
                                      : CustomColor.primaryColor),
                            ),
                          ),
                          onPressed: () async {
                            if (!attentionFansController.fansList[index]
                                ["bidirectional"]) {
                              HttpResponse response =
                                  await UserApi.attentionUser(
                                attentionFansController.userInfo.value.id,
                                int.parse(attentionFansController
                                    .fansList[index]["userId"]),
                              );
                              if (response.code == StatusCode.postSuccess) {
                                attentionFansController.fansList[index]
                                    ["bidirectional"] = true;
                                attentionFansController.fansList.refresh();
                              }
                              return;
                            } else {
                              showCupertinoDialog(
                                context: context,
                                builder: (context) {
                                  return CupertinoAlertDialog(
                                    title: const Text("提示"),
                                    content: const Text("确定要取消关注吗？"),
                                    actions: [
                                      CupertinoDialogAction(
                                        child: const Text("取消"),
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                      ),
                                      CupertinoDialogAction(
                                        child: const Text("确定"),
                                        onPressed: () async {
                                          HttpResponse response =
                                              await UserApi.attentionUser(
                                            attentionFansController
                                                .userInfo.value.id,
                                            int.parse(attentionFansController
                                                .fansList[index]["userId"]),
                                          );
                                          if (response.code ==
                                              StatusCode.postSuccess) {
                                            attentionFansController
                                                    .fansList[index]
                                                ["bidirectional"] = false;
                                            attentionFansController.fansList
                                                .refresh();
                                          }
                                          Navigator.pop(context);
                                        },
                                      ),
                                    ],
                                  );
                                },
                              );
                            }
                          },
                          child: Text(
                            attentionFansController.fansList[index]
                                    ["bidirectional"]
                                ? "互相关注"
                                : "回关",
                            style: TextStyle(
                                fontSize: 14,
                                color: attentionFansController.fansList[index]
                                        ["bidirectional"]
                                    ? CustomColor.unselectedColor
                                    : CustomColor.primaryColor),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
