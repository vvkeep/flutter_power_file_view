import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:power_file_view/power_file_view.dart';

class PowerFileViewModel {
  final String downloadUrl;

  final String filePath;

  final Function(PowerViewType type) viewTypeChanged;

  late final String fileType = FileUtil.getFileType(filePath);

  late bool _isLocalExists = FileUtil.isExistsFile(filePath);

  PowerFileViewModel({required this.downloadUrl, required this.filePath, required this.viewTypeChanged}) {
    debugPrint('downloadUrl: $downloadUrl, downloadPath: $filePath');
  }

  Future<EngineState?> engineState() async {
    final state = await PowerFileViewManager.engineState();
    return state;
  }

  Future<PowerViewType> get getViewType async {
    // 判断是否支持的平台
    if (!_isSupportPlatform) {
      return PowerViewType.unsupportedPlatform;
    }

    // 判断是否支持的文件类型
    if (!_isSupportFileType) {
      return PowerViewType.unsupportedType;
    }

    // Android 判断引擎状态
    if (Platform.isAndroid) {
      EngineState? state = await PowerFileViewManager.engineState();
      if (state == null) {
        return PowerViewType.engineFail;
      }

      switch (state) {
        case EngineState.done:
          return _viewTypeByLoadFile;
        case EngineState.none:
          PowerFileViewManager.initEngine();
          return PowerViewType.engineLoading;
        case EngineState.start:
        case EngineState.downloading:
        case EngineState.downloadSuccess:
        case EngineState.installSuccess:
          return PowerViewType.engineLoading;
        case EngineState.downloadFail:
        case EngineState.installFail:
        case EngineState.error:
          return PowerViewType.engineFail;
      }
    } else {
      return _viewTypeByLoadFile;
    }
  }

  Future<PowerViewType> get _viewTypeByLoadFile async {
    if (_isLocalExists) {
      return PowerViewType.done;
    }

    int? size = await DownloadUtil.fileSize(downloadUrl);
    debugPrint("download file size: ${FileUtil.fileSize(size)}");
    DownloadUtil.download(downloadUrl, filePath, callback: (state) {
      if (state == DownloadState.error || state == DownloadState.fail) {
        viewTypeChanged(PowerViewType.fileFail);
      } else if (state == DownloadState.done) {
        _isLocalExists = true;
        viewTypeChanged(PowerViewType.done);
      }
    });
    return PowerViewType.fileLoading;
  }

  bool get _isSupportPlatform => Platform.isAndroid || Platform.isIOS;

  bool get _isSupportFileType => FileUtil.isSupportOpen(fileType);
}
