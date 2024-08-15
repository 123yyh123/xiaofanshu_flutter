import 'package:animation_wrappers/animations/faded_slide_animation.dart';
import 'package:extended_nested_scroll_view/extended_nested_scroll_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:xiaofanshu_flutter/config/custom_icon.dart';
import 'package:xiaofanshu_flutter/controller/mine_controller.dart';
import 'package:xiaofanshu_flutter/static/custom_color.dart';
import 'package:xiaofanshu_flutter/static/custom_string.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../../../components/item.dart';

class MinePage extends StatefulWidget {
  const MinePage({super.key});

  @override
  State<MinePage> createState() => _MinePageState();
}

class _MinePageState extends State<MinePage> with TickerProviderStateMixin {
  MineController mineController = Get.find();
  late TabController _tabController;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    mineController.appBarOpacity.value = 0.0;
    _tabController = TabController(length: 3, vsync: this, initialIndex: 0);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        return;
      }
      Get.log('index: ${_tabController.index}');
      switch (_tabController.index) {
        case 0:
          mineController.notesTabType.value = 0;
          mineController.onTap(TabsType.notes);
          break;
        case 1:
          mineController.notesTabType.value = 1;
          mineController.onTap(TabsType.collects);
          break;
        case 2:
          mineController.notesTabType.value = 2;
          mineController.onTap(TabsType.likes);
          break;
      }
    });
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
              .withOpacity(mineController.appBarOpacity.value),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                children: [
                  Builder(builder: (context) {
                    return IconButton(
                      icon: const Icon(
                        CustomIcon.menu,
                        color: Colors.white,
                        size: 25,
                      ),
                      onPressed: () {
                        Scaffold.of(context).openDrawer();
                      },
                    );
                  }),
                  IconButton(
                    style: ButtonStyle(
                      overlayColor: WidgetStateProperty.all(Colors.transparent),
                    ),
                    onPressed: () {},
                    icon: const Icon(
                      Icons.catching_pokemon_rounded,
                      color: Colors.transparent,
                    ),
                  ),
                ],
              ),
              mineController.isShowTopAvatar.value
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
                                mineController.userInfo.value.avatarUrl),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    )
                  : Container(),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(
                      CustomIcon.share,
                      color: Colors.white,
                      size: 22,
                    ),
                    onPressed: () {
                      Get.snackbar('分享', '分享给好友');
                    },
                  ),
                  IconButton(
                    icon: const Icon(
                      CustomIcon.scanQR,
                      color: Colors.white,
                      size: 22,
                    ),
                    onPressed: () {
                      Get.snackbar('扫一扫', '扫描二维码');
                    },
                  ),
                ],
              ),
            ],
          ),
          leadingWidth: 0,
          leading: Container(),
        ),
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
        body: RefreshIndicator(
          onRefresh: () async {
            await mineController.onRefresh();
          },
          color: CustomColor.primaryColor,
          notificationPredicate: (ScrollNotification notification) {
            return true;
          },
          child: ExtendedNestedScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            controller: mineController.scrollController,
            scrollDirection: Axis.vertical,
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return <Widget>[
                SliverToBoxAdapter(
                  child: Obx(
                    () => Container(
                      height: MediaQuery.of(context).size.height * 0.5,
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
                          image: NetworkImage(
                              mineController.userInfo.value.homePageBackground),
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
                            GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: () {
                                Get.toNamed(
                                  '/image/backgroundPreview',
                                  arguments: mineController
                                      .userInfo.value.homePageBackground,
                                );
                              },
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Stack(
                                    children: [
                                      GestureDetector(
                                        behavior: HitTestBehavior.opaque,
                                        onTap: () {
                                          Get.toNamed(
                                            '/image/preview',
                                            arguments: mineController
                                                .userInfo.value.avatarUrl,
                                          );
                                        },
                                        child: Container(
                                          width: 80,
                                          height: 80,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(40),
                                            image: DecorationImage(
                                              image: NetworkImage(mineController
                                                  .userInfo.value.avatarUrl),
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        right: 0,
                                        bottom: 0,
                                        child: Container(
                                          width: 24,
                                          height: 24,
                                          decoration: BoxDecoration(
                                            color: Colors.amberAccent,
                                            borderRadius:
                                                BorderRadius.circular(15),
                                          ),
                                          child: const Icon(
                                            Icons.add,
                                            color: Colors.black,
                                            size: 16,
                                          ),
                                        ),
                                      ),
                                    ],
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
                                          mineController
                                              .userInfo.value.nickname,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          '小番薯号：${mineController.userInfo.value.uid}',
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
                            ),
                            // 个人简介
                            Text(
                              mineController.userInfo.value.selfIntroduction,
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
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      mineController.userInfo.value.sex == 1
                                          ? const Icon(Icons.male,
                                              color: Colors.lightBlue, size: 12)
                                          : const Icon(Icons.female,
                                              color: Colors.pinkAccent,
                                              size: 12),
                                      Text(
                                        ' ${mineController.userInfo.value.age}岁',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 10,
                                        ),
                                      )
                                    ],
                                  ).paddingOnly(left: 8, right: 8),
                                ).marginOnly(left: 15),
                                mineController.userInfo.value.ipAddr.isEmpty
                                    ? Container()
                                    : Container(
                                        height: 20,
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.2),
                                          borderRadius:
                                              BorderRadius.circular(15),
                                        ),
                                        child: Text(
                                          ' ${mineController.userInfo.value.ipAddr}',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 10,
                                          ),
                                        ).paddingOnly(left: 8, right: 8),
                                      ).marginOnly(left: 10),
                              ],
                            ).marginOnly(top: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width * 0.5,
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      GestureDetector(
                                          onTap: () {},
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                '${mineController.userInfo.value.attentionNum}',
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
                                          ).paddingOnly(left: 10, right: 10)),
                                      GestureDetector(
                                          onTap: () {},
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                '${mineController.userInfo.value.fansNum}',
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
                                          ).paddingOnly(left: 10, right: 10)),
                                      GestureDetector(
                                          onTap: () {
                                            Get.dialog(
                                              SimpleDialog(
                                                backgroundColor:
                                                    const Color(0xfffffffc),
                                                title: const Text('获赞和收藏',
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                      color: Colors.black,
                                                      fontSize: 18,
                                                    )),
                                                children: [
                                                  Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    children: [
                                                      Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          const Text(
                                                            '当前发布笔记数',
                                                            style: TextStyle(
                                                              color: CustomColor
                                                                  .unselectedColor,
                                                              fontSize: 12,
                                                            ),
                                                          ).marginOnly(
                                                              right: 10),
                                                          Text(
                                                            '${mineController.notesCount.value}',
                                                            style:
                                                                const TextStyle(
                                                              color:
                                                                  Colors.black,
                                                              fontSize: 12,
                                                            ),
                                                          ),
                                                        ],
                                                      ).marginOnly(
                                                          top: 10, bottom: 10),
                                                      Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          const Text(
                                                            '当前获得点赞数',
                                                            style: TextStyle(
                                                              color: CustomColor
                                                                  .unselectedColor,
                                                              fontSize: 12,
                                                            ),
                                                          ).marginOnly(
                                                              right: 10),
                                                          Text(
                                                            '${mineController.praiseCount.value}',
                                                            style:
                                                                const TextStyle(
                                                              color:
                                                                  Colors.black,
                                                              fontSize: 12,
                                                            ),
                                                          ),
                                                        ],
                                                      ).marginOnly(
                                                          top: 10, bottom: 10),
                                                      Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          const Text(
                                                            '当前获得收藏数',
                                                            style: TextStyle(
                                                              color: CustomColor
                                                                  .unselectedColor,
                                                              fontSize: 12,
                                                            ),
                                                          ).marginOnly(
                                                              right: 10),
                                                          Text(
                                                            '${mineController.collectCount.value}',
                                                            style:
                                                                const TextStyle(
                                                              color:
                                                                  Colors.black,
                                                              fontSize: 12,
                                                            ),
                                                          ),
                                                        ],
                                                      ).marginOnly(
                                                          top: 10, bottom: 10),
                                                      TextButton(
                                                        onPressed: () {
                                                          Get.back();
                                                        },
                                                        style: ButtonStyle(
                                                          overlayColor:
                                                              WidgetStateProperty
                                                                  .all(
                                                            Colors.transparent,
                                                          ),
                                                        ),
                                                        child: Container(
                                                          width:
                                                              double.infinity,
                                                          height: 30,
                                                          alignment:
                                                              Alignment.center,
                                                          decoration:
                                                              BoxDecoration(
                                                            color: CustomColor
                                                                .primaryColor,
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        15),
                                                          ),
                                                          child: const Text(
                                                            '我知道了',
                                                            style: TextStyle(
                                                              color:
                                                                  Colors.white,
                                                              fontSize: 12,
                                                            ),
                                                          ),
                                                        ).marginOnly(top: 10),
                                                      ),
                                                    ],
                                                  ).marginOnly(
                                                      left: 25, right: 25),
                                                ],
                                              ),
                                            );
                                          },
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                '${mineController.praiseCount.value + mineController.collectCount.value}',
                                                style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 12),
                                              ),
                                              const Text(
                                                MineString.getPraiseAndCollect,
                                                style: TextStyle(
                                                    color: Colors.white70,
                                                    fontSize: 10),
                                              ),
                                            ],
                                          ).paddingOnly(left: 10, right: 10)),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Container(
                                        height: 30,
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.2),
                                          borderRadius:
                                              BorderRadius.circular(15),
                                        ),
                                        child: const Text(
                                          '编辑资料',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 13,
                                          ),
                                        ).paddingOnly(left: 15, right: 15),
                                      ),
                                      Container(
                                        height: 30,
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.2),
                                          borderRadius:
                                              BorderRadius.circular(15),
                                        ),
                                        child: const Icon(
                                          Icons.settings,
                                          color: Colors.white,
                                          size: 16,
                                        ).paddingOnly(left: 15, right: 15),
                                      ).marginOnly(left: 15),
                                    ],
                                  ).paddingOnly(left: 10, right: 15),
                                ),
                              ],
                            ).marginOnly(top: 15),
                            Expanded(
                              flex: 1,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        width:
                                            (MediaQuery.of(context).size.width -
                                                    50) /
                                                3,
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                          color: Colors.grey.withOpacity(0.4),
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        child: const Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Icon(
                                                  Icons.shopping_cart_outlined,
                                                  color: Colors.white,
                                                  size: 14,
                                                ),
                                                SizedBox(width: 5),
                                                Text(
                                                  '购物车',
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            SizedBox(height: 5),
                                            Text(
                                              '查看推荐好物',
                                              style: TextStyle(
                                                color: Colors.white70,
                                                fontSize: 10,
                                              ),
                                            ),
                                          ],
                                        ).paddingOnly(
                                            top: 8,
                                            bottom: 8,
                                            left: 15,
                                            right: 15),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(width: 10),
                                  Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        width:
                                            (MediaQuery.of(context).size.width -
                                                    50) /
                                                3,
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                          color: Colors.grey.withOpacity(0.4),
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        child: const Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Icon(
                                                  Icons.lightbulb_outlined,
                                                  color: Colors.white,
                                                  size: 14,
                                                ),
                                                SizedBox(width: 5),
                                                Text(
                                                  '创作灵感',
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            SizedBox(height: 5),
                                            Text(
                                              '学创作找灵感',
                                              style: TextStyle(
                                                color: Colors.white70,
                                                fontSize: 10,
                                              ),
                                            ),
                                          ],
                                        ).paddingOnly(
                                            top: 8,
                                            bottom: 8,
                                            left: 15,
                                            right: 15),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(width: 10),
                                  Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        width:
                                            (MediaQuery.of(context).size.width -
                                                    50) /
                                                3,
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                          color: Colors.grey.withOpacity(0.4),
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        child: const Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Icon(
                                                  Icons.history,
                                                  color: Colors.white,
                                                  size: 14,
                                                ),
                                                SizedBox(width: 5),
                                                Text(
                                                  '浏览记录',
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            SizedBox(height: 5),
                                            Text(
                                              '看过的笔记',
                                              style: TextStyle(
                                                color: Colors.white70,
                                                fontSize: 10,
                                              ),
                                            ),
                                          ],
                                        ).paddingOnly(
                                            top: 8,
                                            bottom: 8,
                                            left: 15,
                                            right: 15),
                                      ),
                                    ],
                                  ),
                                ],
                              ).marginOnly(left: 15, right: 15),
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
      ),
    );
  }

  _tabBars() {
    return Container(
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Color(0xffe5e5e5),
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
            tabs: mineController.tabs.map((e) => Tab(text: e)).toList(),
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
                Container(
                  decoration: const BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: Color(0xffe5e5e5),
                        width: 0.5,
                      ),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      TextButton(
                        style: ButtonStyle(
                          overlayColor:
                              WidgetStateProperty.all(Colors.transparent),
                        ),
                        onPressed: () {
                          mineController.notesPublishType.value = 0;
                          mineController.onTap(TabsType.publish);
                        },
                        child: Text(
                          '公开${mineController.publishNotesNum.value == 0 ? '' : ' • ${mineController.publishNotesNum.value}'}',
                          style: TextStyle(
                            color: mineController.notesPublishType.value == 0
                                ? CustomColor.primaryColor
                                : CustomColor.unselectedColor,
                          ),
                        ),
                      ),
                      TextButton(
                        style: ButtonStyle(
                          overlayColor: WidgetStateProperty.all(
                              Colors.transparent), // 按下时的背景色
                        ),
                        onPressed: () {
                          mineController.notesPublishType.value = 1;
                          mineController.onTap(TabsType.private);
                        },
                        child: Text(
                          '私密${mineController.privateNotesNum.value == 0 ? '' : ' • ${mineController.privateNotesNum.value}'}',
                          style: TextStyle(
                            color: mineController.notesPublishType.value == 1
                                ? CustomColor.primaryColor
                                : CustomColor.unselectedColor,
                          ),
                        ),
                      ),
                      TextButton(
                        style: ButtonStyle(
                          overlayColor: WidgetStateProperty.all(
                              Colors.transparent), // 按下时的背景色
                        ),
                        onPressed: () {
                          mineController.notesPublishType.value = 2;
                          mineController.onTap(TabsType.draft);
                        },
                        child: Text(
                          '草稿${mineController.draftNotesNum.value == 0 ? '' : ' • ${mineController.draftNotesNum.value}'}',
                          style: TextStyle(
                            color: mineController.notesPublishType.value == 2
                                ? CustomColor.primaryColor
                                : CustomColor.unselectedColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.transparent,
                    ),
                    child: Obx(
                      () => StaggeredGridView.countBuilder(
                        crossAxisCount: 2,
                        itemCount: mineController.myNotes.length,
                        mainAxisSpacing: 6,
                        crossAxisSpacing: 8,
                        padding: const EdgeInsets.all(10),
                        itemBuilder: (BuildContext context, int index) {
                          return ItemView(
                            id: mineController.myNotes[index]['id'],
                            authorId: mineController.myNotes[index]
                                ['belongUserId'],
                            coverPicture: mineController.myNotes[index]
                                ['coverPicture'],
                            noteTitle: mineController.myNotes[index]['title'],
                            authorAvatar: mineController.myNotes[index]
                                ['avatarUrl'],
                            authorName: mineController.myNotes[index]
                                ['nickname'],
                            notesLikeNum: mineController.myNotes[index]
                                ['notesLikeNum'],
                            notesType: mineController.myNotes[index]
                                ['notesType'],
                            isLike: mineController.myNotes[index]['isLike'],
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
                color: Colors.transparent,
              ),
              child: Obx(
                () => StaggeredGridView.countBuilder(
                  crossAxisCount: 2,
                  itemCount: mineController.myCollects.length,
                  mainAxisSpacing: 6,
                  crossAxisSpacing: 8,
                  padding: const EdgeInsets.all(10),
                  itemBuilder: (BuildContext context, int index) {
                    return ItemView(
                      id: mineController.myCollects[index]['id'],
                      authorId: mineController.myCollects[index]
                          ['belongUserId'],
                      coverPicture: mineController.myCollects[index]
                          ['coverPicture'],
                      noteTitle: mineController.myCollects[index]['title'],
                      authorAvatar: mineController.myCollects[index]
                          ['avatarUrl'],
                      authorName: mineController.myCollects[index]['nickname'],
                      notesLikeNum: mineController.myCollects[index]
                          ['notesLikeNum'],
                      notesType: mineController.myCollects[index]['notesType'],
                      isLike: mineController.myCollects[index]['isLike'],
                    );
                  },
                  staggeredTileBuilder: (int index) =>
                      const StaggeredTile.fit(1),
                ),
              ),
            ),
            Container(
              decoration: const BoxDecoration(
                color: Colors.transparent,
              ),
              child: Obx(
                () => StaggeredGridView.countBuilder(
                  crossAxisCount: 2,
                  itemCount: mineController.myLikes.length,
                  mainAxisSpacing: 6,
                  crossAxisSpacing: 8,
                  padding: const EdgeInsets.all(10),
                  itemBuilder: (BuildContext context, int index) {
                    return ItemView(
                      id: mineController.myLikes[index]['id'],
                      authorId: mineController.myLikes[index]['belongUserId'],
                      coverPicture: mineController.myLikes[index]
                          ['coverPicture'],
                      noteTitle: mineController.myLikes[index]['title'],
                      authorAvatar: mineController.myLikes[index]['avatarUrl'],
                      authorName: mineController.myLikes[index]['nickname'],
                      notesLikeNum: mineController.myLikes[index]
                          ['notesLikeNum'],
                      notesType: mineController.myLikes[index]['notesType'],
                      isLike: mineController.myLikes[index]['isLike'],
                    );
                  },
                  staggeredTileBuilder: (int index) =>
                      const StaggeredTile.fit(1),
                ),
              ),
            ),
          ]),
    );
  }
}
