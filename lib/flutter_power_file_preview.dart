// You have generated a new plugin project without
// specifying the `--platforms` flag. A plugin project supports no platforms is generated.
// To add platforms, run `flutter create -t plugin --platforms <platforms> .` under the same
// directory. You can also find a detailed instruction on how to add platforms in the `pubspec.yaml` at https://flutter.dev/docs/development/packages-and-plugins/developing-packages#plugin-platforms.

import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_power_file_preview/src/enums/download_state.dart';
import 'package:flutter_power_file_preview/src/enums/engine_state.dart';
import 'package:flutter_power_file_preview/src/utils/download_util.dart';

class FlutterPowerFilePreview {
  static const MethodChannel _channel = MethodChannel('cn.vvkeep/flutter_power_file_preview');

  static final _engineInitController = StreamController<EngineState>.broadcast();
  static Stream<EngineState> get engineInitStream => _engineInitController.stream;

  static Future<String?> get platformVersion async {
    final String? version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  static Future<void> initEngine() async {
    if (!Platform.isAndroid) return;
    _channel.setMethodCallHandler(_handler);
    await _channel.invokeMethod<bool?>('initEngine');
  }

  static Future<EngineState?> engineState() async {
    if (Platform.isAndroid) {
      final int? i = await _channel.invokeMethod<int>('getEngineState');
      return EngineStateExtension.getType(i ?? -1);
    }
    return null;
  }

  static Future<void> downloadFile(
    String fileUrl,
    String filePath, {
    required Function(DownloadState value) callback,
    ProgressCallback? onProgress,
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
    bool? deleteOnError,
    String? lengthHeader,
    dynamic data,
    Options? options,
  }) async =>
      DownloadUtil.download(
        fileUrl,
        filePath,
        callback: callback,
        onProgress: onProgress,
        queryParameters: queryParameters,
        cancelToken: cancelToken,
        deleteOnError: deleteOnError ?? true,
        lengthHeader: lengthHeader ?? Headers.contentLengthHeader,
        data: data,
        options: options,
      );

  static Future<String?> getFileSize(
    BuildContext context,
    String fileUrl, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
    Options? options,
    String? fileSizeTip,
    String? fileSizeFailTip,
    String? fileSizeErrorTip,
  }) async =>
      DownloadUtil.fileSize(
        context,
        fileUrl,
        data: data,
        queryParameters: queryParameters,
        cancelToken: cancelToken,
        options: options,
        fileSizeTip: fileSizeTip,
        fileSizeErrorTip: fileSizeErrorTip,
        fileSizeFailTip: fileSizeFailTip,
      );

  static Future<void> _handler(MethodCall call) async {
    switch (call.method) {
      case 'engineState':
        _engineInitController.add(EngineStateExtension.getType(call.arguments as int));
        break;
      default:
        break;
    }
  }
}
