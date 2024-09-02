import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_z_location/flutter_z_location.dart';
import 'package:xiaofanshu_flutter/utils/Adapt.dart';

// 解决中文和英文提前自动换行问题
extension FixAutoLines on String {
  String fixAutoLines() {
    return Characters(this).join('\u{200B}');
  }
}

// 判断字符串是否为url，标准为http://或https://开头
extension IsUrl on String {
  bool get isUrl {
    return RegExp(r'^https?://').hasMatch(this);
  }
}

Future<Size> getImageDimensions(String imageUrl) async {
  final Completer<Size> completer = Completer<Size>();
  final ImageProvider provider = NetworkImage(imageUrl);

  final ImageStream stream = provider.resolve(const ImageConfiguration());

  void handleImageInfo(ImageInfo info, bool synchronousCall) {
    // 确保Completer只完成一次
    if (!completer.isCompleted) {
      final imageSize = Size(
        info.image.width.toDouble(),
        info.image.height.toDouble(),
      );
      completer.complete(imageSize);
    }
  }

  final ImageStreamListener listener = ImageStreamListener(handleImageInfo);

  stream.addListener(listener);

  // 监听错误情况
  completer.future.catchError((error) {
    stream.removeListener(listener);
  });

  return completer.future;
}

// 日期字符串转时间戳
int dateStringToTimestamp(String dateString) {
  // dateString格式为'yyyy-MM-dd HH:mm:ss'，是UTC时间字符串，需要转换为UTC+8
  DateTime utcDateTime = DateTime.parse(dateString).toUtc();
  DateTime localDateTime = utcDateTime.add(const Duration(hours: 8));
  return localDateTime.millisecondsSinceEpoch;
}

// 时间戳转日期字符串 'yyyy-MM-dd HH:mm:ss'
String timestampToDateString(int timestamp) {
  DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
  String formattedDateTime =
      "${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} "
      "${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}:${dateTime.second.toString().padLeft(2, '0')}";
  return formattedDateTime;
}

// 插入文本
void insertText(String text, TextEditingController controller) {
  final textValue = controller.text;
  final textSelection = controller.selection;
// 确保光标位置有效
  final start = textSelection.start < 0 ? 0 : textSelection.start;
  final end = textSelection.end < 0 ? 0 : textSelection.end;
  final newText = textValue.replaceRange(
    start,
    end,
    text,
  );

  final newTextSelection = textSelection.copyWith(
    baseOffset: textSelection.start + text.length,
    extentOffset: textSelection.start + text.length,
  );

  controller.value = controller.value.copyWith(
    text: newText,
    selection: newTextSelection,
    composing: TextRange.empty,
  );
}

void closeKeyboardButKeepFocus() {
  SystemChannels.textInput.invokeMethod('TextInput.hide');
}

void showKeyboard() {
  SystemChannels.textInput.invokeMethod('TextInput.show');
}

void copyToClipboard(String text) {
  Clipboard.setData(ClipboardData(text: text));
}

// 获取经纬度
Future<String> getLocation() async {
  final coordinate = await FlutterZLocation.getCoordinate();
  return '${coordinate.latitude},${coordinate.longitude}';
}

// 根据语音时长来计算组件宽度
double calculateAudioWidth(int audioTime) {
  final double maxWidth = Adapt.setRpx(450);
  final double minWidth = Adapt.setRpx(150);
  // 语音时长超出60秒的，按60秒计算
  final int time = audioTime > 60 ? 60 : audioTime;
  final double width = minWidth + (maxWidth - minWidth) * time / 60;
  return width;
}
