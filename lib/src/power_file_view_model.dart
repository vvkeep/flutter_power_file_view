import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:power_file_view/power_file_view.dart';

class PowerFileViewModel {
  final String downloadUrl;

  final String filePath;

  final Function(PowerViewType type) viewTypeChanged;

  final Function(int progress) progressChanged;

  late final String fileType = FileUtil.getFileType(filePath);

  late bool _isLocalExists = FileUtil.isExistsFile(filePath);

  PowerViewType _viewType = PowerViewType.none;

  late StreamSubscription<EngineState> stateSubscription;
  late StreamSubscription<int> progressSubscription;

  int progress = 0;

  PowerFileViewModel(
      {required this.downloadUrl,
      required this.filePath,
      required this.viewTypeChanged,
      required this.progressChanged}) {
    debugPrint('downloadUrl: $downloadUrl, downloadPath: $filePath');
    addListenStream();
  }

  void addListenStream() {
    stateSubscription = PowerFileViewManager.engineInitStream.listen((EngineState e) async {
      debugPrint('engineInitStream state: ${EngineStateExtension.description(e)}');
      if (_viewType == PowerViewType.engineLoading) {
        await updateViewType();
        viewTypeChanged(_viewType);
      }
    });

    progressSubscription = PowerFileViewManager.engineDownloadStream.listen((int progress) async {
      debugPrint('engineDownloadStream progress: $progress');
      this.progress = progress;
      if (_viewType == PowerViewType.engineLoading) {
        progressChanged(progress);
      }
    });
  }

  void removeListenStream() {
    stateSubscription.cancel();
    progressSubscription.cancel();
  }

  updateViewType() async {
    _viewType = await _getViewType;
  }

  PowerViewType get getViewType => _viewType;

  Future<PowerViewType> get _getViewType async {
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

      debugPrint('get engineState: ${EngineStateExtension.description(state)}');
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