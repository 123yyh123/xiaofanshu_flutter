import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:xiaofanshu_flutter/static/custom_color.dart';
import '../../controller/search_controller.dart' as search;

class Search extends StatefulWidget {
  const Search({super.key});

  @override
  State<Search> createState() => _SearchState();
}

class _SearchState extends State<Search> {
  search.SearchController searchController = Get.find();

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
              child: Obx(
                () => Container(
                  height: 35,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  alignment: Alignment.center,
                  child: TextField(
                    autofocus: true,
                    maxLines: 1,
                    minLines: 1,
                    maxLength: 15,
                    cursorColor: CustomColor.primaryColor,
                    controller: searchController.searchTextFieldController,
                    decoration: InputDecoration(
                      counterText: '',
                      hintText: '请输入搜索关键词',
                      hintStyle: const TextStyle(
                        color: Color(0xFFB3B3B3),
                        fontSize: 16,
                        height: 1,
                      ),
                      prefixIcon: const Icon(
                        Icons.search,
                        color: Color(0xFFB3B3B3),
                      ),
                      // 清除
                      suffixIcon: GestureDetector(
                        onTap: () {
                          searchController.searchTextFieldController.clear();
                        },
                        child: searchController.keyword.value.isNotEmpty
                            ? const Icon(
                                Icons.cancel,
                                size: 18,
                                color: Color(0xFFB3B3B3),
                              )
                            : const SizedBox(),
                      ),
                      contentPadding: const EdgeInsets.all(0),
                      border: InputBorder.none, // 移除默认边框
                    ),
                  ),
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                searchController.search();
              },
              child: const Text(
                '搜索',
                style: TextStyle(
                  color: Color(0xFFB3B3B3),
                  fontSize: 16,
                ),
              ).marginOnly(left: 8),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Obx(
              () => Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('搜索历史'),
                  searchController.isShowClearButton.value
                      ? Row(
                          children: [
                            GestureDetector(
                              onTap: () {
                                searchController.clearSearchHistory();
                              },
                              child: const Text(
                                '全部删除',
                                style: TextStyle(
                                    color: Color(0xFFB3B3B3), fontSize: 14),
                              ),
                            ),
                            const Text(
                              '|',
                              style: TextStyle(
                                  color: Color(0xFFB3B3B3), fontSize: 12),
                            ).marginOnly(left: 8, right: 8),
                            GestureDetector(
                              onTap: () {
                                searchController.isShowClearButton.value =
                                    false;
                              },
                              child: const Text(
                                '完成',
                                style: TextStyle(
                                    color: Color(0xFF2b2b2b), fontSize: 14),
                              ),
                            ),
                          ],
                        )
                      : GestureDetector(
                          onTap: () {
                            searchController.isShowClearButton.value = true;
                          },
                          child: const Icon(
                            Icons.delete_outline_rounded,
                            color: Color(0xFFB3B3B3),
                            size: 20,
                          ),
                        ),
                ],
              ).paddingOnly(left: 15, top: 8, bottom: 8, right: 15),
            ),
            Obx(
              () => Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  ...searchController.searchHistoryList.map((e) {
                    return GestureDetector(
                      onTap: () {
                        searchController.searchTextFieldController.text = e;
                        searchController.search();
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 15,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5F5F5),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              e,
                              style: const TextStyle(fontSize: 14),
                            ),
                            searchController.isShowClearButton.value
                                ? GestureDetector(
                                    onTap: () {
                                      searchController.deleteSearchHistory(e);
                                    },
                                    child: const Text(
                                      '✕',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Color(0xFFB3B3B3),
                                      ),
                                    ).marginOnly(left: 5),
                                  )
                                : const SizedBox(),
                          ],
                        ),
                      ),
                    );
                  }),
                ],
              ).paddingOnly(left: 15, right: 15),
            ),
            const SizedBox(height: 20),
            const Text('热门搜索').paddingOnly(left: 15),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: const [
                Text('热门搜索1'),
                Text('热门搜索2'),
                Text('热门搜索3'),
                Text('热门搜索4'),
                Text('热门搜索5'),
                Text('热门搜索6'),
                Text('热门搜索7'),
                Text('热门搜索8'),
                Text('热门搜索9'),
                Text('热门搜索10'),
              ].map((e) {
                return GestureDetector(
                  onTap: () {},
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F5F5),
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                );
              }).toList(),
            ).paddingOnly(left: 15, right: 15),
          ],
        ),
      ),
    );
  }
}
