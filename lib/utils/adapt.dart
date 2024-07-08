import 'package:flutter/material.dart';

class Adapt {
  static MediaQueryData _mediaQueryData = const MediaQueryData();
  static double _screenWidth = 0;
  static double _screenHeight = 0;
  static double _rpx = 0;
  static double _px = 0;

  static void initialize(BuildContext context, {double standardWidth = 750}) {
    _mediaQueryData = MediaQuery.of(context);
    _screenWidth = _mediaQueryData.size.width;
    _screenHeight = _mediaQueryData.size.height;
    _rpx = _screenWidth / standardWidth;
    _px = _screenWidth / standardWidth * 2;
  }

  // 按照像素来设置
  static double setPx(double size) {
    return Adapt._rpx * size * 2;
  }

  // 按照rxp来设置
  static double setRpx(double size) {
    return Adapt._rpx * size;
  }
}
