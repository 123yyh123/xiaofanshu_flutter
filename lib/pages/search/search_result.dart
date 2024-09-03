import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get/get.dart';
import 'package:xiaofanshu_flutter/controller/search_result_controller.dart';
import 'package:xiaofanshu_flutter/utils/snackbar_util.dart';

import '../../components/item.dart';
import '../../static/custom_color.dart';

class SearchResultPage extends StatefulWidget {
  const SearchResultPage({super.key});

  @override
  State<SearchResultPage> createState() => _SearchResultPageState();
}

class _SearchResultPageState extends State<SearchResultPage>
    with SingleTickerProviderStateMixin {
  SearchResultController searchResultController = Get.find();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    searchResultController.tabController =
        TabController(length: 2, vsync: this, initialIndex: 0);
    searchResultController.tabController.addListener(() {
      if (searchResultController.tabController.indexIsChanging) {
        return;
      }
      Get.log('tabIndex: ${searchResultController.tabController.index}');
      if (searchResultController.tabController.index !=
          searchResultController.tabIndex.value) {
        searchResultController.tabIndex.value =
            searchResultController.tabController.index;
        searchResultController.onTabChange();
      } else {
        searchResultController.tabIndex.value =
            searchResultController.tabController.index;
      }
    });
  }

  @override
  void dispose() {
    searchResultController.tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: GestureDetector(
          onTap: () {
            Get.back();
          },
          child: const Icon(
            Icons.arrow_back_ios,
            color: Colors.black,
            size: 25,
          ).marginOnly(left: 10),
        ),
        leadingWidth: 28,
        title: Row(
          children: [
            Expanded(
              child: Container(
                height: 35,
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(18),
                ),
                alignment: Alignment.center,
                child: TextField(
                  onTap: () {
                    Get.toNamed('/search');
                  },
                  readOnly: true,
                  maxLines: 1,
                  minLines: 1,
                  maxLength: 15,
                  controller: TextEditingController(
                      text: searchResultController.keyword),
                  cursorColor: CustomColor.primaryColor,
                  decoration: const InputDecoration(
                    counterText: '',
                    prefixIcon: Icon(
                      Icons.search,
                      color: Color(0xFFB3B3B3),
                    ),
                    contentPadding: EdgeInsets.all(0),
                    border: InputBorder.none, // 移除默认边框
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Row(
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width / 2,
                child: TabBar(
                  controller: searchResultController.tabController,
                  tabs: const [
                    Tab(text: '笔记'),
                    Tab(text: '用户'),
                  ],
                  labelColor: CustomColor.primaryColor,
                  unselectedLabelColor: Colors.black,
                  indicatorColor: CustomColor.primaryColor,
                  indicatorSize: TabBarIndicatorSize.label,
                ),
              ),
              Obx(
                () => searchResultController.tabIndex.value == 0
                    ? SizedBox(
                        width: MediaQuery.of(context).size.width / 2,
                        child: GestureDetector(
                            onTap: () {
                              Get.defaultDialog(
                                backgroundColor: Colors.white,
                                title: '筛选',
                                titleStyle: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 16,
                                ),
                                content: Obx(
                                  () => Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        '笔记类型',
                                        style: TextStyle(
                                          color: Color(0xFFB3B3B3),
                                          fontSize: 16,
                                        ),
                                      ).paddingOnly(bottom: 10),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: GestureDetector(
                                              onTap: () {
                                                searchResultController
                                                    .notesType.value = 2;
                                                searchResultController
                                                    .onNotesRefresh();
                                                Get.back();
                                              },
                                              child: Container(
                                                height: 40,
                                                alignment: Alignment.center,
                                                decoration: BoxDecoration(
                                                  color: searchResultController
                                                              .notesType
                                                              .value ==
                                                          2
                                                      ? CustomColor.primaryColor
                                                      : Colors.white,
                                                  border: Border.all(
                                                    color: CustomColor
                                                        .primaryColor,
                                                    width: 0.5,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                                child: Text(
                                                  '全部',
                                                  style: TextStyle(
                                                    color:
                                                        searchResultController
                                                                    .notesType
                                                                    .value ==
                                                                2
                                                            ? Colors.white
                                                            : CustomColor
                                                                .primaryColor,
                                                    fontSize: 14,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: GestureDetector(
                                              onTap: () {
                                                searchResultController
                                                    .notesType.value = 0;
                                                searchResultController
                                                    .onNotesRefresh();
                                                Get.back();
                                              },
                                              child: Container(
                                                height: 40,
                                                alignment: Alignment.center,
                                                decoration: BoxDecoration(
                                                  color: searchResultController
                                                              .notesType
                                                              .value ==
                                                          0
                                                      ? CustomColor.primaryColor
                                                      : Colors.white,
                                                  border: Border.all(
                                                    color: CustomColor
                                                        .primaryColor,
                                                    width: 0.5,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                                child: Text(
                                                  '图片笔记',
                                                  style: TextStyle(
                                                    color:
                                                        searchResultController
                                                                    .notesType
                                                                    .value ==
                                                                0
                                                            ? Colors.white
                                                            : CustomColor
                                                                .primaryColor,
                                                    fontSize: 14,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: GestureDetector(
                                              onTap: () {
                                                searchResultController
                                                    .notesType.value = 1;
                                                searchResultController
                                                    .onNotesRefresh();
                                                Get.back();
                                              },
                                              child: Container(
                                                height: 40,
                                                alignment: Alignment.center,
                                                decoration: BoxDecoration(
                                                  color: searchResultController
                                                              .notesType
                                                              .value ==
                                                          1
                                                      ? CustomColor.primaryColor
                                                      : Colors.white,
                                                  border: Border.all(
                                                    color: CustomColor
                                                        .primaryColor,
                                                    width: 0.5,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                                child: Text(
                                                  '视频笔记',
                                                  style: TextStyle(
                                                    color:
                                                        searchResultController
                                                                    .notesType
                                                                    .value ==
                                                                1
                                                            ? Colors.white
                                                            : CustomColor
                                                                .primaryColor,
                                                    fontSize: 14,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 10),
                                      const Text(
                                        '热门排序',
                                        style: TextStyle(
                                          color: Color(0xFFB3B3B3),
                                          fontSize: 16,
                                        ),
                                      ).paddingOnly(bottom: 10),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: GestureDetector(
                                              onTap: () {
                                                searchResultController
                                                    .hotType.value = 2;
                                                searchResultController
                                                    .onNotesRefresh();
                                                Get.back();
                                              },
                                              child: Container(
                                                height: 40,
                                                alignment: Alignment.center,
                                                decoration: BoxDecoration(
                                                  color: searchResultController
                                                              .hotType.value ==
                                                          2
                                                      ? CustomColor.primaryColor
                                                      : Colors.white,
                                                  border: Border.all(
                                                    color: CustomColor
                                                        .primaryColor,
                                                    width: 0.5,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                                child: Text(
                                                  '全部',
                                                  style: TextStyle(
                                                    color:
                                                        searchResultController
                                                                    .hotType
                                                                    .value ==
                                                                2
                                                            ? Colors.white
                                                            : CustomColor
                                                                .primaryColor,
                                                    fontSize: 14,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: GestureDetector(
                                              onTap: () {
                                                searchResultController
                                                    .hotType.value = 0;
                                                searchResultController
                                                    .onNotesRefresh();
                                                Get.back();
                                              },
                                              child: Container(
                                                height: 40,
                                                alignment: Alignment.center,
                                                decoration: BoxDecoration(
                                                  color: searchResultController
                                                              .hotType.value ==
                                                          0
                                                      ? CustomColor.primaryColor
                                                      : Colors.white,
                                                  border: Border.all(
                                                    color: CustomColor
                                                        .primaryColor,
                                                    width: 0.5,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                                child: Text(
                                                  '最新',
                                                  style: TextStyle(
                                                    color:
                                                        searchResultController
                                                                    .hotType
                                                                    .value ==
                                                                0
                                                            ? Colors.white
                                                            : CustomColor
                                                                .primaryColor,
                                                    fontSize: 14,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: GestureDetector(
                                              onTap: () {
                                                searchResultController
                                                    .hotType.value = 1;
                                                searchResultController
                                                    .onNotesRefresh();
                                                Get.back();
                                              },
                                              child: Container(
                                                height: 40,
                                                alignment: Alignment.center,
                                                decoration: BoxDecoration(
                                                  color: searchResultController
                                                              .hotType.value ==
                                                          1
                                                      ? CustomColor.primaryColor
                                                      : Colors.white,
                                                  border: Border.all(
                                                    color: CustomColor
                                                        .primaryColor,
                                                    width: 0.5,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                                child: Text(
                                                  '最热',
                                                  style: TextStyle(
                                                    color:
                                                        searchResultController
                                                                    .hotType
                                                                    .value ==
                                                                1
                                                            ? Colors.white
                                                            : CustomColor
                                                                .primaryColor,
                                                    fontSize: 14,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ).paddingOnly(left: 10, right: 10),
                                ),
                              );
                            },
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text(
                                  '筛选',
                                  style: TextStyle(
                                    color: Color(0xFFB3B3B3),
                                    fontSize: 16,
                                  ),
                                ),
                                SizedBox(width: 5),
                                Icon(
                                  Icons.filter_list,
                                  size: 18,
                                  color: Color(0xFFB3B3B3),
                                ),
                              ],
                            ).paddingOnly(right: 10)),
                      )
                    : const SizedBox(),
              ),
            ],
          ),
          _buildTabBarView(),
        ],
      ),
    );
  }

  Widget _buildTabBarView() {
    return Expanded(
      child: TabBarView(
        controller: searchResultController.tabController,
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          Scaffold(
            backgroundColor: Colors.white,
            body: RefreshIndicator(
              onRefresh: () async {
                searchResultController.onNotesRefresh();
              },
              color: CustomColor.primaryColor,
              child: Obx(
                () => StaggeredGridView.countBuilder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  controller: searchResultController.notesScrollController,
                  crossAxisCount: 2,
                  itemCount: searchResultController.notesList.length,
                  mainAxisSpacing: 6,
                  crossAxisSpacing: 8,
                  padding: const EdgeInsets.all(10),
                  itemBuilder: (BuildContext context, int index) {
                    return ItemView(
                      id: searchResultController.notesList[index]['id'],
                      authorId: searchResultController.notesList[index]
                          ['belongUserId'],
                      coverPicture: searchResultController.notesList[index]
                          ['coverPicture'],
                      noteTitle: searchResultController.notesList[index]
                          ['title'],
                      authorAvatar: searchResultController.notesList[index]
                          ['avatarUrl'],
                      authorName: searchResultController.notesList[index]
                          ['nickname'],
                      notesLikeNum: searchResultController.notesList[index]
                          ['notesLikeNum'],
                      notesType: searchResultController.notesList[index]
                          ['notesType'],
                      isLike: searchResultController.notesList[index]['isLike'],
                    );
                  },
                  staggeredTileBuilder: (int index) =>
                      const StaggeredTile.fit(1),
                ),
              ),
            ),
          ),
          Scaffold(
            backgroundColor: Colors.white,
            body: RefreshIndicator(
              onRefresh: () async {
                searchResultController.onUserRefresh();
              },
              color: CustomColor.primaryColor,
              child: Obx(
                () => searchResultController.userList.isEmpty
                    ? const Center(
                        child: Text(
                          '暂无数据',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 16,
                          ),
                        ),
                      )
                    : ListView.builder(
                        physics: const AlwaysScrollableScrollPhysics(),
                        controller: searchResultController.userScrollController,
                        itemCount: searchResultController.userList.length,
                        itemBuilder: (BuildContext context, int index) {
                          return GestureDetector(
                            onTap: () {
                              Get.toNamed(
                                "/other/mine",
                                arguments: searchResultController
                                    .userList[index]['id'],
                              );
                            },
                            child: Row(
                              children: [
                                Container(
                                  width: 45,
                                  height: 45,
                                  margin: const EdgeInsets.only(
                                      left: 10, right: 10),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(30),
                                    image: DecorationImage(
                                      image: NetworkImage(
                                        searchResultController.userList[index]
                                            ['avatarUrl'],
                                      ),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        searchResultController.userList[index]
                                            ['nickname'],
                                        style: const TextStyle(
                                          color: Colors.black,
                                          fontSize: 16,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Text(
                                        "小番薯号：${searchResultController.userList[index]['uid']}",
                                        style: const TextStyle(
                                          color: Colors.grey,
                                          fontSize: 14,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ).paddingOnly(top: 10, bottom: 10),
                          );
                        },
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
