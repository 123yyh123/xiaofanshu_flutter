import 'package:get/get.dart';
import 'package:xiaofanshu_flutter/components/background_image_pre.dart';
import 'package:xiaofanshu_flutter/components/location_picker.dart';
import 'package:xiaofanshu_flutter/components/video_horizontal_pre.dart';
import 'package:xiaofanshu_flutter/pages/auth/login.dart';
import 'package:xiaofanshu_flutter/pages/home/home.dart';
import 'package:xiaofanshu_flutter/pages/home/mine/attention_fans.dart';
import 'package:xiaofanshu_flutter/pages/notesDetail/note_details_video.dart';
import 'package:xiaofanshu_flutter/pages/publish/publish_note.dart';

import '../bindings/controller_binding.dart';
import '../components/image_preview.dart';
import '../pages/notesDetail/note_details_image.dart';
import '../pages/publish/video_clip.dart';

class RouteConfig {
  static final routes = [
    GetPage(
      name: '/login',
      page: () => const LoginPage(),
    ),
    GetPage(
      name: '/home',
      page: () => const HomePage(),
      binding: ControllerBinding(),
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
      name: '/image/simple/pre',
      page: () => const SimpleImagePre(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: '/notes/detail/image',
      page: () => const NoteDetailsImage(),
      transition: Transition.circularReveal,
      binding: ControllerBinding(),
    ),
    GetPage(
      name: '/notes/detail/video',
      page: () => const NoteDetailsVideo(),
      transition: Transition.circularReveal,
      binding: ControllerBinding(),
    ),
    GetPage(
      name: '/videoPlayer',
      page: () => const VideoHorizontalPre(),
      transition: Transition.fadeIn,
      binding: ControllerBinding(),
    ),
    GetPage(
      name: '/publish/notes',
      page: () => const PublishNotes(),
      transition: Transition.fadeIn,
      binding: ControllerBinding(),
    ),
    GetPage(
      name: '/video/clip',
      page: () => const VideoEditor(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: '/video/simple/pre',
      page: () => const SimpleVideoPre(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: '/location/picker',
      page: () => const LocationPicker(),
      transition: Transition.fadeIn,
      binding: ControllerBinding(),
    ),
    GetPage(
      name: '/relation',
      page: () => const AttentionFans(),
      transition: Transition.fadeIn,
      binding: ControllerBinding(),
    ),
  ];
}
