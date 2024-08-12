import 'dart:async';
import 'package:flutter/material.dart';

// 解决中文和英文提前自动换行问题
extension FixAutoLines on String {
  String fixAutoLines() {
    return Characters(this).join('\u{200B}');
  }
}

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
