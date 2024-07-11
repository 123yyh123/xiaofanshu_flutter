import 'package:get/get.dart';
import 'package:xiaofanshu_flutter/pages/auth/login.dart';
import 'package:xiaofanshu_flutter/pages/home/home.dart';

class RouteConfig {
  static final routes = [
    GetPage(
      name: '/login',
      page: () => const LoginPage(),
    ),
    GetPage(
      name: '/home',
      page: () => const HomePage(),
    )
  ];
}
