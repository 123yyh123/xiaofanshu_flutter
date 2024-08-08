import 'package:get/get.dart';
import 'package:xiaofanshu_flutter/components/background_image_pre.dart';
import 'package:xiaofanshu_flutter/pages/auth/login.dart';
import 'package:xiaofanshu_flutter/pages/home/home.dart';

import '../components/image_preview.dart';

class RouteConfig {
  static final routes = [
    GetPage(
      name: '/login',
      page: () => const LoginPage(),
    ),
    GetPage(
      name: '/home',
      page: () => const HomePage(),
    ),
    GetPage(
      name: '/image/preview',
      page: () => const ImagePreview(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: '/image/backgroundPreview',
      page: () => const BackgroundImagePre(),
      transition: Transition.fadeIn,
    ),
  ];
}
