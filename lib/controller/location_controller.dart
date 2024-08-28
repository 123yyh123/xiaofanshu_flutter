import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:amap_flutter_location/amap_flutter_location.dart';
import 'package:amap_flutter_location/amap_location_option.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:amap_flutter_map/amap_flutter_map.dart';
import 'package:amap_flutter_base/amap_flutter_base.dart';
import 'package:xiaofanshu_flutter/apis/app.dart';
import 'package:xiaofanshu_flutter/utils/snackbar_util.dart';
import '../config/amap_config.dart';
import '../model/user.dart';
import '../static/default_data.dart';
import '../utils/image_util.dart';
import '../utils/store_util.dart';

class LocationController extends GetxController {
  // 默认为北京
  var latitude = '39.919926'.obs; //纬度
  var longitude = '116.397245'.obs; //经度
  var markerMap = <Marker>{}.obs;

  //实例化插件
  final AMapFlutterLocation locationPlugin = AMapFlutterLocation();

  late AMapController mapController;

  late StreamSubscription _locationListener;

  var isInitComplete = false;
  var isMoved = false;
  var locationList = List<Map<String, String>>.empty().obs;
  var page = 1.obs;
  var isLoadLocationList = false.obs;
  var hasMore = true.obs;
  ScrollController peripheralScrollController = ScrollController();
  TextEditingController searchController = TextEditingController();

  @override
  Future<void> onInit() async {
    Get.log('LocationController初始化');
    super.onInit();
    await requestPermission();
    AMapFlutterLocation.updatePrivacyAgree(true);
    AMapFlutterLocation.updatePrivacyShow(true, true);
    AMapFlutterLocation.setApiKey(AMapConfig.androidKey, AMapConfig.iosKey);
    Get.log('开始监听定位信息');
    _locationListener = locationPlugin
        .onLocationChanged()
        .listen((Map<String, Object> event) async {
      Get.log('定位信息：$event');
      latitude.value = event['latitude'].toString();
      longitude.value = event['longitude'].toString();
      if (!isInitComplete || isMoved) {
        return;
      }
      // 移动地图到当前位置，只执行一次
      CameraUpdate cameraUpdate = CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(
              double.parse(latitude.value), double.parse(longitude.value)),
          zoom: 12,
          tilt: 0,
          bearing: 0,
        ),
      );
      mapController.moveCamera(cameraUpdate);
      isMoved = true;
      String avatar = jsonDecode(await readData('userInfo') ??
          jsonEncode(DefaultData.user))['avatarUrl'];
      ByteData myByteData = await MapImageUtil.urlToImage(
        networkImage: avatar,
        devicePixelRatio: AMapUtil.devicePixelRatio,
        pixelRatio: AMapUtil.devicePixelRatio,
        size: const Size(200, 200),
      );
      markerMap.add(Marker(
        position:
            LatLng(double.parse(latitude.value), double.parse(longitude.value)),
        icon: BitmapDescriptor.fromBytes(myByteData.buffer.asUint8List()),
      ));
      loadLocationList();
      peripheralScrollController.addListener(() {
        if (peripheralScrollController.position.pixels ==
            peripheralScrollController.position.maxScrollExtent) {
          loadLocationList();
        }
      });
    });
    _setLocationOption();
    locationPlugin.startLocation();
  }

  loadLocationList({String keyword = ''}) async {
    if (isLoadLocationList.value || !hasMore.value) {
      Get.log('正在加载或没有更多数据');
      Get.log('isLoadLocationList: ${isLoadLocationList.value}');
      Get.log('hasMore: ${hasMore.value}');
      return;
    }
    String location = '${latitude.value},${longitude.value}';
    Get.log('location: $location');
    isLoadLocationList.value = true;
    Map<String, dynamic> result = await ThirdApi.getPeripheralInformation(
        location, page.value,
        keywords: keyword);
    if (result['status'] != "1") {
      SnackbarUtil.showError('获取周边信息失败');
      return;
    }
    List<dynamic> list = result['pois'];
    if (list.isEmpty) {
      hasMore.value = false;
      return;
    }
    for (var element in list) {
      Get.log('element: $element');
      Map<String, String> location = {
        'name': element['name'].toString(),
        'address': element['address'].toString(),
        'longitude': element['location'].toString().split(',')[0],
        'latitude': element['location'].toString().split(',')[1],
      };
      locationList.add(location);
    }
    page.value++;
    isLoadLocationList.value = false;
  }

//  动态申请定位权限
  Future<void> requestPermission() async {
    // 申请权限
    bool hasLocationPermission = await requestLocationPermission();
    if (hasLocationPermission) {
      Get.log('定位权限已授予');
    } else {
      Get.log('定位权限未授予');
    }
  }

  //  申请定位权限  授予定位权限返回true， 否则返回false
  Future<bool> requestLocationPermission() async {
    //获取当前的权限
    var status = await Permission.location.status;
    if (status == PermissionStatus.granted) {
      //已经授权
      return true;
    } else {
      //未授权则发起一次申请
      status = await Permission.location.request();
      if (status == PermissionStatus.granted) {
        return true;
      } else {
        return false;
      }
    }
  }

  //设置定位参数
  void _setLocationOption() {
    AMapLocationOption locationOption = AMapLocationOption();

    ///是否单次定位
    locationOption.onceLocation = false;

    ///是否需要返回逆地理信息
    locationOption.needAddress = true;

    ///逆地理信息的语言类型
    locationOption.geoLanguage = GeoLanguage.DEFAULT;

    locationOption.desiredLocationAccuracyAuthorizationMode =
        AMapLocationAccuracyAuthorizationMode.ReduceAccuracy;

    locationOption.fullAccuracyPurposeKey = "AMapLocationScene";

    ///设置Android端连续定位的定位间隔
    locationOption.locationInterval = 2000;

    ///设置Android端的定位模式<br>
    ///可选值：<br>
    ///<li>[AMapLocationMode.Battery_Saving]</li>
    ///<li>[AMapLocationMode.Device_Sensors]</li>
    ///<li>[AMapLocationMode.Height_Accuracy]</li>
    locationOption.locationMode = AMapLocationMode.Hight_Accuracy;

    ///设置iOS端的定位最小更新距离<br>
    locationOption.distanceFilter = -1;

    ///设置iOS端期望的定位精度
    /// 可选值：<br>
    /// <li>[DesiredAccuracy.Best] 最高精度</li>
    /// <li>[DesiredAccuratForNavigation] 适用于导航场景的高精度 </li>
    /// <li>[DesiredAccuracy.NearestTenMeters] 10米 </li>
    /// <li>[DesiredAccuracy.Kilometer] 1000米</li>
    /// <li>[DesiredAccuracy.ThreeKilometers] 3000米</li>
    locationOption.desiredAccuracy = DesiredAccuracy.Best;

    ///设置iOS端是否允许系统暂停定位
    locationOption.pausesLocationUpdatesAutomatically = false;

    ///将定位参数设置给定位插件
    locationPlugin.setLocationOption(locationOption);
  }

  void startLocation() {
    locationPlugin.startLocation();
  }

  void addMarker(Marker marker) {
    markerMap.add(marker);
  }

  void searchLocation() {
    String keyword = searchController.text;
    page.value = 1;
    hasMore.value = true;
    isLoadLocationList.value = false;
    locationList.clear();
    loadLocationList(keyword: keyword);
  }
}
