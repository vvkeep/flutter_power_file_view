import 'dart:async';
import 'dart:io';

import 'package:power_file_view/power_file_view.dart';

import 'constant/constants.dart';

class PowerFileViewModel {
  String? downloadUrl;

  String filePath;

  final Function(PowerViewType type) viewTypeChanged;

  final Function(int progress) progressChanged;

  late final String fileType = FileUtil.getFileType(filePath);

  late bool _isLocalExists = FileUtil.isExistsFile(filePath);

  PowerViewType _viewType = PowerViewType.none;

  late StreamSubscription<EngineState> stateSubscription;
  late StreamSubscription<int> progressSubscription;

  int progress = 0;

  final CancelToken cancelToken = CancelToken();

  PowerFileViewModel({
    required this.filePath,
    this.downloadUrl,
    required this.viewTypeChanged,
    required this.progressChanged,
  }) {
    powerPrint('downloadUrl: $downloadUrl, downloadPath: $filePath');
    addListenStream();
  }

  void addListenStream() {
    stateSubscription = PowerFileViewManager.engineInitStream.listen((EngineState e) async {
      powerPrint('engineInitStream state: ${EngineStateExtension.description(e)}');
      if (_viewType == PowerViewType.engineLoading) {
        await updateViewType();
        viewTypeChanged(_viewType);
      }
    });

    progressSubscription = PowerFileViewManager.engineDownloadStream.listen((int progress) async {
      powerPrint('engineDownloadStream progress: $progress');
      this.progress = progress;
      if (_viewType == PowerViewType.engineLoading) {
        progressChanged(progress);
      }
    });
  }

  void clearTask() {
    stateSubscription.cancel();
    progressSubscription.cancel();
    if (!cancelToken.isCancelled) {
      cancelToken.cancel();
    }
  }

  Future<void> reset() async {
    if (_viewType == PowerViewType.engineFail) {
      PowerFileViewManager.resetEngine();
    }

    await updateViewType();
  }

  updateViewType() async {
    _viewType = await _getViewType;
  }

  PowerViewType get getViewType => _viewType;

  Future<PowerViewType> get _getViewType async {
    if (!_isSupportPlatform) {
      return PowerViewType.unsupportedPlatform;
    }

    if (!_isSupportFileType) {
      return PowerViewType.unsupportedType;
    }

    if (Platform.isAndroid) {
      EngineState? state = await PowerFileViewManager.engineState();
      powerPrint('get engineState: ${state != null ? EngineStateExtension.description(state) : 'null'}');
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

    if (downloadUrl == null) {
      return PowerViewType.fileFail;
    }

    int? size = await DownloadUtil.fileSize(downloadUrl!, cancelToken: cancelToken);
    if (size == null) {
      powerPrint("get file size error");
      return PowerViewType.fileFail;
    }

    powerPrint("download file size: ${FileUtil.fileSize(size)}");
    DownloadUtil.download(downloadUrl!, filePath, cancelToken: cancelToken, onProgress: (count, total) {
      final value = (count.toDouble() / total.toDouble() * 100).toInt();
      if (_viewType == PowerViewType.fileLoading) {
        progressChanged(value);
      }
    }, callback: (state) {
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

  String getMsg(PowerLocalizations local) {
    switch (_viewType) {
      case PowerViewType.none:
        return local.loading;
      case PowerViewType.unsupportedPlatform:
        return local.unsupportedPlatform;
      case PowerViewType.nonExistent:
        return local.nonExistent;
      case PowerViewType.unsupportedType:
        return sprintf(local.unsupportedType, fileType);
      case PowerViewType.engineLoading:
        return sprintf(local.engineLoading, '$progress');
      case PowerViewType.engineFail:
        return local.engineFail;
      case PowerViewType.fileLoading:
        return sprintf(local.fileLoading, '$progress');
      case PowerViewType.fileFail:
        return local.fileFail;
      case PowerViewType.done:
        return '';
    }
  }

  String sprintf(String stringtf, String msg) {
    return stringtf.replaceAll('%s', msg);
  }
}
