// You have generated a new plugin project without
// specifying the `--platforms` flag. A plugin project supports no platforms is generated.
// To add platforms, run `flutter create -t plugin --platforms <platforms> .` under the same
// directory. You can also find a detailed instruction on how to add platforms in the `pubspec.yaml` at https://flutter.dev/docs/development/packages-and-plugins/developing-packages#plugin-platforms.

import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:power_file_view/src/constant/enums.dart';
import 'package:power_file_view/src/utils/download_util.dart';

import 'constant/constants.dart';

class PowerFileViewManager {
  static const MethodChannel _channel = MethodChannel(Constants.channelName);

  static final _engineInitController = StreamController<EngineState>.broadcast();
  static Stream<EngineState> get engineInitStream => _engineInitController.stream;

  static final _engineDownloadProgressController = StreamController<int>.broadcast();
  static Stream<int> get engineDownloadStream => _engineDownloadProgressController.stream;

  static Future<String?> get platformVersion async {
    final String? version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  static bool logEnable = true;

  static Future<void> initLogEnable(bool log, bool pluginLog) async {
    logEnable = log;
    await _channel.invokeMethod('pluginLogEnable', pluginLog);
  }

  /// Initialize the engine, this method is only valid for the Andorid platform, iOS does not need to call
  ///
  /// 初始化引擎，此方法只针对Andorid平台有效，iOS无需调用
  /// 1. 判断手机是是否加载陈宫
  static Future<void> initEngine() async {
    if (!Platform.isAndroid) return;
    _channel.setMethodCallHandler(_handler);
    await _channel.invokeMethod<bool?>('initEngine');
  }

  static Future<void> resetEngine() async {
    if (!Platform.isAndroid) return;
    await _channel.invokeMethod<bool?>('resetEngine');
  }

  static Future<void> refreshView() async {
    if (!Platform.isAndroid) return;
    await _channel.invokeMethod<bool?>('refreshView');
  }

  /// Get the engine status in real time, this method is only valid for Andorid platform, iOS does not need to call
  ///
  /// 实时获取引擎状态，此方法只针对Andorid平台有效，iOS无需调用
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
        callback: (value) => callback(value),
        onProgress: onProgress,
        queryParameters: queryParameters,
        cancelToken: cancelToken,
        deleteOnError: deleteOnError ?? true,
        lengthHeader: lengthHeader ?? Headers.contentLengthHeader,
        data: data,
        options: options,
      );

  static Future<int?> getFileSize(
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
        final type = EngineStateExtension.getType(call.arguments as int);
        debugPrint('engineState callback: ${EngineStateExtension.description(type)}');
        _engineInitController.add(type);
        break;
      case 'engineDownloadProgress':
        int progress = call.arguments as int;
        debugPrint('engineDownloadProgress callback: $progress');
        _engineDownloadProgressController.add(progress);
        break;
      default:
        break;
    }
  }
}
