import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart' as dio;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:xiaofanshu_flutter/mapper/draft_notes_mapper.dart';
import 'package:xiaofanshu_flutter/model/draft_notes.dart';
import 'package:xiaofanshu_flutter/model/response.dart';
import 'package:xiaofanshu_flutter/utils/comment_util.dart';
import 'package:xiaofanshu_flutter/utils/loading_util.dart';
import 'package:xiaofanshu_flutter/utils/snackbar_util.dart';
import '../apis/app.dart';
import '../model/user.dart';
import '../static/custom_code.dart';
import '../static/default_data.dart';
import '../utils/store_util.dart';

class PublishNotesController extends GetxController {
  var isShowAtUser = false.obs;
  var isShowEmoji = false.obs;
  var attentionPage = 1.obs;
  var attentionPageSize = 10.obs;
  var attentionIsLoadMore = false.obs;
  var attentionHasMore = true.obs;
  var attentionList = List.empty().obs;

  // 0为图文，1为视频
  var type = 0.obs;

  // 仅在type为0时使用
  var files = List<File>.empty().obs;

  // 仅在type为1时使用
  Rx<File> video = File('').obs;
  Rx<File> cover = File('').obs;
  var selectedLocationName = ''.obs;
  var longitude = 0.0.obs;
  var latitude = 0.0.obs;
  var authority = 0.obs;
  var userInfo = DefaultData.user.obs;
  var isDraft = false.obs;
  var draftId = 0;
  TextEditingController titleController = TextEditingController();
  TextEditingController contentController = TextEditingController();
  ScrollController attentionScrollController = ScrollController();

  @override
  Future<void> onInit() async {
    // TODO: implement onInit
    super.onInit();
    Map<String, dynamic> args = Get.arguments;
    Get.log(args.toString());
    // 先判断是否含有 draft 参数，如果有则说明是草稿
    if (args.containsKey('draft')) {
      args['draft'] == true ? isDraft.value = true : isDraft.value = false;
      if (isDraft.value) {
        draftId = args['id'];
        DraftNotesMapper.queryById(args['id']).then((value) {
          if (value != null) {
            titleController.text = value.title!;
            contentController.text = value.content!;
            type.value = value.type;
            if (type.value == 0) {
              List<String> filesPath = value.filesPath.split(',');
              for (var item in filesPath) {
                files.add(File(item));
              }
            } else {
              video.value = File(value.filesPath.split(',')[0]);
              cover.value = File(value.coverPath!);
            }
            selectedLocationName.value = value.address!;
            authority.value = value.authority;
          }
        });
      }
    } else {
      type.value = args['type'];
      if (type.value == 0) {
        files.value = args['files'];
      } else if (type.value == 1) {
        video.value = args['video'];
        cover.value = args['cover'];
      }
    }
    userInfo.value = User.fromJson(
        jsonDecode(await readData('userInfo') ?? jsonEncode(DefaultData.user)));
    userInfo.refresh();
    String location = await getLocation();
    Get.log('位置信息：$location');
    List<String> locationList = location.split(',');
    longitude.value = double.parse(locationList[1]);
    latitude.value = double.parse(locationList[0]);
    loadAttentionList();
    attentionScrollController.addListener(() {
      if (attentionScrollController.offset ==
          attentionScrollController.position.maxScrollExtent) {
        loadAttentionList();
      }
    });
    titleController.addListener(() {
      // 禁止输入换行
      if (titleController.text.contains('\n')) {
        titleController.text = titleController.text.replaceAll('\n', '');
        titleController.selection = TextSelection.fromPosition(
            TextPosition(offset: titleController.text.length));
      }
    });
    contentController.addListener(() {
      // 不能连续输入3个换行
      if (contentController.text.contains('\n\n\n')) {
        contentController.text =
            contentController.text.replaceAll('\n\n\n', '\n\n');
        contentController.selection = TextSelection.fromPosition(
            TextPosition(offset: contentController.text.length));
      }
    });
  }

  void loadAttentionList() {
    if (attentionIsLoadMore.value) {
      return;
    }
    attentionIsLoadMore.value = true;
    if (!attentionHasMore.value) {
      attentionIsLoadMore.value = false;
      return;
    }
    UserApi.getAttentionList(
            userInfo.value.id, attentionPage.value, attentionPageSize.value)
        .then((value) {
      if (value.code == StatusCode.getSuccess) {
        for (var item in value.data) {
          attentionList.add(item);
        }
        attentionPage.value++;
        if (value.data.length < attentionPageSize.value) {
          attentionHasMore.value = false;
        }
      }
    }).whenComplete(() {
      attentionIsLoadMore.value = false;
    });
  }

  Future<void> publish() async {
    if (titleController.text.isEmpty) {
      SnackbarUtil.showError('请输入标题');
      return;
    }
    if (contentController.text.isEmpty) {
      SnackbarUtil.showError('请输入内容');
      return;
    }
    if (type.value == 0 && files.isEmpty) {
      SnackbarUtil.showError('请上传图片');
      return;
    }
    if (type.value == 1 && video.value.path.isEmpty) {
      SnackbarUtil.showError('请上传视频');
      return;
    }
    if (type.value == 1 && cover.value.path.isEmpty) {
      SnackbarUtil.showError('请上传封面');
      return;
    }
    LoadingUtil.show();
    try {
      List<String> filesPath = [];
      String coverPath = '';
      // 上传资源
      if (type.value == 0) {
        for (var element in files) {
          File file = File(element.path);
          dio.FormData formData = dio.FormData.fromMap({
            'file': await dio.MultipartFile.fromFile(
              file.path,
              filename: file.path.split('/').last,
            ),
          });
          HttpResponse httpResponse = await ThirdApi.uploadImage(formData);
          if (httpResponse.code == StatusCode.postSuccess) {
            filesPath.add(httpResponse.data);
          }
        }
      } else {
        File file = File(video.value.path);
        dio.FormData formData = dio.FormData.fromMap({
          'file': await dio.MultipartFile.fromFile(
            file.path,
            filename: file.path.split('/').last,
          ),
        });
        HttpResponse httpResponse = await ThirdApi.uploadVideo(formData);
        if (httpResponse.code == StatusCode.postSuccess) {
          filesPath.add(httpResponse.data);
        }
        File coverFile = File(cover.value.path);
        dio.FormData coverFormData = dio.FormData.fromMap({
          'file': await dio.MultipartFile.fromFile(
            coverFile.path,
            filename: coverFile.path.split('/').last,
          ),
        });
        HttpResponse coverHttpResponse =
            await ThirdApi.uploadImage(coverFormData);
        if (coverHttpResponse.code == StatusCode.postSuccess) {
          coverPath = coverHttpResponse.data;
        }
      }
      LoadingUtil.hide();
      LoadingUtil.show();
      String jsonResource = jsonEncode(filesPath);
      Map<String, dynamic> data = {
        'title': titleController.text,
        'content': contentController.text,
        'realContent': contentController.text,
        'belongUserId': userInfo.value.id,
        'notesType': type.value,
        'coverPicture': type.value == 0 ? '' : coverPath,
        'notesResources': jsonResource,
        'address': selectedLocationName.value,
        'longitude': longitude.value,
        'latitude': latitude.value,
        'authority': authority.value,
      };
      NoteApi.publishNotes(data).then((value) {
        LoadingUtil.hide();
        if (value.code == StatusCode.postSuccess) {
          Get.back();
        }
      });
    } catch (e) {
      LoadingUtil.hide();
      SnackbarUtil.showError('上传失败');
    }
  }

  Future<void> saveDraft() async {
    LoadingUtil.show();
    // 将 files 列表转换为逗号分隔的字符串
    String filesPathString = type.value == 0
        ? files.map((e) => e.path).join(',')
        : [video.value.path, cover.value.path].join(',');
// 创建 DraftNotes 实例
    DraftNotes draftNotes = DraftNotes(
      title: titleController.text,
      content: contentController.text,
      type: type.value,
      // 确保这是整数
      filesPath: filesPathString,
      // 转换为字符串
      coverPath: type.value == 0 ? '' : cover.value.path,
      authority: authority.value,
      // 确保这是整数
      address: selectedLocationName.value,
    );
    if (isDraft.value) {
      await DraftNotesMapper.delete(draftId);
    }
    var i = await DraftNotesMapper.insert(draftNotes);
    LoadingUtil.hide();
    if (i > 0) {
      SnackbarUtil.showSuccess('保存成功');
    } else {
      SnackbarUtil.showError('保存失败');
    }
    Get.back();
  }
}
