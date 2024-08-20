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
    var status3 = await Permission.manageExternalStorage.status;
    if (status3.isDenied) {
      await Permission.manageExternalStorage.request();
    }
  }
}
