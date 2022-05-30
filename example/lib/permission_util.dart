import 'dart:io';

import 'package:permission_handler/permission_handler.dart';

class PermissionUtil {
  static Future<bool> check() async {
    if (Platform.isAndroid) {
      PermissionStatus status = await Permission.storage.status;
      if (status.isGranted) {
        return true;
      } else if (status.isPermanentlyDenied) {
        return false;
      } else {
        PermissionStatus requestStatus = await Permission.storage.request();
        if (requestStatus.isGranted) {
          return true;
        } else {
          return false;
        }
      }
    } else {
      return true;
    }
  }
}
