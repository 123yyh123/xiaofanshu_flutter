import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:xiaofanshu_flutter/utils/audio_play_manager.dart';
import '../pages/home/message/chat.dart';
import '../utils/comment_util.dart';

class AudioAnimation extends StatefulWidget {
  final String message;
  final int audioTime;
  final bool isMe;

  const AudioAnimation(
      {super.key,
      required this.message,
      required this.audioTime,
      required this.isMe});

  @override
  State<AudioAnimation> createState() => _AudioAnimationState();
}

class _AudioAnimationState extends State<AudioAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController animationController;

  @override
  void initState() {
    super.initState();
    // 初始为停止状态，并且循环播放，刚开始为满的状态
    animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )
      ..repeat()
      ..stop()
      ..value = 1.0;
    AudioPlayManager.instance.audioPlayer.onPlayerStateChanged.listen((event) {
      // 判断当前播放的语音是否是当前点击的语音
      var source = AudioPlayManager.instance.audioPlayer.source;
      if (source == null ||
          (source is UrlSource && source.url != widget.message) ||
          (source is DeviceFileSource && source.path != widget.message)) {
        try {
          animationController.stop();
        } catch (e) {
          Get.log('动画控制器已经被释放');
        }
        return;
      }
      Get.log('语音状态变为了: $event');
      if (event == PlayerState.playing) {
        animationController.repeat();
      } else if (event == PlayerState.paused) {
        animationController.stop();
      } else if (event == PlayerState.completed) {
        animationController.stop();
      }
    });
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Get.log('点击了语音消息');
        var source = AudioPlayManager.instance.audioPlayer.source;
        if (source == null ||
            (source is UrlSource && source.url != widget.message) ||
            (source is DeviceFileSource && source.path != widget.message)) {
          // 执行对应的逻辑
          Get.log('播放新的语音');
          // 如果当前播放的语音不是当前点击的语音，则停止当前播放的语音，播放当前点击的语音
          AudioPlayManager.instance.audioPlayer.stop();
          AudioPlayManager.instance.audioPlayer.setSource(
            widget.message.isUrl
                ? UrlSource(
                    widget.message,
                  )
                : DeviceFileSource(
                    widget.message,
                  ),
          );
          AudioPlayManager.instance.audioPlayer.play(widget.message.isUrl
              ? UrlSource(
                  widget.message,
                )
              : DeviceFileSource(
                  widget.message,
                ));
        } else {
          Get.log('播放当前的语音');
          Get.log('当前语音状态: ${AudioPlayManager.instance.audioPlayer.state}');
          // 如果当前播放的语音是当前点击的语音，则暂停或者继续播放
          if (AudioPlayManager.instance.audioPlayer.state ==
              PlayerState.completed) {
            AudioPlayManager.instance.audioPlayer.play(
              widget.message.isUrl
                  ? UrlSource(
                      widget.message,
                    )
                  : DeviceFileSource(
                      widget.message,
                    ),
            );
          } else if (AudioPlayManager.instance.audioPlayer.state ==
              PlayerState.playing) {
            AudioPlayManager.instance.audioPlayer.pause();
          } else if (AudioPlayManager.instance.audioPlayer.state ==
              PlayerState.paused) {
            AudioPlayManager.instance.audioPlayer.resume();
          }
        }
      },
      child: Container(
        width: calculateAudioWidth(widget.audioTime),
        height: 40,
        decoration: BoxDecoration(
          color: widget.isMe ? const Color(0xff38a1db) : Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisAlignment:
              widget.isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
          children: [
            widget.isMe
                ? Text(
                    '${widget.audioTime.toString()}"',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  )
                : SizedBox(
                    width: 30,
                    child: AnimatedBuilder(
                      animation: animationController,
                      builder: (context, child) {
                        return CustomPaint(
                          painter: ArcPainter(animationController.value, false),
                        );
                      },
                    ),
                  ).paddingOnly(left: 3, right: 5),
            widget.isMe
                ? SizedBox(
                    width: 30,
                    child: AnimatedBuilder(
                      animation: animationController,
                      builder: (context, child) {
                        return CustomPaint(
                          painter: ArcPainter(animationController.value, true),
                        );
                      },
                    ),
                  ).paddingOnly(left: 3, right: 5)
                : Text(
                    '${widget.audioTime.toString()}"',
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 14,
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
