import 'dart:convert';

import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:xiaofanshu_flutter/apis/app.dart';
import 'package:xiaofanshu_flutter/model/notes.dart';
import 'package:xiaofanshu_flutter/model/response.dart';
import 'package:xiaofanshu_flutter/static/custom_code.dart';
import 'package:xiaofanshu_flutter/static/default_data.dart';

import '../model/user.dart';
import '../utils/comment_util.dart';
import '../utils/store_util.dart';

class NoteDetailsImageController extends GetxController {
  var notes = DefaultData.notes.obs;
  var userInfo = DefaultData.user.obs;
  var swiperHeight = 200.0.obs;

  @override
  void onInit() async {
    // TODO: implement onInit
    super.onInit();
    var notesId = Get.arguments as int;
    Get.log('controller init: $notesId');
    HttpResponse httpResponse = await NoteApi.getNotesDetail(notesId);
    if (httpResponse.code == StatusCode.getSuccess) {
      notes.value = Notes.fromJson(httpResponse.data);
      notes.refresh();
    }
    Size size = await getImageDimensions(notes.value.notesResources[0].url);
    setSwiperHeight(size.height, size.width);
    userInfo.value = User.fromJson(
        jsonDecode(await readData('userInfo') ?? jsonEncode(DefaultData.user)));
    userInfo.refresh();
  }

  setSwiperHeight(double imageHeight, double imageWidth) {
    var itemHeight = 0.0;
    var itemWidth = 0.0;
    if (imageWidth >= imageHeight) {
      itemWidth = 750;
      itemHeight = 750 * imageHeight / imageWidth;
    } else {
      if (imageHeight > 1000) {
        itemHeight = 1000;
        itemWidth = 1000 * imageWidth / imageHeight;
        if (itemWidth > 750) {
          itemWidth = 750;
          itemHeight = 750 * imageHeight / imageWidth;
        }
      } else {
        if (imageWidth > 750) {
          itemWidth = 750;
          itemHeight = 750 * imageHeight / imageWidth;
        } else {
          itemWidth = imageWidth;
          itemHeight = imageHeight;
        }
      }
    }
    if (itemHeight > swiperHeight.value) {
      swiperHeight.value = itemHeight;
    }
  }
}
