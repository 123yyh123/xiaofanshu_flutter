import 'dart:convert';

import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:xiaofanshu_flutter/apis/app.dart';
import 'package:xiaofanshu_flutter/mapper/draft_notes_mapper.dart';
import 'package:xiaofanshu_flutter/model/response.dart';
import 'package:xiaofanshu_flutter/model/user.dart';
import 'package:xiaofanshu_flutter/static/custom_code.dart';
import 'package:xiaofanshu_flutter/static/custom_color.dart';
import 'package:xiaofanshu_flutter/static/default_data.dart';
import 'package:xiaofanshu_flutter/utils/db_util.dart';
import 'package:xiaofanshu_flutter/utils/snackbar_util.dart';
import 'package:xiaofanshu_flutter/utils/store_util.dart';

import '../static/custom_string.dart';

class MineController extends GetxController {
  var userInfo = DefaultData.user.obs;
  final ScrollController scrollController = ScrollController();
  var appBarOpacity = 0.0.obs;
  var tabs = ["笔记", "收藏", "赞过"];
  var tabsEn = ["notes", "collects", "likes"];

  // 0: 公开 1: 私密 2: 草稿
  var notesPublishType = 0.obs;

  // 0: 我的笔记 1: 我的收藏 2: 我的赞过
  var notesTabType = 0.obs;
  var myNotes = [].obs;
  var myCollects = [].obs;
  var myLikes = [].obs;
  var lastPressedAt = DateTime.now();
  var lastPressedInfo = '';
  var myNotesPage = 1;
  var myCollectsPage = 1;
  var myLikesPage = 1;
  var myNotesSize = 10;
  var myCollectsSize = 10;
  var myLikesSize = 10;
  var isNotesLoadMore = false;
  var isHasMyNotesMore = true;
  var isHasMyCollectsMore = true;
  var isHasMyLikesMore = true;
  var publishNotesNum = 0.obs;
  var privateNotesNum = 0.obs;
  var draftNotesNum = 0.obs;
  var notesCount = 0.obs;
  var praiseCount = 0.obs;
  var collectCount = 0.obs;
  var isShowTopAvatar = false.obs;

  @override
  void onInit() async {
    // TODO: implement onInit
    super.onInit();
    int userId = int.parse(jsonDecode(
            await readData('userInfo') ?? jsonEncode(DefaultData.user))['id']
        .toString());
    Get.log('userId: $userId');
    if (userId == 1) {
      userInfo.value = DefaultData.user;
    } else {
      HttpResponse httpResponse = await UserApi.getUserInfo(userId);
      if (httpResponse.code == StatusCode.getSuccess) {
        userInfo.value = User.fromJson(httpResponse.data);
        // 保存最新的用户信息
        await saveData('userInfo', jsonEncode(userInfo.value));
      } else {
        userInfo.value = DefaultData.user;
      }
    }
    userInfo.refresh();
    if (myNotes.isEmpty) {
      myNotesPage = 1;
      getNotesList(0, notesPublishType.value);
    }
    await DBManager.instance.createDraftNotesTable();
    NoteApi.getAllNotesCountAndPraiseCountAndCollectCount().then((res) {
      if (res.code == StatusCode.getSuccess) {
        notesCount.value = res.data['notesCount'];
        praiseCount.value = res.data['praiseCount'];
        collectCount.value = res.data['collectCount'];
      }
    });
    scrollController.addListener(() {
      // appBar透明度最大值为0.9
      double offset = scrollController.offset;
      Get.log('offset: $offset');
      double opacity = offset / 100;
      if (offset > 100) {
        isShowTopAvatar.value = true;
      } else {
        isShowTopAvatar.value = false;
      }
      appBarOpacity.value = opacity > 0.9 ? 0.9 : opacity;
      if (scrollController.position.pixels ==
          scrollController.position.maxScrollExtent) {
        onLoading();
      }
    });
  }

  Future<void> onRefresh() async {
    HttpResponse httpResponse = await UserApi.getUserInfo(userInfo.value.id);
    if (httpResponse.code == StatusCode.getSuccess) {
      userInfo.value = User.fromJson(httpResponse.data);
      // 保存最新的用户信息
      await saveData('userInfo', jsonEncode(userInfo.value));
    }
    userInfo.refresh();
    // 刷新笔记列表
    if (notesTabType.value == 0) {
      isHasMyNotesMore = true;
      myNotesPage = 1;
      myNotes.clear();
      getNotesList(0, notesPublishType.value);
    } else if (notesTabType.value == 1) {
      isHasMyCollectsMore = true;
      myCollectsPage = 1;
      myCollects.clear();
      getNotesList(1, 0);
    } else if (notesTabType.value == 2) {
      isHasMyLikesMore = true;
      myLikesPage = 1;
      myLikes.clear();
      getNotesList(2, 0);
    }
    NoteApi.getAllNotesCountAndPraiseCountAndCollectCount().then((res) {
      if (res.code == StatusCode.getSuccess) {
        notesCount.value = res.data['notesCount'];
        praiseCount.value = res.data['praiseCount'];
        collectCount.value = res.data['collectCount'];
      }
    });
  }

  bool judgeDoubleTap(String info) {
    if (DateTime.now().difference(lastPressedAt) <
        const Duration(milliseconds: 500)) {
      if (lastPressedInfo == info) {
        return true;
      }
    }
    lastPressedAt = DateTime.now();
    lastPressedInfo = info;
    return false;
  }

  void onTap(String info) {
    if (!judgeDoubleTap(info)) {
      switch (info) {
        case 'collects':
          if (myCollects.isEmpty) {
            isHasMyCollectsMore = true;
            myCollectsPage = 1;
            getNotesList(1, 0);
          }
          break;
        case 'likes':
          if (myLikes.isEmpty) {
            isHasMyLikesMore = true;
            myLikesPage = 1;
            getNotesList(2, 0);
          }
          break;
        case 'notes':
          if (myNotes.isEmpty) {
            isHasMyNotesMore = true;
            myNotesPage = 1;
            getNotesList(0, notesPublishType.value);
          }
          break;
        case 'publish':
        case 'private':
        case 'draft':
          isHasMyNotesMore = true;
          myNotesPage = 1;
          myNotes.clear();
          getNotesList(0, notesPublishType.value);
          break;
        default:
          break;
      }
    } else {
      switch (info) {
        case 'collects':
          isHasMyCollectsMore = true;
          myCollectsPage = 1;
          myCollects.clear();
          getNotesList(1, 0);
          break;
        case 'likes':
          isHasMyLikesMore = true;
          myLikesPage = 1;
          myLikes.clear();
          getNotesList(2, 0);
          break;
        case 'notes':
        case 'publish':
        case 'private':
          isHasMyNotesMore = true;
          myNotesPage = 1;
          myNotes.clear();
          getNotesList(0, notesPublishType.value);
          break;
        case 'draft':
          isHasMyNotesMore = true;
          myNotesPage = 1;
          myNotes.clear();
          getNotesList(0, 2);
          break;
        default:
          break;
      }
    }
  }

  void getNotesList(int notesTabType, int notesPublishType) {
    if (isNotesLoadMore) {
      return;
    }
    isNotesLoadMore = true;
    try {
      switch (notesTabType) {
        case 0:
          if (!isHasMyNotesMore) {
            return;
          }
          if (notesPublishType == 0 || notesPublishType == 1) {
            NoteApi.getMyNotes(notesPublishType, myNotesPage, myNotesSize)
                .then((res) {
              if (res.code == StatusCode.getSuccess) {
                if (res.data['list'].length < myNotesSize) {
                  isHasMyNotesMore = false;
                }
                myNotes.addAll(res.data['list']);
                myNotesPage++;
                if (notesPublishType == 0) {
                  publishNotesNum.value = res.data['total'];
                } else if (notesPublishType == 1) {
                  privateNotesNum.value = res.data['total'];
                }
              }
            });
          } else if (notesPublishType == 2) {
            DraftNotesMapper.queryAll().then((value) {
              draftNotesNum.value = value.length;
              myNotes.clear();
              myNotes.addAll(value);
              isHasMyNotesMore = false;
              myNotesPage++;
              for (var element in myNotes) {
                Get.log('element.filesPath: ${element.filesPath}');
                Get.log('element.coverPath: ${element.coverPath}');
              }
            });
          }
          break;
        case 1:
          if (!isHasMyCollectsMore) {
            return;
          }
          NoteApi.getMyCollects(myCollectsPage, myCollectsSize).then((res) {
            if (res.code == StatusCode.getSuccess) {
              if (res.data['list'].length < myCollectsSize) {
                isHasMyCollectsMore = false;
              }
              myCollects.addAll(res.data['list']);
              myCollectsPage++;
            }
          });
          break;
        case 2:
          if (!isHasMyLikesMore) {
            return;
          }
          NoteApi.getMyLikes(myLikesPage, myLikesSize).then((res) {
            if (res.code == StatusCode.getSuccess) {
              if (res.data['list'].length < myLikesSize) {
                isHasMyLikesMore = false;
              }
              myLikes.addAll(res.data['list']);
              myLikesPage++;
            }
          });
          break;
        default:
          break;
      }
    } catch (e) {
      SnackbarUtil.showError(ErrorString.networkError);
    } finally {
      isNotesLoadMore = false;
    }
  }

  void onLoading() {
    if (isNotesLoadMore) {
      return;
    }
    isNotesLoadMore = true;
    try {
      switch (notesTabType.value) {
        case 0:
          if (!isHasMyNotesMore) {
            return;
          }
          NoteApi.getMyNotes(notesPublishType.value, myNotesPage, myNotesSize)
              .then((res) {
            if (res.code == StatusCode.getSuccess) {
              if (res.data['list'].length < myNotesSize) {
                isHasMyNotesMore = false;
              }
              myNotes.addAll(res.data['list']);
              myNotesPage++;
            }
          });
          break;
        case 1:
          if (!isHasMyCollectsMore) {
            return;
          }
          NoteApi.getMyCollects(myCollectsPage, myCollectsSize).then((res) {
            if (res.code == StatusCode.getSuccess) {
              if (res.data['list'].length < myCollectsSize) {
                isHasMyCollectsMore = false;
              }
              myCollects.addAll(res.data['list']);
              myCollectsPage++;
            }
          });
          break;
        case 2:
          if (!isHasMyLikesMore) {
            return;
          }
          NoteApi.getMyLikes(myLikesPage, myLikesSize).then((res) {
            if (res.code == StatusCode.getSuccess) {
              if (res.data['list'].length < myLikesSize) {
                isHasMyLikesMore = false;
              }
              myLikes.addAll(res.data['list']);
              myLikesPage++;
            }
          });
          break;
        default:
          break;
      }
    } catch (e) {
      SnackbarUtil.showError(ErrorString.networkError);
    } finally {
      isNotesLoadMore = false;
    }
  }

  void onDeleteDraft(id) {
    Get.defaultDialog(
      title: '提示',
      titleStyle: const TextStyle(fontSize: 16, color: Colors.black),
      middleText: '确定删除这篇草稿吗？',
      textConfirm: '确定',
      textCancel: '取消',
      buttonColor: CustomColor.primaryColor,
      confirmTextColor: Colors.white,
      onCancel: () {
        Get.back();
      },
      onConfirm: () {
        DraftNotesMapper.delete(id).then((value) {
          if (value > 0) {
            SnackbarUtil.showSuccess('删除成功');
            draftNotesNum.value--;
            myNotes.removeWhere((element) => element.id == id);
          } else {
            SnackbarUtil.showError('删除失败');
          }
        });
        Get.back();
      },
    );
  }
}

class TabsType {
  // var tabsType = ['notes', 'collects', 'likes', 'publish', 'private', 'draft'];
  static const notes = 'notes';
  static const collects = 'collects';
  static const likes = 'likes';
  static const publish = 'publish';
  static const private = 'private';
  static const draft = 'draft';
}
