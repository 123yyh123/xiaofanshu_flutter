import 'package:get/get.dart';
import 'package:xiaofanshu_flutter/components/background_image_pre.dart';
import 'package:xiaofanshu_flutter/pages/auth/login.dart';
import 'package:xiaofanshu_flutter/pages/home/home.dart';
import 'package:xiaofanshu_flutter/pages/notesDetail/note_details_video.dart';

import '../components/image_preview.dart';
import '../pages/notesDetail/note_details_image.dart';

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
    GetPage(
      name: '/notes/detail/image',
      page: () => const NoteDetailsImage(),
    ),
    GetPage(
      name: '/notes/detail/video',
      page: () => const NoteDetailsVideo(),
    ),
  ];
}
