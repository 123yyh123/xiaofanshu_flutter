import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:xiaofanshu_flutter/utils/Adapt.dart';

// 发送验证码 按钮
class SendSmsBtn extends StatefulWidget {
  final Future<bool> Function()? onTap;

  const SendSmsBtn({
    super.key,
    this.onTap,
  });

  @override
  State<SendSmsBtn> createState() => _SendSmsBtnState();
}

class _SendSmsBtnState extends State<SendSmsBtn> {
  int countdown = 60;
  Timer? timer;

  void sendRegisterMsgCode() {
    if (countdown == 60) {
      countdown--;
      setState(() {});
      timer?.cancel();
      timer = null;
      timer ??= Timer.periodic(const Duration(seconds: 1), (timer) {
        countdown--;
        if (countdown == 0) {
          timer.cancel();
          countdown = 60;
        }
        setState(() {});
      });
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    timer = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return countdown == 60
        ? InkWell(
            onTap: () async {
              //  AppToast.showLoading();
              final s = await widget.onTap?.call() ?? false;
              // AppToast.closeAllLoading();
              if (s) {
                sendRegisterMsgCode();
              }
            },
            child: Container(
              width: Adapt.setRpx(200),
              // Adapt.px(123
              height: Adapt.setRpx(30),
              // Adapt.px(43),
              alignment: Alignment.center,
              padding: const EdgeInsets.all(5),
              child: const Text(
                "发送验证码",
                style: TextStyle(color: Color(0xff89c3eb), fontSize: 14),
              ),
            ).marginAll(4),
          )
        : Container(
            width: Adapt.setRpx(200),
            height: Adapt.setRpx(30),
            alignment: Alignment.center,
            padding: const EdgeInsets.all(5),
            child: Text(
              "$countdown s重新获取",
              style: const TextStyle(color: Color(0xff999999), fontSize: 14),
            ),
          );
  }
}
