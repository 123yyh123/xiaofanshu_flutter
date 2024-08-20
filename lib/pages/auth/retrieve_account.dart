import 'package:amap_flutter_map/amap_flutter_map.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:amap_flutter_base/amap_flutter_base.dart';

import '../../bindings/controller_binding.dart';
import '../../config/amap_config.dart';
import '../../controller/location_controller.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Flutter Demo',
      home: const HomeView(),
      initialBinding: ControllerBinding(),
    );
  }
}

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  LocationController locationController = Get.find();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
      ),
      body: Column(
        children: <Widget>[
          const SizedBox(
            height: 50,
          ),
          SizedBox(
            height: 50,
            child: Obx(() => Text('纬度：${locationController.latitude.value}')),
          ),
          SizedBox(
            height: 50,
            child: Obx(() => Text('经度：${locationController.longitude.value}')),
          ),
          SizedBox(
            height: 50,
            child: ElevatedButton(
              onPressed: () async {
                Get.log('点击定位到当前位置');
                locationController.mapController?.moveCamera(
                  CameraUpdate.newLatLng(LatLng(
                    double.parse(locationController.latitude.value),
                    double.parse(locationController.longitude.value),
                  )),
                );
              },
              child: const Text('定位到当前位置'),
            ),
          ),
          SizedBox(
            height: 300,
            child: Obx(
              () => AMapWidget(
                apiKey: const AMapApiKey(
                  androidKey: AMapConfig.androidKey,
                  iosKey: AMapConfig.iosKey,
                ),
                privacyStatement: const AMapPrivacyStatement(
                  hasShow: true,
                  hasAgree: true,
                  hasContains: true,
                ),
                onMapCreated: (controller) {
                  CameraUpdate cameraUpdate = CameraUpdate.newCameraPosition(
                    CameraPosition(
                      target: LatLng(
                          double.parse(locationController.latitude.value),
                          double.parse(locationController.longitude.value)),
                      zoom: 16,
                      tilt: 0,
                      bearing: 0,
                    ),
                  );
                  controller.moveCamera(cameraUpdate);
                  locationController.mapController = controller;
                },
                markers: Set<Marker>.of(locationController.markerMap),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
