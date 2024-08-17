import 'package:flutter/material.dart';
import 'package:extended_text_field/extended_text_field.dart';
import 'dart:convert';
import 'package:get/get.dart';
import 'package:flutter/gestures.dart';
import 'package:xiaofanshu_flutter/utils/comment_util.dart';
import '../../static/emoji_map.dart';
import 'package:xiaofanshu_flutter/static/custom_color.dart';

class MySpecialTextSpanBuilder extends SpecialTextSpanBuilder {
  MySpecialTextSpanBuilder();

  @override
  TextSpan build(String data, {TextStyle? textStyle, onTap}) {
    var textSpan = super.build(data, textStyle: textStyle, onTap: onTap);
    return textSpan;
  }

  @override
  SpecialText? createSpecialText(String flag,
      {TextStyle? textStyle,
      SpecialTextGestureTapCallback? onTap,
      required int index}) {
    if (flag.isEmpty) return null;

    TextStyle effectiveTextStyle =
        textStyle ?? const TextStyle(color: Colors.black, fontSize: 12);

    if (isStart(flag, AtText.flag)) {
      return AtText(effectiveTextStyle, onTap,
          start: index - (AtText.flag.length - 1));
    } else if (isStart(flag, TopicText.flag)) {
      return TopicText(effectiveTextStyle, onTap,
          start: index - (TopicText.flag.length - 1));
    } else if (isStart(flag, ReplyText.flag)) {
      return ReplyText(effectiveTextStyle, onTap,
          start: index - (ReplyText.flag.length - 1));
    } else if (isStart(flag, EmojiText.flag)) {
      return EmojiText(effectiveTextStyle, onTap,
          start: index - (EmojiText.flag.length - 1));
    }
    return null;
  }
}

/// @somebody，showText: @somebody，realText: @{"id":"123456","name":"somebody"}
class AtText extends SpecialText {
  static const String flag = "@";
  final int start;

  AtText(TextStyle textStyle, SpecialTextGestureTapCallback? onTap,
      {required this.start})
      : super(flag, " ", textStyle, onTap: onTap);

  @override
  TextSpan finishText() {
    TextStyle? textStyle = this
        .textStyle
        ?.copyWith(color: CustomColor.primaryColor, fontSize: 16.0);
    // Map<String, String> map = {
    //   "id": "123456",
    //   "name": "somebody",
    // };
    // String realText='@${jsonEncode(map)} ';
    String realText = toString();
    String showText = '';
    try {
      realText = realText.replaceAll('\u200B', '');
      Map<String, dynamic> map =
          jsonDecode(realText.substring(1, realText.length - 1));
      var nickName = map['name'] as String;
      showText = '@$nickName ';
    } catch (e) {
      showText = realText;
    }
    return SpecialTextSpan(
      // 昵称
      text: showText,
      // id
      actualText: realText,
      start: start,
      deleteAll: true,
      style: textStyle,
      recognizer: TapGestureRecognizer()
        ..onTap = () {
          _handleTap(realText);
        },
    );
  }

  void _handleTap(String text) {
    print("Tapped on: $text");
  }
}

/// #topic
class TopicText extends SpecialText {
  static const String flag = "#";
  final int start;

  TopicText(TextStyle textStyle, SpecialTextGestureTapCallback? onTap,
      {required this.start})
      : super(flag, " ", textStyle, onTap: onTap);

  @override
  TextSpan finishText() {
    TextStyle? textStyle = this
        .textStyle
        ?.copyWith(color: const Color(0xff007bbb), fontSize: 16.0);

    final String atText = toString();
    return SpecialTextSpan(
      text: atText,
      actualText: atText,
      start: start,
      deleteAll: true,
      style: textStyle,
      recognizer: TapGestureRecognizer()
        ..onTap = () {
          _handleTap(atText);
        },
    );
  }

  void _handleTap(String text) {
    print("Tapped on: $text");
  }
}

/// 『emoji』
class EmojiText extends SpecialText {
  static const String flag = "『";
  static const String flag2 = "』";
  static const double size = 20.0;
  final int start;

  EmojiText(TextStyle textStyle, SpecialTextGestureTapCallback? onTap,
      {required this.start})
      : super(flag, flag2, textStyle, onTap: onTap);

  @override
  InlineSpan finishText() {
    String emojiText = toString();
    emojiText = emojiText.replaceAll('\u200B', '');
    final String emojiUrl =
        EmojiMap.getEmojiUrl(emojiText.substring(1, emojiText.length - 1));
    if (emojiUrl.isEmpty) {
      return TextSpan(text: emojiText, style: textStyle);
    }
    return ImageSpan(
      NetworkImage(emojiUrl),
      actualText: emojiText,
      start: start,
      fit: BoxFit.fill,
      imageWidth: size,
      imageHeight: size,
    );
  }
}

class ReplyText extends SpecialText {
  static const String flag = "⟬";
  static const String flag2 = "⟭";
  final int start;

  ReplyText(TextStyle textStyle, SpecialTextGestureTapCallback? onTap,
      {required this.start})
      : super(flag, flag2, textStyle, onTap: onTap);

  @override
  TextSpan finishText() {
    TextStyle? textStyle = this
        .textStyle
        ?.copyWith(color: const Color(0xffadadad), fontSize: 16.0);
    String realText = toString();
    String showText = '';
    try {
      realText = realText.replaceAll('\u200B', '');
      Map<String, dynamic> map =
          jsonDecode(realText.substring(1, realText.length - 1));
      var nickName = map['name'] as String;
      showText = nickName.fixAutoLines();
    } catch (e) {
      Get.log('ReplyText error: $e');
      showText = realText;
    }
    return SpecialTextSpan(
      text: showText,
      actualText: realText,
      start: start,
      deleteAll: true,
      style: textStyle,
      recognizer: TapGestureRecognizer()
        ..onTap = () {
          _handleTap(realText);
        },
    );
  }

  void _handleTap(String text) {
    print("Tapped on: $text");
  }
}

// 用于复制时将特殊处理后的文本恢复到原始文本
String parseSpecialText(String text) {
  text = text.replaceAll('\u200B', '');
  // 将@{"name":"xxx","id":"xxx"} 转为 @xxx
  text = text.replaceAllMapped(RegExp(r'@\{"name":"(.+?)","id":"\d+"\}'),
      (Match match) => '@${match.group(1)}');
  text = text.replaceAllMapped(RegExp(r'⟬{"userId":"\d+","name":"(.+?)"}⟭'),
      (Match match) => '${match.group(1)}');
  return text;
}
