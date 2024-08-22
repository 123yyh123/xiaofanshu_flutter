import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:xiaofanshu_flutter/utils/Adapt.dart';

class ChatAudioMask extends StatefulWidget {
  final RecordAudioState recordAudioState;

  const ChatAudioMask({super.key, required this.recordAudioState});

  @override
  State<ChatAudioMask> createState() => ChatAudioMaskState();
}

class ChatAudioMaskState extends State<ChatAudioMask> {
  double _height = 0;
  bool _showAudioWave = false;
  late RecordAudioState recordAudioState;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    recordAudioState = widget.recordAudioState;
    Future.delayed(const Duration(milliseconds: 150)).then((value) {
      if (mounted) {
        setState(() {
          _height = 100;
        });
      }
    });
    Future.delayed(const Duration(milliseconds: 350)).then((value) {
      if (mounted) {
        setState(() {
          _showAudioWave = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      child: Material(
        color: Colors.black.withOpacity(0.5),
        child: Column(
          children: [
            SizedBox(
              height: Adapt.setRpx(400),
            ),
            Expanded(
              child: Center(
                child: _showAudioWave
                    ? AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        // 动画时长
                        height: Adapt.setRpx(150),
                        width: recordAudioState.recordingState == 1
                            ? Adapt.setRpx(500)
                            : Adapt.setRpx(300),
                        // 宽度的变化
                        decoration: BoxDecoration(
                          color: recordAudioState.recordingState == 1
                              ? Colors.blueAccent
                              : Colors.redAccent, // 颜色的变化
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Center(
                          child: Container(
                            height: Adapt.setRpx(100),
                            width: recordAudioState.recordingState == 1
                                ? Adapt.setRpx(400)
                                : Adapt.setRpx(250), // 内部容器宽度的变化
                            padding: const EdgeInsets.all(10),
                            // 模拟音频波形
                            child: AudioWaveformBar(),
                          ),
                        ),
                      )
                    : Container(),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 50),
              child: Text(recordAudioState.noticeMessage,
                  style: const TextStyle(
                    color: Color(0xfff3f3f2),
                    fontSize: 16,
                  )),
            ),
            Center(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(200),
                    topRight: Radius.circular(200),
                  ),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xffadadad),
                      Color(0xfff3f3f2),
                    ],
                  ),
                ),
                // color: Colors.grey,
                width: double.infinity,
                height: _height,
                child: const Icon(
                  Icons.multitrack_audio_sharp,
                  color: Colors.grey,
                  size: 40,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  // 方法用于更新参数
  void updateParameter(RecordAudioState newValue) {
    setState(() {
      recordAudioState = newValue;
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }
}

class RecordAudioState {
  bool recording;
  int recordingState;
  String noticeMessage;

  RecordAudioState({
    required this.recording,
    required this.recordingState,
    required this.noticeMessage,
  });
}

class AudioWaveformBarPainter extends CustomPainter {
  final List<double> amplitudes;
  final double barWidth;
  final double cornerRadius;

  AudioWaveformBarPainter(this.amplitudes,
      {required this.barWidth, required this.cornerRadius});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xff2b2b2b)
      ..style = PaintingStyle.fill;

    final double spacing = barWidth; // 间距设置为与条形宽度相同
    final double centerY = size.height / 2;
    for (int i = 0; i < amplitudes.length; i++) {
      final x = i * (barWidth + spacing);
      final barHeight = amplitudes[i] * size.height - 20;

      // 调整x坐标，使得条形在Canvas的中心水平对齐
      final xPosition =
          (size.width - (amplitudes.length * (barWidth + spacing) - spacing)) /
                  2 +
              x;

      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(
          xPosition,
          centerY - barHeight / 2,
          barWidth,
          barHeight,
        ),
        Radius.circular(cornerRadius),
      );
      canvas.drawRRect(rect, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

class AudioWaveformBar extends StatefulWidget {
  @override
  _AudioWaveformBarState createState() => _AudioWaveformBarState();
}

class _AudioWaveformBarState extends State<AudioWaveformBar> {
  List<double> amplitudes = [];
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _generateWaveform();
    _timer = Timer.periodic(const Duration(milliseconds: 120), (timer) {
      setState(() {
        _generateWaveform();
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _generateWaveform() {
    amplitudes = List.generate(30, (index) => Random().nextDouble());
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: AudioWaveformBarPainter(
        amplitudes,
        barWidth: 2.0, // 这里设置条形的宽度
        cornerRadius: 5.0, // 这里设置条形的圆角弧度
      ),
    );
  }
}
