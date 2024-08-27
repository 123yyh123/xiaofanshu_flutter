import 'dart:ui';

import 'package:cached_video_player_plus/cached_video_player_plus.dart';
import 'package:extended_text_field/extended_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animated_progress_bar/flutter_animated_progress_bar.dart';
import 'package:get/get.dart';
import 'package:heart_overlay/heart_overlay.dart';
import 'package:lifecycle_lite/lifecycle_mixin.dart';
import 'package:like_button/like_button.dart';

import '../../apis/app.dart';
import '../../config/custom_icon.dart';
import '../../config/text_field_config.dart';
import '../../controller/note_details_video_controller.dart';
import '../../static/custom_color.dart';
import '../../utils/Adapt.dart';

class NoteDetailsVideo extends StatefulWidget {
  const NoteDetailsVideo({super.key});

  @override
  State<NoteDetailsVideo> createState() => _NoteDetailsVideoState();
}

class _NoteDetailsVideoState extends State<NoteDetailsVideo>
    with TickerProviderStateMixin, LifecycleStatefulMixin {
  NoteDetailsVideoController noteDetailsVideoController = Get.find();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    noteDetailsVideoController.progressBarController =
        ProgressBarController(vsync: this);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    Get.log('dispose');
    noteDetailsVideoController.videoController.pause();
  }

  @override
  void deactivate() {
    // TODO: implement deactivate
    super.deactivate();
    Get.log('deactivate');
    noteDetailsVideoController.videoController.pause();
  }

  @override
  void activate() {
    // TODO: implement activate
    super.activate();
    noteDetailsVideoController.videoController.play();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: GestureDetector(
          onTap: () {
            Get.back();
          },
          child: const Icon(
            Icons.arrow_back_ios,
            color: Colors.white,
            size: 25,
          ).marginOnly(left: 10),
        ),
        leadingWidth: 28,
        title: Obx(
          () => Row(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              noteDetailsVideoController.notes.value.belongUserId ==
                      noteDetailsVideoController.userInfo.value.id
                  ? GestureDetector(
                      onTap: () {},
                      child: const Icon(
                        Icons.more_horiz,
                        size: 25,
                        color: Colors.white,
                      ))
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        GestureDetector(
                          onTap: () {},
                          child: const Icon(
                            CustomIcon.share,
                            size: 25,
                            color: Colors.white,
                          ),
                        ).paddingOnly(left: 15, right: 10),
                      ],
                    ),
            ],
          ),
        ),
      ),
      backgroundColor: Colors.black,
      body: Obx(
        () => noteDetailsVideoController.isInitVideo.value
            ? Column(
                children: [
                  GestureDetector(
                    onTap: () {
                      if (noteDetailsVideoController.isVideoPause.value) {
                        noteDetailsVideoController.videoController.play();
                        noteDetailsVideoController.isVideoPause.value = false;
                      } else {
                        noteDetailsVideoController.videoController.pause();
                        noteDetailsVideoController.isVideoPause.value = true;
                      }
                    },
                    onLongPressStart: (details) {
                      // 2倍速播放
                      if (noteDetailsVideoController
                          .videoController.value.isPlaying) {
                        noteDetailsVideoController.videoController
                            .setPlaybackSpeed(2);
                      }
                    },
                    onLongPressEnd: (details) {
                      // 恢复正常速度
                      noteDetailsVideoController.videoController
                          .setPlaybackSpeed(1);
                    },
                    child: SizedBox(
                      width: double.infinity,
                      height: MediaQuery.of(context).size.height - 56,
                      child: Stack(
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Stack(
                                children: [
                                  Center(
                                    child: noteDetailsVideoController
                                            .isInitVideo.value
                                        ? ConstrainedBox(
                                            constraints: BoxConstraints(
                                              maxHeight: MediaQuery.of(context)
                                                      .size
                                                      .height -
                                                  56,
                                            ),
                                            child: AspectRatio(
                                              aspectRatio:
                                                  noteDetailsVideoController
                                                      .videoController
                                                      .value
                                                      .aspectRatio,
                                              child: CachedVideoPlayerPlus(
                                                  noteDetailsVideoController
                                                      .videoController),
                                            ),
                                          )
                                        : const Center(
                                            child: CircularProgressIndicator
                                                .adaptive(),
                                          ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Positioned(
                            left: 0,
                            right: 0,
                            top: 0,
                            bottom: 0,
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.transparent,
                                    Colors.black.withOpacity(0.2),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          HeartOverlay(
                            controller: noteDetailsVideoController
                                .heartOverlayController,
                            duration: const Duration(milliseconds: 2500),
                            backgroundColor: Colors.transparent,
                            tapDownType: TapDownType.double,
                            // verticalOffset: 20,
                            // horizontalOffset: -100,
                            enableGestures: true,
                            cacheExtent: 30,
                            splashAnimationDetails:
                                const SplashAnimationDetails(
                              enableSplash: true,
                              animationDuration: Duration(milliseconds: 1000),
                            ),
                            icon: const Icon(
                              Icons.favorite,
                              color: Colors.redAccent,
                              size: 100,
                            ),
                            onPressed: (numberOfHearts) {
                              if (!noteDetailsVideoController
                                  .notes.value.isLike) {
                                noteDetailsVideoController.notes.value.isLike =
                                    true;
                                noteDetailsVideoController
                                    .notes.value.notesLikeNum++;
                                NoteApi.praiseNotes(
                                    noteDetailsVideoController.notes.value.id,
                                    noteDetailsVideoController
                                        .userInfo.value.id,
                                    noteDetailsVideoController
                                        .notes.value.belongUserId);
                              }
                            },
                          ),
                          // 当宽大于高时，显示全屏按钮
                          noteDetailsVideoController.isInitVideo.value &&
                                  noteDetailsVideoController
                                          .videoController.value.size.width >
                                      noteDetailsVideoController
                                          .videoController.value.size.height
                              ? Positioned(
                                  right: 0,
                                  left: 0,
                                  bottom: (MediaQuery.of(context).size.height *
                                      0.25),
                                  child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        GestureDetector(
                                          onTap: () {
                                            Get.toNamed('/videoPlayer',
                                                arguments:
                                                    noteDetailsVideoController
                                                        .videoController);
                                          },
                                          behavior: HitTestBehavior.opaque,
                                          child: Container(
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                  color:
                                                      const Color(0xffadadad),
                                                  width: 1),
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                            ),
                                            child: Row(
                                              children: [
                                                const Icon(
                                                  Icons.rotate_left,
                                                  color: Color(0xffadadad),
                                                  size: 12,
                                                ).marginOnly(right: 8),
                                                const Text(
                                                  "全屏观看",
                                                  style: TextStyle(
                                                      height: 1.5,
                                                      color: Color(0xffadadad),
                                                      fontSize: 12),
                                                ),
                                              ],
                                            ).paddingOnly(
                                                left: 10,
                                                right: 10,
                                                top: 5,
                                                bottom: 5),
                                          ).marginAll(20),
                                        ),
                                      ]),
                                )
                              : const SizedBox(),
                          Positioned(
                            left: 0,
                            right: 0,
                            top: 0,
                            bottom: 0,
                            child:
                                !noteDetailsVideoController.isVideoPause.value
                                    ? noteDetailsVideoController.videoController
                                                .value.playbackSpeed ==
                                            2
                                        ? const Icon(
                                            Icons.fast_forward_rounded,
                                            color: Colors.white,
                                            size: 50,
                                          )
                                        : const SizedBox()
                                    : const Icon(
                                        Icons.play_arrow,
                                        color: Colors.white,
                                        size: 50,
                                      ),
                          ),
                          Positioned(
                            left: 0,
                            right: 0,
                            bottom: 0,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  height: 90,
                                  width: double.infinity,
                                  child: Row(
                                    children: [
                                      Container(
                                        height: 40,
                                        width: 40,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(20),
                                          color: Colors.white,
                                        ),
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(20),
                                          child: Image.network(
                                            noteDetailsVideoController
                                                .notes.value.avatarUrl,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        noteDetailsVideoController
                                            .notes.value.nickname,
                                        style: const TextStyle(
                                            color: Colors.white, fontSize: 16),
                                      ).marginOnly(left: 15),
                                      noteDetailsVideoController
                                                  .notes.value.belongUserId ==
                                              noteDetailsVideoController
                                                  .userInfo.value.id
                                          ? const SizedBox()
                                          : GestureDetector(
                                              onTap: () {
                                                noteDetailsVideoController
                                                        .notes.value.isFollow =
                                                    !noteDetailsVideoController
                                                        .notes.value.isFollow;
                                                noteDetailsVideoController.notes
                                                    .refresh();
                                                UserApi.attentionUser(
                                                  noteDetailsVideoController
                                                      .userInfo.value.id,
                                                  noteDetailsVideoController
                                                      .notes.value.belongUserId,
                                                );
                                              },
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(20),
                                                  border: Border.all(
                                                    color:
                                                        noteDetailsVideoController
                                                                .notes
                                                                .value
                                                                .isFollow
                                                            ? CustomColor
                                                                .unselectedColor
                                                            : CustomColor
                                                                .primaryColor,
                                                    width: 1,
                                                  ),
                                                  color:
                                                      noteDetailsVideoController
                                                              .notes
                                                              .value
                                                              .isFollow
                                                          ? Colors.transparent
                                                          : CustomColor
                                                              .primaryColor,
                                                ),
                                                child: Text(
                                                  noteDetailsVideoController
                                                          .notes.value.isFollow
                                                      ? '已关注'
                                                      : '关注',
                                                  style: const TextStyle(
                                                      fontSize: 12,
                                                      color: Colors.white),
                                                ).paddingOnly(
                                                    left: 20,
                                                    right: 20,
                                                    top: 5,
                                                    bottom: 5),
                                              ).marginOnly(left: 15),
                                            ),
                                    ],
                                  ).paddingOnly(
                                      left: 15, right: 15, bottom: 15),
                                ),
                                ExtendedTextField(
                                  onTap: () {
                                    noteDetailsVideoController.openComment();
                                  },
                                  scrollPhysics:
                                      const NeverScrollableScrollPhysics(),
                                  selectionControls:
                                      CustomTextSelectionControls(),
                                  decoration: const InputDecoration(
                                    isCollapsed: true,
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.all(0),
                                  ),
                                  style: const TextStyle(
                                      fontSize: 16,
                                      color: Colors.white,
                                      overflow: TextOverflow.ellipsis),
                                  readOnly: true,
                                  maxLines: 2,
                                  controller: noteDetailsVideoController
                                      .contentController,
                                  specialTextSpanBuilder:
                                      MySpecialTextSpanBuilder(),
                                ).paddingOnly(left: 10, right: 10, bottom: 10),
                                // 进度条
                                noteDetailsVideoController.isInitVideo.value
                                    ? ProgressBar(
                                        barCapShape: BarCapShape.round,
                                        collapsedProgressBarColor:
                                            const Color(0xffadadad),
                                        collapsedBufferedBarColor:
                                            Colors.transparent,
                                        backgroundBarColor:
                                            const Color(0xff595857),
                                        expandedProgressBarColor: Colors.white,
                                        expandedBufferedBarColor:
                                            Colors.transparent,
                                        collapsedBarHeight: 1,
                                        expandedBarHeight: 3,
                                        controller: noteDetailsVideoController
                                            .progressBarController,
                                        progress: noteDetailsVideoController
                                            .videoCurrentTime.value,
                                        buffered: noteDetailsVideoController
                                            .videoBuffered.value,
                                        total: noteDetailsVideoController
                                            .videoTotalTime.value,
                                        onSeek: (position) {
                                          noteDetailsVideoController
                                              .videoController
                                              .seekTo(position);
                                        },
                                      ).paddingOnly(left: 10, right: 10)
                                    : const SizedBox(),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    height: 56,
                    color: Colors.transparent,
                    child: Row(
                      children: [
                        Expanded(
                          flex: 1,
                          child: GestureDetector(
                            onTap: () {
                              noteDetailsVideoController.judgeSameReply(
                                  '', '', '');
                              noteDetailsVideoController.showBottomInput();
                            },
                            child: Container(
                              height: 56,
                              decoration: BoxDecoration(
                                color: const Color(0xff2b2b2b),
                                borderRadius: BorderRadius.circular(25),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.edit_note_rounded,
                                    size: 20,
                                    color: Color(0xffadadad),
                                  ).paddingOnly(left: 10),
                                  const Text(
                                    '说点什么...',
                                    style: TextStyle(
                                      color: Color(0xffadadad),
                                      fontSize: 16,
                                    ),
                                  ).paddingOnly(left: 5, right: 15),
                                ],
                              ),
                            ).paddingAll(10),
                          ),
                        ),
                        LikeButton(
                          mainAxisAlignment: MainAxisAlignment.center,
                          countPostion: CountPostion.right,
                          likeCountPadding: const EdgeInsets.all(10),
                          likeBuilder: (bool isLiked) {
                            return Icon(
                              isLiked ? Icons.favorite : Icons.favorite_border,
                              color: isLiked
                                  ? CustomColor.primaryColor
                                  : Colors.white,
                              size: 32,
                            );
                          },
                          countBuilder:
                              (int? count, bool isLiked, String text) {
                            count ??= 0;
                            return count == 0
                                ? const SizedBox()
                                : Text(
                                    text,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.white,
                                    ),
                                  );
                          },
                          isLiked:
                              noteDetailsVideoController.notes.value.isLike,
                          likeCount: noteDetailsVideoController
                              .notes.value.notesLikeNum,
                          onTap: (bool isLiked) async {
                            noteDetailsVideoController.notes.value.isLike =
                                !isLiked;
                            noteDetailsVideoController.notes.value.isLike
                                ? noteDetailsVideoController
                                    .notes.value.notesLikeNum++
                                : noteDetailsVideoController
                                    .notes.value.notesLikeNum--;
                            NoteApi.praiseNotes(
                                noteDetailsVideoController.notes.value.id,
                                noteDetailsVideoController.userInfo.value.id,
                                noteDetailsVideoController
                                    .notes.value.belongUserId);
                            return !isLiked;
                          },
                        ),
                        LikeButton(
                          mainAxisAlignment: MainAxisAlignment.center,
                          countPostion: CountPostion.right,
                          likeCountPadding: const EdgeInsets.all(10),
                          likeBuilder: (bool isLiked) {
                            return Icon(
                              isLiked ? Icons.star : Icons.star_border,
                              color: isLiked
                                  ? const Color(0xfffbd26b)
                                  : Colors.white,
                              size: 32,
                            );
                          },
                          countBuilder:
                              (int? count, bool isLiked, String text) {
                            count ??= 0;
                            return count == 0
                                ? const SizedBox()
                                : Text(
                                    text,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                        fontSize: 14, color: Colors.white),
                                  );
                          },
                          isLiked:
                              noteDetailsVideoController.notes.value.isCollect,
                          likeCount: noteDetailsVideoController
                              .notes.value.notesCollectNum,
                          onTap: (bool isLiked) async {
                            noteDetailsVideoController.notes.value.isCollect =
                                !isLiked;
                            noteDetailsVideoController.notes.value.isCollect
                                ? noteDetailsVideoController
                                    .notes.value.notesCollectNum++
                                : noteDetailsVideoController
                                    .notes.value.notesCollectNum--;
                            NoteApi.collectNotes(
                                noteDetailsVideoController.notes.value.id,
                                noteDetailsVideoController.userInfo.value.id,
                                noteDetailsVideoController
                                    .notes.value.belongUserId);
                            return !isLiked;
                          },
                        ),
                        LikeButton(
                          mainAxisAlignment: MainAxisAlignment.center,
                          countPostion: CountPostion.right,
                          likeCountPadding: const EdgeInsets.all(10),
                          likeBuilder: (bool isLiked) {
                            return const Icon(
                              CustomIcon.comment,
                              color: Colors.white,
                              size: 31,
                            );
                          },
                          countBuilder:
                              (int? count, bool isLiked, String text) {
                            count ??= 0;
                            return count == 0
                                ? const SizedBox()
                                : Text(
                                    text,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                        fontSize: 14, color: Colors.white),
                                  );
                          },
                          isLiked: false,
                          likeCount:
                              noteDetailsVideoController.commentCount.value,
                          onTap: (bool isLiked) async {
                            // 打开评论区
                            noteDetailsVideoController.openComment();
                          },
                        ),
                      ],
                    ).paddingOnly(right: 3),
                  ),
                ],
              )
            : const Center(
                child: CircularProgressIndicator.adaptive(),
              ),
      ),
    );
  }

  @override
  void whenHide() {
    // TODO: implement whenHide
    Get.log('whenHide');
    noteDetailsVideoController.videoController.pause();
  }

  @override
  void whenShow() {
    // TODO: implement whenShow
    Get.log('whenShow');
    noteDetailsVideoController.videoController.play();
  }
}
