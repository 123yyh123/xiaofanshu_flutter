import 'package:amap_flutter_base/amap_flutter_base.dart';
import 'package:amap_flutter_map/amap_flutter_map.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:xiaofanshu_flutter/controller/location_controller.dart';
import 'package:xiaofanshu_flutter/controller/publish_notes_controller.dart';
import 'package:xiaofanshu_flutter/static/custom_color.dart';

import '../config/amap_config.dart';

class LocationPicker extends StatefulWidget {
  const LocationPicker({super.key});

  @override
  State<LocationPicker> createState() => _LocationPickerState();
}

class _LocationPickerState extends State<LocationPicker> {
  LocationController locationController = Get.find();
  PublishNotesController publishNotesController = Get.find();

  @override
  void dispose() {
    super.dispose();
    locationController.locationPlugin.stopLocation();
    locationController.locationPlugin.destroy();
    locationController.mapController.disponse();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          onPressed: () {
            Get.back();
          },
          icon: const Icon(
            Icons.arrow_back_ios,
            color: Colors.black54,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          color: Colors.white,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height / 2,
                width: double.infinity,
                child: Obx(
                  () => Stack(
                    children: [
                      AMapWidget(
                        compassEnabled: true,
                        apiKey: const AMapApiKey(
                          androidKey: AMapConfig.androidKey,
                          iosKey: AMapConfig.iosKey,
                        ),
                        privacyStatement: const AMapPrivacyStatement(
                          hasShow: true,
                          hasAgree: true,
                          hasContains: true,
                        ),
                        initialCameraPosition: CameraPosition(
                          target: LatLng(
                            double.parse(locationController.latitude.value),
                            double.parse(locationController.longitude.value),
                          ),
                          zoom: 12,
                        ),
                        onMapCreated: (controller) {
                          Get.log('地图创建完成');
                          locationController.mapController = controller;
                          locationController.isInitComplete = true;
                        },
                        markers: locationController.markerMap.toSet(),
                      ),
                      locationController.isInitComplete &&
                              locationController.isMoved
                          ? Positioned(
                              right: 5,
                              bottom: 5,
                              child: IconButton(
                                onPressed: () {
                                  Get.log('点击定位到当前位置');
                                  locationController.mapController.moveCamera(
                                    CameraUpdate.newLatLng(
                                      LatLng(
                                        double.parse(
                                            locationController.latitude.value),
                                        double.parse(
                                            locationController.longitude.value),
                                      ),
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.my_location,
                                    color: Colors.blue),
                              ),
                            )
                          : const SizedBox(),
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height / 2,
                child: Obx(
                  () => Column(
                    children: [
                      _searchBar(),
                      _locationList(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _searchBar() {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: const Color(0XFFf3f3f2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              maxLength: 15,
              maxLines: 1,
              controller: locationController.searchController,
              decoration: const InputDecoration(
                counter: Offstage(),
                hintText: '搜索地址',
                border: InputBorder.none,
              ),
              cursorColor: CustomColor.primaryColor,
              cursorHeight: 20,
              style: const TextStyle(fontSize: 14),
            ),
          ),
          IconButton(
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            onPressed: () {
              locationController.searchLocation();
            },
            icon: const Icon(Icons.search),
          ),
        ],
      ).paddingOnly(left: 15, right: 10),
    ).paddingAll(10);
  }

  Widget _locationList() {
    return Expanded(
      child: ListView.builder(
        controller: locationController.peripheralScrollController,
        padding: const EdgeInsets.all(10),
        itemCount: locationController.locationList.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(locationController.locationList[index]['name']!),
            subtitle: Text(locationController.locationList[index]['address']!),
            onTap: () {
              Get.log(
                  '点击地址：${locationController.locationList[index]['longitude']},'
                  '${locationController.locationList[index]['latitude']}');
              publishNotesController.selectedLocationName.value =
                  locationController.locationList[index]['name']!;
              publishNotesController.latitude.value = double.parse(
                  locationController.locationList[index]['latitude']!);
              publishNotesController.longitude.value = double.parse(
                  locationController.locationList[index]['longitude']!);
              Get.back();
            },
          );
        },
      ),
    );
  }
}
