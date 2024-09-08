import 'package:city_pickers/city_pickers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lifecycle_lite/lifecycle_mixin.dart';
import 'package:xiaofanshu_flutter/controller/edit_info_controller.dart';
import 'package:xiaofanshu_flutter/static/custom_color.dart';
import 'package:xiaofanshu_flutter/utils/Adapt.dart';
import 'package:xiaofanshu_flutter/utils/snackbar_util.dart';

class EditInformationPage extends StatefulWidget {
  const EditInformationPage({super.key});

  @override
  State<EditInformationPage> createState() => _EditInformationPageState();
}

class _EditInformationPageState extends State<EditInformationPage>
    with LifecycleStatefulMixin {
  EditInfoController editInfoController = Get.find();

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
        title: const Text('编辑资料',
            style: TextStyle(color: Colors.black, fontSize: 16)),
        centerTitle: true,
      ),
      body: Obx(
        () => SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.only(top: 20, bottom: 20),
                child: Stack(
                  children: [
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        Get.toNamed(
                          '/image/preview',
                          arguments:
                              editInfoController.userInfo.value.avatarUrl,
                        );
                      },
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(50),
                          image: DecorationImage(
                            image: NetworkImage(
                                editInfoController.userInfo.value.avatarUrl),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        width: 26,
                        height: 26,
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: const Icon(
                          Icons.camera_alt_outlined,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                children: [
                  GestureDetector(
                    onTap: () {
                      Get.defaultDialog(
                        title: '修改昵称',
                        titleStyle: const TextStyle(
                            color: Color(0xff2b2b2b),
                            fontSize: 16,
                            fontWeight: FontWeight.w500),
                        backgroundColor: Colors.white,
                        content: Container(
                          padding: const EdgeInsets.only(left: 10, right: 10),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: const Color(0xffF5F5F5),
                          ),
                          child: TextField(
                            cursorColor: CustomColor.primaryColor,
                            controller: editInfoController.nameController
                              ..text =
                                  editInfoController.userInfo.value.nickname,
                            maxLength: 12,
                            decoration: const InputDecoration(
                              hintText: '请输入昵称',
                              counterText: '',
                              hintStyle: TextStyle(
                                  color: Color(0xff999999), fontSize: 16),
                              border: InputBorder.none,
                            ),
                          ),
                        ).paddingAll(10),
                        cancel: GestureDetector(
                          onTap: () {
                            Get.back();
                          },
                          child: Container(
                            padding: const EdgeInsets.only(
                                left: 20, right: 20, top: 5, bottom: 5),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: const Color(0xffF5F5F5),
                            ),
                            child: const Text('取消',
                                style: TextStyle(
                                    color: Color(0xff666666),
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500)),
                          ),
                        ),
                        confirm: GestureDetector(
                          onTap: () {
                            Get.back();
                            editInfoController.updateNickname();
                          },
                          child: Container(
                            padding: const EdgeInsets.only(
                                left: 20, right: 20, top: 5, bottom: 5),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: CustomColor.primaryColor,
                            ),
                            child: const Text('确定',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500)),
                          ),
                        ),
                        onCancel: () {},
                        textConfirm: '确定',
                        textCancel: '取消',
                        onConfirm: () {},
                      );
                    },
                    behavior: HitTestBehavior.opaque,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('昵称',
                            style: TextStyle(
                                color: Color(0xFF666666),
                                fontSize: 16,
                                fontWeight: FontWeight.w500)),
                        Expanded(
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                        editInfoController
                                            .userInfo.value.nickname,
                                        style: const TextStyle(
                                          color: Color(0xff2b2b2b),
                                          fontSize: 16,
                                        )),
                                  ],
                                ),
                              ),
                              const Icon(
                                Icons.arrow_forward_ios,
                                color: Color(0xff666666),
                                size: 16,
                              ).marginOnly(left: 5)
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                  const Divider(
                    height: 1,
                    color: Color(0xFFE5E5E5),
                  ).paddingOnly(top: 10, bottom: 10),
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      SnackbarUtil.showInfo("小番薯号暂时不可修改");
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('小番薯号',
                            style: TextStyle(
                                color: Color(0xFF666666),
                                fontSize: 16,
                                fontWeight: FontWeight.w500)),
                        Row(
                          children: [
                            Text(editInfoController.userInfo.value.uid,
                                style: const TextStyle(
                                  color: Color(0xff2b2b2b),
                                  fontSize: 16,
                                )),
                            const Icon(
                              Icons.arrow_forward_ios,
                              color: Color(0xff666666),
                              size: 16,
                            ).marginOnly(left: 5)
                          ],
                        )
                      ],
                    ),
                  ),
                  const Divider(
                    height: 1,
                    color: Color(0xFFE5E5E5),
                  ).paddingOnly(top: 10, bottom: 10),
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      Get.defaultDialog(
                        title: '修改简介',
                        titleStyle: const TextStyle(
                            color: Color(0xff2b2b2b),
                            fontSize: 16,
                            fontWeight: FontWeight.w500),
                        backgroundColor: Colors.white,
                        content: Container(
                          padding: const EdgeInsets.only(left: 10, right: 10),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: const Color(0xffF5F5F5),
                          ),
                          child: TextField(
                            cursorColor: CustomColor.primaryColor,
                            controller: editInfoController.selfIntroController
                              ..text = editInfoController
                                  .userInfo.value.selfIntroduction,
                            maxLength: 100,
                            maxLines: 3,
                            minLines: 1,
                            decoration: const InputDecoration(
                              hintText: '请输入简介',
                              counterText: '',
                              hintStyle: TextStyle(
                                  color: Color(0xff999999), fontSize: 16),
                              border: InputBorder.none,
                            ),
                          ),
                        ).paddingAll(10),
                        cancel: GestureDetector(
                          onTap: () {
                            Get.back();
                          },
                          child: Container(
                            padding: const EdgeInsets.only(
                                left: 20, right: 20, top: 5, bottom: 5),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: const Color(0xffF5F5F5),
                            ),
                            child: const Text('取消',
                                style: TextStyle(
                                    color: Color(0xff666666),
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500)),
                          ),
                        ),
                        confirm: GestureDetector(
                          onTap: () {
                            Get.back();
                            editInfoController.updateSelfIntroduction();
                          },
                          child: Container(
                            padding: const EdgeInsets.only(
                                left: 20, right: 20, top: 5, bottom: 5),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: CustomColor.primaryColor,
                            ),
                            child: const Text('确定',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500)),
                          ),
                        ),
                        onCancel: () {},
                        textConfirm: '确定',
                        textCancel: '取消',
                        onConfirm: () {},
                      );
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('简介',
                            style: TextStyle(
                                color: Color(0xFF666666),
                                fontSize: 16,
                                fontWeight: FontWeight.w500)),
                        Expanded(
                          flex: 1,
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      editInfoController
                                          .userInfo.value.selfIntroduction,
                                      style: const TextStyle(
                                        color: Color(0xff2b2b2b),
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(
                                Icons.arrow_forward_ios,
                                color: Color(0xff666666),
                                size: 16,
                              ).marginOnly(left: 5)
                            ],
                          ).paddingOnly(left: 10),
                        )
                      ],
                    ),
                  ),
                  const Divider(
                    height: 1,
                    color: Color(0xFFE5E5E5),
                  ).paddingOnly(top: 10, bottom: 10),
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      editInfoController.readySex.value =
                          editInfoController.userInfo.value.sex;
                      Get.defaultDialog(
                        title: '修改性别',
                        titleStyle: const TextStyle(
                            color: Color(0xff2b2b2b),
                            fontSize: 16,
                            fontWeight: FontWeight.w500),
                        backgroundColor: Colors.white,
                        content: Container(
                          padding: const EdgeInsets.only(left: 10, right: 10),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: const Color(0xffF5F5F5),
                          ),
                          child: Obx(
                            () => Column(
                              children: [
                                Row(
                                  children: [
                                    Radio<int>(
                                      value: 1,
                                      groupValue:
                                          editInfoController.readySex.value,
                                      onChanged: (value) {
                                        editInfoController.readySex.value =
                                            value!;
                                        // 1 男 0 女
                                      },
                                      activeColor: CustomColor.primaryColor,
                                    ),
                                    const Text('男',
                                        style: TextStyle(
                                            color: Color(0xff2b2b2b),
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500)),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Radio<int>(
                                      value: 0,
                                      groupValue:
                                          editInfoController.readySex.value,
                                      onChanged: (value) {
                                        Get.log(value.toString());
                                        editInfoController.readySex.value =
                                            value!;
                                      },
                                      activeColor: CustomColor.primaryColor,
                                    ),
                                    const Text('女',
                                        style: TextStyle(
                                            color: Color(0xff2b2b2b),
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ).paddingAll(10),
                        cancel: GestureDetector(
                          onTap: () {
                            Get.back();
                          },
                          child: Container(
                            padding: const EdgeInsets.only(
                                left: 20, right: 20, top: 5, bottom: 5),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: const Color(0xffF5F5F5),
                            ),
                            child: const Text('取消',
                                style: TextStyle(
                                    color: Color(0xff666666),
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500)),
                          ),
                        ),
                        confirm: GestureDetector(
                          onTap: () {
                            Get.back();
                            editInfoController.updateSex();
                          },
                          child: Container(
                            padding: const EdgeInsets.only(
                                left: 20, right: 20, top: 5, bottom: 5),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: CustomColor.primaryColor,
                            ),
                            child: const Text('确定',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500)),
                          ),
                        ),
                        onCancel: () {},
                        textConfirm: '确定',
                        textCancel: '取消',
                        onConfirm: () {},
                      );
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('性别',
                            style: TextStyle(
                                color: Color(0xFF666666),
                                fontSize: 16,
                                fontWeight: FontWeight.w500)),
                        Row(
                          children: [
                            Text(
                                editInfoController.userInfo.value.sex == 1
                                    ? '男'
                                    : '女',
                                style: const TextStyle(
                                  color: Color(0xff2b2b2b),
                                  fontSize: 16,
                                )),
                            const Icon(
                              Icons.arrow_forward_ios,
                              color: Color(0xff666666),
                              size: 16,
                            ).marginOnly(left: 5)
                          ],
                        ),
                      ],
                    ),
                  ),
                  const Divider(
                    height: 1,
                    color: Color(0xFFE5E5E5),
                  ).paddingOnly(top: 10, bottom: 10),
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      Get.defaultDialog(
                        title: '修改生日',
                        titleStyle: const TextStyle(
                            color: Color(0xff2b2b2b),
                            fontSize: 16,
                            fontWeight: FontWeight.w500),
                        backgroundColor: Colors.white,
                        content: Container(
                          padding: const EdgeInsets.only(left: 10, right: 10),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: const Color(0xffF5F5F5),
                          ),
                          child: Obx(
                            () => Column(
                              children: [
                                SizedBox(
                                  height: 200,
                                  width: Adapt.setRpx(600),
                                  child: CupertinoDatePicker(
                                    minimumDate: DateTime(1900),
                                    maximumDate: DateTime.now(),
                                    mode: CupertinoDatePickerMode.date,
                                    initialDateTime: DateTime.parse(
                                        editInfoController
                                            .userInfo.value.birthday),
                                    onDateTimeChanged: (DateTime value) {
                                      editInfoController.readyBirthday.value =
                                          value;
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ).paddingAll(10),
                        cancel: GestureDetector(
                          onTap: () {
                            Get.back();
                          },
                          child: Container(
                            padding: const EdgeInsets.only(
                                left: 20, right: 20, top: 5, bottom: 5),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: const Color(0xffF5F5F5),
                            ),
                            child: const Text('取消',
                                style: TextStyle(
                                    color: Color(0xff666666),
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500)),
                          ),
                        ),
                        confirm: GestureDetector(
                          onTap: () {
                            Get.back();
                            editInfoController.updateBirthday();
                          },
                          child: Container(
                            padding: const EdgeInsets.only(
                                left: 20, right: 20, top: 5, bottom: 5),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: CustomColor.primaryColor,
                            ),
                            child: const Text('确定',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500)),
                          ),
                        ),
                        onCancel: () {},
                        textConfirm: '确定',
                        textCancel: '取消',
                        onConfirm: () {},
                      );
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('生日',
                            style: TextStyle(
                                color: Color(0xFF666666),
                                fontSize: 16,
                                fontWeight: FontWeight.w500)),
                        Row(
                          children: [
                            Text(editInfoController.userInfo.value.birthday,
                                style: const TextStyle(
                                  color: Color(0xff2b2b2b),
                                  fontSize: 16,
                                )),
                            const Icon(
                              Icons.arrow_forward_ios,
                              color: Color(0xff666666),
                              size: 16,
                            ).marginOnly(left: 5)
                          ],
                        ),
                      ],
                    ),
                  ),
                  const Divider(
                    height: 1,
                    color: Color(0xFFE5E5E5),
                  ).paddingOnly(top: 10, bottom: 10),
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () async {
                      Result? picker = await CityPickers.showCityPicker(
                        context: context,
                        cancelWidget: const Text('取消',
                            style: TextStyle(
                                color: Color(0xff666666),
                                fontSize: 16,
                                fontWeight: FontWeight.w500)),
                        confirmWidget: const Text('确定',
                            style: TextStyle(
                                color: CustomColor.primaryColor,
                                fontSize: 16,
                                fontWeight: FontWeight.w500)),
                        height: 300,
                      );
                      if (picker != null) {
                        String area =
                            "${picker.provinceName!} ${picker.cityName!} ${picker.areaName!}";
                        editInfoController.updateArea(area);
                      }
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('地区',
                            style: TextStyle(
                                color: Color(0xFF666666),
                                fontSize: 16,
                                fontWeight: FontWeight.w500)),
                        Row(
                          children: [
                            Text(editInfoController.userInfo.value.area,
                                style: const TextStyle(
                                  color: Color(0xff2b2b2b),
                                  fontSize: 16,
                                )),
                            const Icon(
                              Icons.arrow_forward_ios,
                              color: Color(0xff666666),
                              size: 16,
                            ).marginOnly(left: 5)
                          ],
                        ),
                      ],
                    ),
                  ),
                  const Divider(
                    height: 1,
                    color: Color(0xFFE5E5E5),
                  ).paddingOnly(top: 10, bottom: 10),
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      Get.toNamed(
                        '/image/backgroundPreview',
                        arguments: editInfoController
                            .userInfo.value.homePageBackground,
                      );
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('背景图',
                            style: TextStyle(
                                color: Color(0xFF666666),
                                fontSize: 16,
                                fontWeight: FontWeight.w500)),
                        Row(
                          children: [
                            Container(
                              width: 90,
                              height: 60,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5),
                                image: DecorationImage(
                                  image: NetworkImage(editInfoController
                                      .userInfo.value.homePageBackground),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            const Icon(
                              Icons.arrow_forward_ios,
                              color: Color(0xff666666),
                              size: 16,
                            ).marginOnly(left: 5)
                          ],
                        ),
                      ],
                    ),
                  ),
                  const Divider(
                    height: 1,
                    color: Color(0xFFE5E5E5),
                  ).paddingOnly(top: 10, bottom: 10),
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      SnackbarUtil.showInfo('暂未开放');
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('二维码',
                            style: TextStyle(
                                color: Color(0xFF666666),
                                fontSize: 16,
                                fontWeight: FontWeight.w500)),
                        Row(
                          children: [
                            const Icon(
                              Icons.qr_code,
                              color: Color(0xff666666),
                              size: 20,
                            ),
                            const Icon(
                              Icons.arrow_forward_ios,
                              color: Color(0xff666666),
                              size: 16,
                            ).marginOnly(left: 5)
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ).paddingAll(20),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void whenHide() {}

  @override
  void whenShow() {
    editInfoController.refreshInfo();
  }
}
