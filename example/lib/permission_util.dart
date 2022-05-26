import 'dart:io';

import 'package:permission_handler/permission_handler.dart';

class PermissionUtil {
  /// 申请读取文件权限(android：相册、文件，ios：相册)
  static Future<bool> checkPhotos() async {
    if (Platform.isAndroid) {
      PermissionStatus status = await Permission.storage.status;
      if (status.isGranted) {
        return true;
      } else if (status.isPermanentlyDenied) {
        // 该权限被永久拒绝 => 弹框告知是否跳转设置权限
        _showDialog("读写文件");
        return false;
      } else {
        // 重新请求权限
        PermissionStatus requestStatus = await Permission.storage.request();
        if (requestStatus.isGranted) {
          return true;
        } else {
          // 二次权限拒绝 => 弹框告知是否跳转设置权限
          _showDialog("读写文件");
          return false;
        }
      }
    } else {
      // iOS平台，只能访问相册
      PermissionStatus status = await Permission.photos.status;
      if (status.isGranted) {
        return true;
      } else if (status.isPermanentlyDenied) {
        // 该权限被永久拒绝 => 弹框告知是否跳转设置权限
        _showDialog("读写相册");
        return false;
      } else {
        // 重新请求权限
        PermissionStatus requestStatus = await Permission.photos.request();
        if (requestStatus.isGranted) {
          return true;
        } else {
          // 二次权限拒绝 => 弹框告知是否跳转设置权限
          _showDialog("读写相册");
          return false;
        }
      }
    }
  }

  static Future<bool> checkCamera() async {
    // iOS平台，只能访问相册
    PermissionStatus status = await Permission.camera.status;
    if (status.isGranted) {
      return true;
    } else if (status.isPermanentlyDenied) {
      // 该权限被永久拒绝 => 弹框告知是否跳转设置权限
      _showDialog("相机");
      return false;
    } else {
      // 重新请求权限
      PermissionStatus requestStatus = await Permission.photos.request();
      if (requestStatus.isGranted) {
        return true;
      } else {
        // 二次权限拒绝 => 弹框告知是否跳转设置权限
        _showDialog("相机");
        return false;
      }
    }
  }

  static void _showDialog(String permissionName) {}
}
