import 'package:cached_video_player_plus/cached_video_player_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animated_progress_bar/flutter_animated_progress_bar.dart';
import 'package:get/get.dart';
import 'package:xiaofanshu_flutter/controller/note_details_video_controller.dart';
import 'package:xiaofanshu_flutter/static/custom_color.dart';

class VideoHorizontalPre extends StatefulWidget {
  const VideoHorizontalPre({super.key});

  @override
  State<VideoHorizontalPre> createState() => _VideoHorizontalPreState();
}

class _VideoHorizontalPreState extends State<VideoHorizontalPre>
    with TickerProviderStateMixin {
  NoteDetailsVideoController noteDetailsVideoController = Get.find();
  late ProgressBarController progressBarController;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft, //全屏时旋转方向，左边
    ]);
    progressBarController = ProgressBarController(
      vsync: this,
    );
    noteDetailsVideoController.videoController.play();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp, //退出全屏时旋转方向，正常
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      endDrawer: Drawer(
        backgroundColor: Colors.black.withOpacity(0.8),
        child: Obx(
          () => ListView(
            children: [
              ListTile(
                title: Text(
                  "0.5x",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: noteDetailsVideoController.videoSpeed.value == 0.5
                        ? CustomColor.primaryColor
                        : Colors.white,
                  ),
                ),
                onTap: () {
                  noteDetailsVideoController.videoSpeed.value = 0.5;
                  noteDetailsVideoController.videoController
                      .setPlaybackSpeed(0.5);
                  Get.back();
                },
              ),
              ListTile(
                title: Text(
                  "0.75x",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: noteDetailsVideoController.videoSpeed.value == 0.75
                        ? CustomColor.primaryColor
                        : Colors.white,
                  ),
                ),
                onTap: () {
                  noteDetailsVideoController.videoSpeed.value = 0.75;
                  noteDetailsVideoController.videoController
                      .setPlaybackSpeed(0.75);
                  Get.back();
                },
              ),
              ListTile(
                title: Text(
                  "1.0x",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: noteDetailsVideoController.videoSpeed.value == 1.0
                        ? CustomColor.primaryColor
                        : Colors.white,
                  ),
                ),
                onTap: () {
                  noteDetailsVideoController.videoSpeed.value = 1.0;
                  noteDetailsVideoController.videoController
                      .setPlaybackSpeed(1.0);
                  Get.back();
                },
              ),
              ListTile(
                title: Text(
                  "1.25x",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: noteDetailsVideoController.videoSpeed.value == 1.25
                        ? CustomColor.primaryColor
                        : Colors.white,
                  ),
                ),
                onTap: () {
                  noteDetailsVideoController.videoSpeed.value = 1.25;
                  noteDetailsVideoController.videoController
                      .setPlaybackSpeed(1.25);
                  Get.back();
                },
              ),
              ListTile(
                title: Text(
                  "1.5x",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: noteDetailsVideoController.videoSpeed.value == 1.5
                        ? CustomColor.primaryColor
                        : Colors.white,
                  ),
                ),
                onTap: () {
                  noteDetailsVideoController.videoSpeed.value = 1.5;
                  noteDetailsVideoController.videoController
                      .setPlaybackSpeed(1.5);
                  Get.back();
                },
              ),
              ListTile(
                title: Text(
                  "1.75x",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: noteDetailsVideoController.videoSpeed.value == 1.75
                        ? CustomColor.primaryColor
                        : Colors.white,
                  ),
                ),
                onTap: () {
                  noteDetailsVideoController.videoSpeed.value = 1.75;
                  noteDetailsVideoController.videoController
                      .setPlaybackSpeed(1.75);
                  Get.back();
                },
              ),
              ListTile(
                title: Text(
                  "2.0x",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: noteDetailsVideoController.videoSpeed.value == 2.0
                        ? CustomColor.primaryColor
                        : Colors.white,
                  ),
                ),
                onTap: () {
                  noteDetailsVideoController.videoSpeed.value = 2.0;
                  noteDetailsVideoController.videoController
                      .setPlaybackSpeed(2.0);
                  Get.back();
                },
              ),
            ],
          ),
        ),
      ),
      body: Center(
        child: Stack(
          children: [
            AspectRatio(
              aspectRatio:
                  noteDetailsVideoController.videoController.value.aspectRatio,
              child: CachedVideoPlayerPlus(
                  noteDetailsVideoController.videoController),
            ),
            Positioned(
              top: 0,
              left: 10,
              child: IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios,
                  color: Colors.white,
                ),
                onPressed: () {
                  Get.back();
                },
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Obx(
                () => Column(
                  children: [
                    noteDetailsVideoController.isInitVideo.value
                        ? ProgressBar(
                            barCapShape: BarCapShape.round,
                            collapsedProgressBarColor: const Color(0xffadadad),
                            collapsedBufferedBarColor: Colors.transparent,
                            backgroundBarColor: const Color(0xff595857),
                            expandedProgressBarColor: Colors.white,
                            expandedBufferedBarColor: Colors.transparent,
                            collapsedBarHeight: 1,
                            expandedBarHeight: 3,
                            controller: progressBarController,
                            progress: noteDetailsVideoController
                                .videoCurrentTime.value,
                            buffered:
                                noteDetailsVideoController.videoBuffered.value,
                            total:
                                noteDetailsVideoController.videoTotalTime.value,
                            onSeek: (position) {
                              noteDetailsVideoController.videoController
                                  .seekTo(position);
                            },
                          ).paddingOnly(left: 10, right: 10)
                        : const SizedBox(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () {
                            noteDetailsVideoController
                                    .videoController.value.isPlaying
                                ? noteDetailsVideoController.videoController
                                    .pause()
                                : noteDetailsVideoController.videoController
                                    .play();
                          },
                          child: Icon(
                            noteDetailsVideoController.isVideoPause.value
                                ? Icons.play_arrow
                                : Icons.pause,
                            color: Colors.white,
                            size: 30,
                          ),
                        ),
                        Row(
                          children: [
                            Builder(builder: (context) {
                              return GestureDetector(
                                onTap: () {
                                  Scaffold.of(context).openEndDrawer();
                                },
                                child: Text(
                                  "${noteDetailsVideoController.videoSpeed.value}x",
                                  style: const TextStyle(color: Colors.white),
                                ).paddingOnly(right: 10),
                              );
                            }),
                            GestureDetector(
                              onTap: () {
                                Get.back();
                              },
                              child: const Icon(
                                Icons.fit_screen_outlined,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ).paddingOnly(left: 10, right: 10),
            ),
          ],
        ),
      ),
    );
  }
}
