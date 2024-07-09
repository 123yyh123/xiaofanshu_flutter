import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:xiaofanshu_flutter/controller/retrieve_account_controller.dart';

import '../../utils/Adapt.dart';

class RetrieveAccountPage extends StatefulWidget {
  const RetrieveAccountPage({super.key});

  @override
  State<RetrieveAccountPage> createState() => _RetrieveAccountPageState();
}

class _RetrieveAccountPageState extends State<RetrieveAccountPage> {
  RetrieveAccountController retrieveAccountController =
  Get.find();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            IconButton(
              onPressed: () {
                Get.back();
              },
              icon: const Icon(Icons.arrow_back),
            ),
          ],
        ).paddingOnly(left: 10, right: 10),
      ),
      body: Column(
        children: [
          const Text('输入原手机号', style: TextStyle(fontSize: 25)).marginOnly(
            bottom: Adapt.setRpx(20),
          ),
          const Text(
            '我们将发送验证码到您的手机',
            style: TextStyle(
              color: Color(0xff999999),
              fontSize: 12,
            ),
          ),
          Obx(() =>
              TextField(
                controller: retrieveAccountController.phoneController,
                decoration: InputDecoration(
                  hintText: '请输入手机号',
                  hintStyle: const TextStyle(
                    color: Color(0xffCDCDCD),
                    fontSize: 18,
                  ),
                  enabledBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(color: Color(0xffEDEDED))),
                  focusedBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(color: Color(0xffEDEDED))),
                  suffixIcon: retrieveAccountController.phone.isNotEmpty
                      ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      retrieveAccountController.phoneController.clear();
                    },
                  )
                      : null,
                ),
                style: const TextStyle(
                    fontSize: 20, color: Color(0xff333333)),
                cursorColor: const Color(0xffFF2E4D),
                keyboardType: TextInputType.phone,
                inputFormatters: [
                  // 手机号校验，只允许输入数字
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                ],
              )),
        ],
      ),
    );
  }
}
