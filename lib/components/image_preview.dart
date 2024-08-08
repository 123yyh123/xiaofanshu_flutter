import 'dart:io';

import 'package:dio/dio.dart' as dio;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_pickers/image_pickers.dart';
import 'package:xiaofanshu_flutter/controller/mine_controller.dart';
import 'package:xiaofanshu_flutter/model/response.dart';

// import 'package:image_picker/image_picker.dart';
import 'package:xiaofanshu_flutter/static/custom_color.dart';
import 'package:xiaofanshu_flutter/utils/snackbar_util.dart';

import '../apis/app.dart';
import '../static/custom_code.dart';

class ImagePreview extends StatefulWidget {
  const ImagePreview({super.key});

  @override
  State<ImagePreview> createState() => _ImagePreviewState();
}

class _ImagePreviewState extends State<ImagePreview> {
  String imageUrl = '';
  MineController mineController = Get.find();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    imageUrl = Get.arguments as String;
    Get.log('ImagePreview imageUrl: $imageUrl');
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Get.back();
      },
      child: Container(
        color: Colors.black,
        width: double.infinity,
        height: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 头部
            IconButton(
              onPressed: () {
                Get.back();
              },
              icon: const Icon(
                Icons.close,
                color: CustomColor.unselectedColor,
                size: 30,
              ),
            ),
            // 圆形图片
            const SizedBox(height: 30),
            ClipOval(
              child: Image.network(
                imageUrl,
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.width - 40,
                fit: BoxFit.cover,
              ),
            ).paddingAll(10),
            // 间隔
            const SizedBox(height: 30),
            // 操作
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: const Color(0xff2b2b2b),
              ),
              child: Column(
                children: [
                  GestureDetector(
                    onTap: () async {
                      List<Media> listImagePaths =
                          await ImagePickers.pickerPaths(
                        galleryMode: GalleryMode.image,
                        selectCount: 1,
                        showCamera: true,
                      );
                      if (listImagePaths.isNotEmpty) {
                        for (var element in listImagePaths) {
                          Get.log(
                              'ImagePreview listImagePath: ${element.path}');
                          File file = File(element.path!);
                          dio.FormData formData = dio.FormData.fromMap({
                            'file': await dio.MultipartFile.fromFile(
                              file.path,
                              filename: file.path.split('/').last,
                            ),
                          });
                          HttpResponse httpResponse =
                              await ThirdApi.uploadImage(formData);
                          if (httpResponse.code == StatusCode.postSuccess) {
                            Get.log(
                                'ImagePreview uploadImage: ${httpResponse.data}');
                            UserApi.updateUserAvatar(
                              httpResponse.data,
                              mineController.userInfo.value.id,
                            ).then((value) {
                              if (value.code == StatusCode.postSuccess) {
                                Get.log(
                                    'ImagePreview updateUserAvatar success');
                                mineController.userInfo.value.avatarUrl =
                                    httpResponse.data;
                                mineController.userInfo.refresh();
                              } else {
                                SnackbarUtil.showError("上传失败");
                              }
                            });
                          } else {
                            SnackbarUtil.showError("上传失败");
                          }
                          Get.back();
                        }
                      }
                    },
                    behavior: HitTestBehavior.opaque,
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text("上传新头像",
                            style: TextStyle(color: Color(0xfffffffc))),
                        Icon(
                          Icons.broken_image_outlined,
                          color: CustomColor.unselectedColor,
                        ),
                      ],
                    ).paddingAll(10),
                  )
                ],
              ),
            ).paddingAll(20),
          ],
        ).paddingOnly(
          top: MediaQuery.of(context).padding.top,
          left: 10,
          right: 10,
          bottom: 10,
        ),
      ),
    );
  }
}
