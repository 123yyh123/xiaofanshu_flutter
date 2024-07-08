import 'package:get/get.dart';
import 'package:xiaofanshu_flutter/pages/auth/login.dart';

class RouteConfig {
  static final routes = [
    GetPage(
      name: '/login',
      page: () => const LoginPage(),
    )
  ];
}
