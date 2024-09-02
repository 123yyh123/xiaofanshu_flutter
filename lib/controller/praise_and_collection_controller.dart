import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:xiaofanshu_flutter/mapper/praise_and_collection_mapper.dart';

class PraiseAndCollectionController extends GetxController {
  List<Map<String, dynamic>> list = List<Map<String, dynamic>>.empty().obs;
  var page = 1.obs;
  var pageSize = 10.obs;
  var isLoadMore = false.obs;
  var hasMore = true.obs;
  ScrollController scrollController = ScrollController();

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    _loadData();
    scrollController.addListener(() {
      if (scrollController.position.pixels ==
          scrollController.position.maxScrollExtent) {
        _loadData();
      }
    });
  }

  void _loadData() {
    if (!hasMore.value) {
      return;
    }
    if (isLoadMore.value) {
      return;
    }
    isLoadMore.value = true;
    PraiseAndCollectionMapper.queryPage(page.value, pageSize.value)
        .then((value) {
      if (value.length < pageSize.value) {
        hasMore.value = false;
      }
      list.addAll(value);
      page.value++;
      isLoadMore.value = false;
    });
  }

  void onRefresh() {
    page.value = 1;
    hasMore.value = true;
    list.clear();
    _loadData();
  }
}
