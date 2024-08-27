import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:lifecycle_lite/life_navigator_observer.dart';
import 'package:tencent_calls_uikit/tuicall_kit.dart';
import 'package:xiaofanshu_flutter/controller/websocket_controller.dart';
import 'package:xiaofanshu_flutter/pages/auth/login.dart';
import 'package:xiaofanshu_flutter/pages/home/home.dart';
import 'package:xiaofanshu_flutter/utils/Adapt.dart';
import 'package:xiaofanshu_flutter/utils/store_util.dart';

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
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('zh', 'CN'),
        Locale('en', 'US'),
      ],
      navigatorObservers: [
        LifeNavigatorObserver(),
        TUICallKit.navigatorObserver,
      ],
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        tabBarTheme: const TabBarTheme(dividerColor: Colors.transparent),
        buttonTheme: const ButtonThemeData(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
        ),
      ),
      getPages: RouteConfig.routes,
      defaultTransition: Transition.rightToLeft,
      builder: EasyLoading.init(),
      initialBinding: ControllerBinding(),
      home: const InitializationPage(),
    );
  }
}

class InitializationPage extends StatefulWidget {
  const InitializationPage({super.key});

  @override
  State<InitializationPage> createState() => _InitializationPageState();
}

class _InitializationPageState extends State<InitializationPage> {
  WebsocketController websocketController =
      Get.put(WebsocketController(), permanent: true);

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    readData('token').then((value) {
      Future.delayed(const Duration(milliseconds: 500), () {
        if (value != null && value != '') {
          Get.offAllNamed('/home');
        } else {
          Get.offAllNamed('/login');
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
