import 'dart:convert';

import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:xiaofanshu_flutter/apis/app.dart';
import 'package:xiaofanshu_flutter/model/notes.dart';
import 'package:xiaofanshu_flutter/model/response.dart';
import 'package:xiaofanshu_flutter/static/custom_code.dart';
import 'package:xiaofanshu_flutter/static/default_data.dart';

import '../model/user.dart';
import '../utils/store_util.dart';

class NoteDetailsImageController extends GetxController {
  var notes = DefaultData.notes.obs;
  var userInfo = DefaultData.user.obs;

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
    userInfo.value = User.fromJson(
        jsonDecode(await readData('userInfo') ?? jsonEncode(DefaultData.user)));
    userInfo.refresh();
  }
}
