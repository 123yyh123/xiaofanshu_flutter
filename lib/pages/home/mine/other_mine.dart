import 'dart:io';

import 'package:animation_wrappers/animations/faded_slide_animation.dart';
import 'package:extended_nested_scroll_view/extended_nested_scroll_view.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:xiaofanshu_flutter/apis/app.dart';
import 'package:xiaofanshu_flutter/config/custom_icon.dart';
import 'package:xiaofanshu_flutter/controller/mine_controller.dart';
import 'package:xiaofanshu_flutter/controller/other_mine_controller.dart';
import 'package:xiaofanshu_flutter/model/response.dart';
import 'package:xiaofanshu_flutter/static/custom_color.dart';
import 'package:xiaofanshu_flutter/static/custom_string.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:xiaofanshu_flutter/utils/date_show_util.dart';
import 'package:xiaofanshu_flutter/utils/snackbar_util.dart';
import 'package:xiaofanshu_flutter/utils/toast_util.dart';
import '../../../components/item.dart';
import '../../../static/custom_code.dart';

class OtherMine extends StatefulWidget {
  const OtherMine({super.key});

  @override
  State<OtherMine> createState() => _OtherMineState();
}

class _OtherMineState extends State<OtherMine> with TickerProviderStateMixin {
  OtherMineController otherMineController = Get.find();
  late TabController _tabController;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    otherMineController.appBarOpacity.value = 0.0;
    _tabController = TabController(length: 2, vsync: this, initialIndex: 0);
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));
    return Obx(
      () => Scaffold(
        backgroundColor: Colors.transparent,
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent
              .withOpacity(otherMineController.appBarOpacity.value),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      Get.back();
                    },
                    child: const Icon(
                      Icons.arrow_back_ios,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ],
              ),
              otherMineController.isShowTopAvatar.value
                  ? FadedSlideAnimation(
                      beginOffset: const Offset(0, 1),
                      endOffset: Offset.zero,
                      fadeDuration: const Duration(milliseconds: 300),
                      slideDuration: const Duration(milliseconds: 300),
                      child: Container(
                        width: 35,
                        height: 35,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(40),
                          image: DecorationImage(
                            image: NetworkImage(
                                otherMineController.userInfo['avatarUrl']),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    )
                  : Container(),
              GestureDetector(
                onTap: () {
                  ToastUtil.showSimpleToast("暂无权限");
                },
                child: const Icon(
                  Icons.more_horiz,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ],
          ),
          leadingWidth: 0,
          leading: Container(),
        ),
        body: otherMineController.userInfo.keys.isEmpty
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : ExtendedNestedScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                controller: otherMineController.scrollController,
                scrollDirection: Axis.vertical,
                headerSliverBuilder: (context, innerBoxIsScrolled) {
                  return <Widget>[
                    SliverToBoxAdapter(
                      child: Obx(
                        () => Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.black.withOpacity(0.9), // 从上到下渐变变暗
                                Colors.transparent,
                              ],
                            ),
                            image: DecorationImage(
                              image: NetworkImage(otherMineController
                                  .userInfo['homePageBackground']),
                              fit: BoxFit.cover,
                            ),
                          ),
                          child: Container(
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.black38, // 从上到下渐变变暗
                                  Colors.black87,
                                ],
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // 顶部位置
                                SizedBox(
                                  height: MediaQuery.of(context).padding.top,
                                ),
                                // 用户信息
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    GestureDetector(
                                      behavior: HitTestBehavior.opaque,
                                      onTap: () {
                                        List<String> images = [
                                          otherMineController
                                              .userInfo['avatarUrl'],
                                        ];
                                        Get.toNamed(
                                          '/image/simple/pre',
                                          arguments: images,
                                        );
                                      },
                                      child: Container(
                                        width: 80,
                                        height: 80,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(40),
                                          image: DecorationImage(
                                            image: NetworkImage(
                                                otherMineController
                                                    .userInfo['avatarUrl']),
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 80,
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            otherMineController
                                                .userInfo['nickname'],
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(
                                            '小番薯号：${otherMineController.userInfo['uid']}',
                                            style: const TextStyle(
                                              color: Color(0xffa3a3a2),
                                              fontSize: 10,
                                            ),
                                          ),
                                        ],
                                      ).marginOnly(left: 10),
                                    ),
                                  ],
                                ).paddingOnly(left: 15, right: 15),

                                // 个人简介
                                Text(
                                  otherMineController
                                      .userInfo['selfIntroduction'],
                                  maxLines: 3,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.white,
                                    letterSpacing: 0.5,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ).marginOnly(top: 10, left: 15, right: 15),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Container(
                                      height: 20,
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          otherMineController.userInfo['sex'] ==
                                                  1
                                              ? const Icon(Icons.male,
                                                  color: Colors.lightBlue,
                                                  size: 12)
                                              : const Icon(Icons.female,
                                                  color: Colors.pinkAccent,
                                                  size: 12),
                                          Text(
                                            ' ${otherMineController.userInfo['age']}岁',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 10,
                                            ),
                                          )
                                        ],
                                      ).paddingOnly(left: 8, right: 8),
                                    ).marginOnly(left: 15),
                                  ],
                                ).marginOnly(top: 10),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      width: MediaQuery.of(context).size.width *
                                          0.4,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          GestureDetector(
                                              onTap: () {
                                                ToastUtil.showSimpleToast(
                                                    "暂无权限");
                                              },
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    '${otherMineController.userInfo['attentionNum']}',
                                                    style: const TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 12),
                                                  ),
                                                  const Text(
                                                    MineString.attention,
                                                    style: TextStyle(
                                                        color: Colors.white70,
                                                        fontSize: 10),
                                                  ),
                                                ],
                                              ).paddingOnly(
                                                  left: 10, right: 10)),
                                          GestureDetector(
                                              onTap: () {
                                                ToastUtil.showSimpleToast(
                                                    "暂无权限");
                                              },
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    '${otherMineController.userInfo['fansNum']}',
                                                    style: const TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 12),
                                                  ),
                                                  const Text(
                                                    MineString.fans,
                                                    style: TextStyle(
                                                        color: Colors.white70,
                                                        fontSize: 10),
                                                  ),
                                                ],
                                              ).paddingOnly(
                                                  left: 30, right: 10)),
                                        ],
                                      ).paddingOnly(left: 15),
                                    ),
                                    Expanded(
                                      flex: 1,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          GestureDetector(
                                            onTap: () {
                                              Get.toNamed('/chat',
                                                  arguments: int.parse(
                                                      otherMineController
                                                          .userInfo['id']));
                                            },
                                            child: Container(
                                              height: 30,
                                              alignment: Alignment.center,
                                              decoration: BoxDecoration(
                                                color: Colors.white
                                                    .withOpacity(0.2),
                                                borderRadius:
                                                    BorderRadius.circular(15),
                                              ),
                                              child: const Text(
                                                '发消息',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 13,
                                                ),
                                              ).paddingOnly(
                                                  left: 15, right: 15),
                                            ),
                                          ),
                                          GestureDetector(
                                            onTap: () {
                                              if (otherMineController.userInfo[
                                                      'attentionStatus'] ==
                                                  0) {
                                                UserApi.attentionUser(
                                                        otherMineController
                                                            .myUserId.value,
                                                        int.parse(
                                                            otherMineController
                                                                    .userInfo[
                                                                'id']))
                                                    .then((res) {
                                                  if (res.code ==
                                                      StatusCode.postSuccess) {
                                                    otherMineController
                                                            .userInfo[
                                                        'attentionStatus'] = 1;
                                                    otherMineController.userInfo
                                                        .refresh();
                                                    SnackbarUtil.showSuccess(
                                                        '关注成功');
                                                  } else {
                                                    SnackbarUtil.showError(
                                                        '关注失败');
                                                  }
                                                });
                                              } else {
                                                showCupertinoDialog(
                                                  context: context,
                                                  builder: (context) {
                                                    return CupertinoAlertDialog(
                                                      title: const Text('提示'),
                                                      content: const Text(
                                                          '确定取消关注吗？'),
                                                      actions: <Widget>[
                                                        CupertinoDialogAction(
                                                          child:
                                                              const Text('取消'),
                                                          onPressed: () {
                                                            Navigator.of(
                                                                    context)
                                                                .pop();
                                                          },
                                                        ),
                                                        CupertinoDialogAction(
                                                          child:
                                                              const Text('确定'),
                                                          onPressed: () async {
                                                            HttpResponse
                                                                response =
                                                                await UserApi.attentionUser(
                                                                    otherMineController
                                                                        .myUserId
                                                                        .value,
                                                                    int.parse(otherMineController
                                                                            .userInfo[
                                                                        'id']));
                                                            if (response.code ==
                                                                StatusCode
                                                                    .postSuccess) {
                                                              otherMineController
                                                                      .userInfo[
                                                                  'attentionStatus'] = 0;
                                                              otherMineController
                                                                  .userInfo
                                                                  .refresh();
                                                              SnackbarUtil
                                                                  .showSuccess(
                                                                      '取消关注成功');
                                                            } else {
                                                              SnackbarUtil
                                                                  .showError(
                                                                      '取消关注失败');
                                                            }
                                                            Navigator.of(
                                                                    context)
                                                                .pop();
                                                          },
                                                        ),
                                                      ],
                                                    );
                                                  },
                                                );
                                              }
                                            },
                                            child: Container(
                                              height: 30,
                                              alignment: Alignment.center,
                                              decoration: BoxDecoration(
                                                color: Colors.white
                                                    .withOpacity(0.2),
                                                borderRadius:
                                                    BorderRadius.circular(15),
                                              ),
                                              child: Icon(
                                                otherMineController.userInfo[
                                                            'attentionStatus'] ==
                                                        1
                                                    ? Icons
                                                        .person_remove_alt_1_rounded
                                                    : Icons
                                                        .person_add_alt_1_rounded,
                                                color: Colors.white,
                                                size: 16,
                                              ).paddingOnly(
                                                  left: 15, right: 15),
                                            ).marginOnly(left: 30),
                                          ),
                                        ],
                                      ).paddingOnly(left: 30, right: 30),
                                    ),
                                  ],
                                ).marginOnly(top: 15),
                                const SizedBox(
                                  height: 30,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ];
                },
                pinnedHeaderSliverHeightBuilder: () {
                  return MediaQuery.of(context).padding.top + 56;
                },
                onlyOneScrollInBody: true,
                body: SizedBox(
                  width: double.infinity,
                  height: double.infinity,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _tabBars(),
                      _tarBarView(),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  _tabBars() {
    return Container(
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Color(0xfffffffc),
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TabBar(
            controller: _tabController,
            tabAlignment: TabAlignment.center,
            labelColor: Colors.black,
            unselectedLabelColor: CustomColor.unselectedColor,
            // 选择的样式
            labelStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
            unselectedLabelStyle: const TextStyle(
              fontSize: 16,
            ),
            isScrollable: true,
            indicatorSize: TabBarIndicatorSize.tab,
            indicator: const UnderlineTabIndicator(
              borderRadius: BorderRadius.all(Radius.circular(10)),
              borderSide: BorderSide(
                width: 3.0,
                color: CustomColor.primaryColor,
              ),
            ),
            indicatorPadding: const EdgeInsets.only(left: 10.0, right: 10.0),
            tabs: otherMineController.tabs.map((e) => Tab(text: e)).toList(),
            onTap: (index) {
              // 切换tab
              _tabController.animateTo(index);
            },
          ),
        ],
      ).paddingOnly(bottom: 5),
    );
  }

  //tab下的view
  _tarBarView() {
    return Expanded(
      child: TabBarView(
          controller: _tabController,
          // physics: const AlwaysScrollableScrollPhysics(),
          children: [
            Column(
              children: [
                Expanded(
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.transparent,
                    ),
                    child: Obx(
                      () => StaggeredGridView.countBuilder(
                        crossAxisCount: 2,
                        itemCount: otherMineController.myNotes.length,
                        mainAxisSpacing: 6,
                        crossAxisSpacing: 8,
                        padding: const EdgeInsets.all(10),
                        itemBuilder: (BuildContext context, int index) {
                          return ItemView(
                            id: otherMineController.myNotes[index]['id'],
                            authorId: otherMineController.myNotes[index]
                                ['belongUserId'],
                            coverPicture: otherMineController.myNotes[index]
                                ['coverPicture'],
                            noteTitle: otherMineController.myNotes[index]
                                ['title'],
                            authorAvatar: otherMineController.myNotes[index]
                                ['avatarUrl'],
                            authorName: otherMineController.myNotes[index]
                                ['nickname'],
                            notesLikeNum: otherMineController.myNotes[index]
                                ['notesLikeNum'],
                            notesType: otherMineController.myNotes[index]
                                ['notesType'],
                            isLike: otherMineController.myNotes[index]
                                ['isLike'],
                          );
                        },
                        staggeredTileBuilder: (int index) =>
                            const StaggeredTile.fit(1),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Container(
              decoration: const BoxDecoration(
                color: Colors.white,
              ),
              child: const Center(
                child: Text(
                  '暂未开放',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ]),
    );
  }
}
