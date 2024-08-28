import 'dart:io';

import 'package:cached_video_player_plus/cached_video_player_plus.dart';
import 'package:dio/dio.dart' as dio;
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animated_progress_bar/flutter_animated_progress_bar.dart';
import 'package:get/get.dart';
import 'package:get/get_utils/get_utils.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:image_pickers/image_pickers.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:xiaofanshu_flutter/controller/mine_controller.dart';
import 'package:xiaofanshu_flutter/model/response.dart';

// import 'package:image_picker/image_picker.dart';
import 'package:xiaofanshu_flutter/static/custom_color.dart';
import 'package:xiaofanshu_flutter/utils/loading_util.dart';
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
    return Container(
      color: Colors.black,
      child: SingleChildScrollView(
        child: GestureDetector(
          onTap: () {
            Get.back();
          },
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
      ),
    );
  }
}

class SimpleImagePre extends StatefulWidget {
  const SimpleImagePre({super.key});

  @override
  State<SimpleImagePre> createState() => _SimpleImagePreState();
}

class _SimpleImagePreState extends State<SimpleImagePre> {
  late List<String> urls;
  int currentIndex = 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    urls = Get.arguments as List<String>;
    if (Get.parameters['index'] != null) {
      setState(() {
        currentIndex = int.parse(Get.parameters['index']!);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Get.back();
      },
      onLongPress: () {
        Get.dialog(
          AlertDialog(
            title: const Text('提示'),
            content: const Text('是否保存图片到相册？'),
            actions: [
              TextButton(
                onPressed: () {
                  Get.back();
                },
                child: const Text('取消'),
              ),
              TextButton(
                onPressed: () async {
                  LoadingUtil.show();
                  if (await Permission.photos.status.isLimited ||
                      await Permission.photos.status.isGranted) {
                    if (urls[currentIndex].isURL) {
                      var response = await Dio().get(urls[currentIndex],
                          options: Options(responseType: ResponseType.bytes));
                      final result = await ImageGallerySaver.saveImage(
                        Uint8List.fromList(response.data),
                      );
                    } else {
                      Uint8List bytes =
                          File(urls[currentIndex]).readAsBytesSync();
                      final result = await ImageGallerySaver.saveImage(
                        bytes,
                      );
                    }
                    LoadingUtil.hide();
                    SnackbarUtil.showSuccess("保存成功");
                    Get.back();
                  } else {
                    LoadingUtil.hide();
                    await Permission.photos.request();
                  }
                },
                child: const Text('确定'),
              ),
            ],
          ),
        );
      },
      child: Stack(
        children: [
          PhotoViewGallery.builder(
            scrollPhysics: const BouncingScrollPhysics(),
            builder: (BuildContext context, int index) {
              return PhotoViewGalleryPageOptions(
                imageProvider: urls[index].isURL
                    ? NetworkImage(urls[index])
                    : FileImage(File(urls[index])),
                initialScale: PhotoViewComputedScale.contained,
                heroAttributes: PhotoViewHeroAttributes(tag: urls[index]),
              );
            },
            itemCount: urls.length,
            loadingBuilder: (context, event) => Center(
              child: SizedBox(
                width: 20.0,
                height: 20.0,
                child: CircularProgressIndicator(
                  value: event == null
                      ? 0
                      : event.cumulativeBytesLoaded / event.expectedTotalBytes!,
                ),
              ),
            ),
            pageController: PageController(
              initialPage: currentIndex,
            ),
            onPageChanged: (index) {
              Get.log('SimpleImagePre onPageChanged: $index');
              setState(() {
                currentIndex = index;
              });
            },
          ),
          Positioned(
            top: 100,
            right: 10,
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xff2b2b2b),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '${currentIndex + 1}/${urls.length}',
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ).paddingOnly(left: 5, right: 5, top: 2, bottom: 2),
            ),
          ),
        ],
      ),
    );
  }
}

class SimpleVideoPre extends StatefulWidget {
  const SimpleVideoPre({super.key});

  @override
  State<SimpleVideoPre> createState() => _SimpleVideoPreState();
}

class _SimpleVideoPreState extends State<SimpleVideoPre>
    with TickerProviderStateMixin {
  late CachedVideoPlayerPlusController videoController;
  late ProgressBarController progressBarController;
  bool isInitVideo = false;
  Duration videoTotalTime = Duration.zero;
  Duration videoCurrentTime = Duration.zero;
  Duration videoBuffered = Duration.zero;
  double videoSpeed = 1.0;
  bool isVideoPause = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    progressBarController = ProgressBarController(vsync: this);
    Get.log('SimpleVideoPre initState: ${Get.arguments}');
    String videoSource = Get.arguments as String;
    if (GetUtils.isURL(videoSource)) {
      videoController =
          CachedVideoPlayerPlusController.networkUrl(Uri.parse(videoSource));
    } else {
      videoController = CachedVideoPlayerPlusController.file(File(videoSource));
    }
    initializeVideoController(videoSource);
  }

  @override
  void dispose() {
    videoController.pause();
    videoController.dispose();
    progressBarController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Stack(
            children: [
              Center(
                child: isInitVideo
                    ? ConstrainedBox(
                        constraints: BoxConstraints(
                          maxHeight: MediaQuery.of(context).size.height - 56,
                        ),
                        child: AspectRatio(
                          aspectRatio: videoController.value.aspectRatio,
                          child: CachedVideoPlayerPlus(videoController),
                        ),
                      )
                    : const Center(
                        child: CircularProgressIndicator.adaptive(),
                      ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 10,
                child: isInitVideo
                    ? Row(
                        children: [
                          GestureDetector(
                            onTap: () {
                              if (isVideoPause) {
                                videoController.play();
                              } else {
                                videoController.pause();
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                color: Colors.black,
                                borderRadius: BorderRadius.circular(40),
                              ),
                              child: Icon(
                                isVideoPause
                                    ? Icons.play_circle_fill
                                    : Icons.pause,
                                color: Colors.white,
                                size: 20,
                              ),
                            ).marginOnly(right: 10),
                          ),
                          Expanded(
                            flex: 1,
                            child: ProgressBar(
                              barCapShape: BarCapShape.round,
                              collapsedProgressBarColor:
                                  const Color(0xffadadad),
                              collapsedBufferedBarColor: Colors.transparent,
                              backgroundBarColor: const Color(0xff595857),
                              expandedProgressBarColor: Colors.white,
                              expandedBufferedBarColor: Colors.transparent,
                              collapsedBarHeight: 1,
                              expandedBarHeight: 3,
                              controller: progressBarController,
                              progress: videoCurrentTime,
                              buffered: videoBuffered,
                              total: videoTotalTime,
                              onSeek: (position) {
                                videoController.seekTo(position);
                              },
                            ),
                          ),
                        ],
                      ).paddingOnly(left: 10, right: 10)
                    : const SizedBox(),
              )
            ],
          ),
        ],
      ),
    );
  }

  void initializeVideoController(String videoSource) {
    videoController.initialize().then((value) async {
      setState(() {
        isInitVideo = true;
        videoTotalTime = videoController.value.duration;
      });
      videoController.play();
      videoController.setLooping(true);
      videoController.addListener(() {
        setState(() {
          videoCurrentTime = videoController.value.position;
          videoBuffered = videoController.value.buffered.isNotEmpty
              ? videoController.value.buffered.last.end
              : Duration.zero;
          videoSpeed = videoController.value.playbackSpeed;
          isVideoPause = !videoController.value.isPlaying;
        });
      });
    });
  }
}
