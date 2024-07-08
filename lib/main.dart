import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:xiaofanshu_flutter/pages/auth/login.dart';
import 'package:xiaofanshu_flutter/utils/Adapt.dart';

import 'bindings/controller_binding.dart';
import 'config/routes.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    Adapt.initialize(context);
    return GetMaterialApp(
      getPages: RouteConfig.routes,
      defaultTransition: Transition.rightToLeft,
      builder: EasyLoading.init(),
      initialBinding: ControllerBinding(),
      home: const LoginPage(),
    );
  }
}
