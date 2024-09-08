import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:xiaofanshu_flutter/apis/app.dart';
import 'package:xiaofanshu_flutter/model/user.dart';
import 'package:xiaofanshu_flutter/static/custom_code.dart';
import 'package:xiaofanshu_flutter/static/default_data.dart';
import 'package:xiaofanshu_flutter/utils/snackbar_util.dart';

class EditInfoController extends GetxController {
  var userInfo = DefaultData.user.obs;
  TextEditingController nameController = TextEditingController();
  TextEditingController selfIntroController = TextEditingController();
  var readySex = 0.obs;
  var readyBirthday = DateTime.now().obs;

  @override
  Future<void> onInit() async {
    // TODO: implement onInit
    super.onInit();
    int userId = Get.arguments as int;
    var response = await UserApi.getUserInfo(userId);
    if (response.code == StatusCode.getSuccess) {
      userInfo.value = User.fromJson(response.data);
    } else {
      SnackbarUtil.showError(response.msg);
    }
  }

  Future<void> refreshInfo() async {
    if (userInfo.value.id == 1) {
      return;
    }
    var response = await UserApi.getUserInfo(userInfo.value.id);
    if (response.code == StatusCode.getSuccess) {
      userInfo.value = User.fromJson(response.data);
    } else {
      SnackbarUtil.showError(response.msg);
    }
  }

  void updateNickname() {
    if (nameController.text.isEmpty) {
      SnackbarUtil.showError('昵称不能为空');
      return;
    }
    if (nameController.text == userInfo.value.nickname) {
      SnackbarUtil.showError('昵称未发生变化');
      return;
    }
    if (nameController.text.length < 2 || nameController.text.length > 12) {
      SnackbarUtil.showError('昵称长度应在2-12个字符之间');
      return;
    }
    UserApi.updateUserNickname(nameController.text, userInfo.value.id)
        .then((response) {
      if (response.code == StatusCode.postSuccess) {
        userInfo.value.nickname = nameController.text;
        userInfo.refresh();
        SnackbarUtil.showSuccess('昵称修改成功');
      } else {
        SnackbarUtil.showError(response.msg);
      }
    });
  }

  void updateSelfIntroduction() {
    if (selfIntroController.text.isEmpty) {
      SnackbarUtil.showError('个人简介不能为空');
      return;
    }
    if (selfIntroController.text == userInfo.value.selfIntroduction) {
      SnackbarUtil.showError('个人简介未发生变化');
      return;
    }
    if (selfIntroController.text.length > 100) {
      SnackbarUtil.showError('自我介绍长度不能超过100个字符');
      return;
    }
    UserApi.updateUserIntroduction(selfIntroController.text, userInfo.value.id)
        .then((response) {
      if (response.code == StatusCode.postSuccess) {
        userInfo.value.selfIntroduction = selfIntroController.text;
        userInfo.refresh();
        SnackbarUtil.showSuccess('个人简介修改成功');
      } else {
        SnackbarUtil.showError(response.msg);
      }
    });
  }

  void updateSex() {
    if (readySex.value == userInfo.value.sex) {
      return;
    }
    UserApi.updateUserSex(readySex.value, userInfo.value.id).then((response) {
      if (response.code == StatusCode.postSuccess) {
        userInfo.value.sex = readySex.value;
        userInfo.refresh();
        SnackbarUtil.showSuccess('性别修改成功');
      } else {
        SnackbarUtil.showError(response.msg);
      }
    });
  }

  void updateBirthday() {
    if (readyBirthday.value == DateTime.parse(userInfo.value.birthday)) {
      return;
    }
    // 2021-09-01
    String birthday = readyBirthday.value.toString().substring(0, 10);
    Get.log(birthday);
    UserApi.updateUserBirthday(birthday, userInfo.value.id).then((response) {
      if (response.code == StatusCode.postSuccess) {
        userInfo.value.birthday = birthday;
        userInfo.refresh();
        SnackbarUtil.showSuccess('生日修改成功');
      } else {
        SnackbarUtil.showError(response.msg);
      }
    });
  }

  void updateArea(String area) {
    List<String> areaList = area.split(' ');
    if (areaList.length != 3) {
      SnackbarUtil.showError('请选择完整的地区');
      return;
    }
    String areaStr;
    String realArea;
    if (DefaultData.specialAreaList.contains(areaList[0])) {
      areaStr = '${areaList[0]} ${areaList[0]} ${areaList[2]}';
      realArea = '${areaList[0]} ${areaList[2]}';
    } else {
      areaStr = area;
      realArea = area;
    }
    if (realArea == userInfo.value.area) {
      return;
    }
    UserApi.updateUserArea(areaStr, userInfo.value.id).then((response) {
      if (response.code == StatusCode.postSuccess) {
        userInfo.value.area = realArea;
        userInfo.refresh();
        SnackbarUtil.showSuccess('地区修改成功');
      } else {
        SnackbarUtil.showError(response.msg);
      }
    });
  }
}
