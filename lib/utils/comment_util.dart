import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// 解决中文和英文提前自动换行问题
extension FixAutoLines on String {
  String fixAutoLines() {
    return Characters(this).join('\u{200B}');
  }
}

// 获取图片的宽度和高度
Future<Size> getImageDimensions(String imageUrl) async {
  // 创建一个ImageProvider
  final ImageProvider provider = NetworkImage(imageUrl);

  // 完成图片加载的Completer
  final Completer<Size> completer = Completer<Size>();

  // 定义图片加载监听器
  final ImageStreamListener listener = ImageStreamListener(
    (ImageInfo info, bool synchronousCall) {
      // 图片加载完成，获取图片的宽度和高度
      final imageSize = Size(
        info.image.width.toDouble(),
        info.image.height.toDouble(),
      );
      // 完成completer
      completer.complete(imageSize);
    },
    onError: (exception, stackTrace) {
      // 图片加载失败，完成completer并传递异常
      completer.completeError(exception, stackTrace);
    },
  );

  // 获取图片的ImageStream
  final ImageStream stream = provider.resolve(const ImageConfiguration());

  // 为ImageStream添加监听器
  stream.addListener(listener);

  // 返回Future，将在图片加载完成或发生错误时完成
  return completer.future;
}

// 日期字符串转时间戳
int dateStringToTimestamp(String dateString) {
  return DateTime.parse(dateString).millisecondsSinceEpoch;
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
  final newText = textValue.replaceRange(
    textSelection.start,
    textSelection.end,
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
