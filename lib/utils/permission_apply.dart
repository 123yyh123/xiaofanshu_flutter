import 'package:get/get_core/src/get_main.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionApply {
  static void requestPermission() async {
    // 申请权限
    var status = await Permission.camera.status;
    if (status.isDenied) {
      await Permission.camera.request();
    }
    var status1 = await Permission.photos.status;
    if (status1.isDenied) {
      await Permission.photos.request();
    }
    var status2 = await Permission.videos.status;
    if (status2.isDenied) {
      await Permission.videos.request();
    }
    await getPermissionStatus();
    var status3 = await Permission.manageExternalStorage.status;
    if (status3.isDenied) {
      await Permission.manageExternalStorage.request();
    }
  }
}

Future<bool> getPermissionStatus() async {
  Permission permission = Permission.microphone;
  //granted 通过，denied 被拒绝，permanentlyDenied 拒绝且不在提示
  PermissionStatus status = await permission.status;
  Get.log('permission status: $status');
  if (status.isGranted) {
    return true;
  } else if (status.isDenied) {
    requestPermission(permission);
  } else if (status.isPermanentlyDenied) {
    openAppSettings();
  } else if (status.isRestricted) {
    requestPermission(permission);
  } else {}
  return false;
}

///申请权限
void requestPermission(Permission permission) async {
  Get.log('requestPermission');
  PermissionStatus status = await permission.request();
  if (status.isPermanentlyDenied) {
    openAppSettings();
  }
}
