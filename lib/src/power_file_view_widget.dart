import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:power_file_view/src/constant/enums.dart';
import 'package:power_file_view/src/i18n/power_localizations.dart';
import 'package:power_file_view/src/power_file_view_manager.dart';
import 'package:power_file_view/src/power_file_view_model.dart';
import 'package:power_file_view/src/widget/power_error_widget.dart';
import 'package:power_file_view/src/widget/power_loading_widget.dart';

import 'constant/constants.dart';

class PowerFileViewWidget extends StatefulWidget {
  final String downloadUrl;

  final String filePath;

  const PowerFileViewWidget({Key? key, required this.downloadUrl, required this.filePath}) : super(key: key);

  @override
  State<PowerFileViewWidget> createState() => _PowerFileViewWidgetState();
}

class _PowerFileViewWidgetState extends State<PowerFileViewWidget> {
  late PowerLocalizations local = PowerLocalizations.of(context);

  late PowerFileViewModel _viewModel;

  PowerViewType viewType = PowerViewType.none;
  final CancelToken cancelToken = CancelToken();

  @override
  void initState() {
    super.initState();
    _viewModel = PowerFileViewModel(
      downloadUrl: widget.downloadUrl,
      filePath: widget.filePath,
      viewTypeChanged: (type) {
        updatePowerViewType(viewType: type);
      },
    );

    updatePowerViewType();
  }

  void updatePowerViewType({PowerViewType? viewType}) async {
    final tempViewType = viewType ?? await _viewModel.getViewType;
    setState(() {
      viewType = tempViewType;
    });
  }

  void addListen() {
    PowerFileViewManager.engineInitStream.listen((EngineState e) async {
      debugPrint('engineInitStream state: ${EngineStateExtension.description(e)}');
    });

    PowerFileViewManager.engineDownloadStream.listen((int progress) {
      debugPrint('engineDownloadStream progress: $progress');
    });
  }

  @override
  void dispose() {
    super.dispose();
    if (!cancelToken.isCancelled) {
      cancelToken.cancel('The page is closed.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return _buildPowerFileWidget();
  }

  Widget _buildPowerFileWidget() {
    switch (viewType) {
      case PowerViewType.none:
      case PowerViewType.engineLoading:
      case PowerViewType.fileLoading:
        return PowerLoadingWidget(viewType: viewType);
      case PowerViewType.unsupportedPlatform:
      case PowerViewType.nonExistent:
      case PowerViewType.unsupportedType:
      case PowerViewType.engineFail:
      case PowerViewType.fileFail:
        return PowerErrorWidget(viewType: viewType);
      case PowerViewType.done:
        if (Platform.isAndroid) {
          return _createAndroidView();
        } else {
          return _createIOSView();
        }
    }
  }

  Widget _createAndroidView() {
    return AndroidView(
      viewType: Constants.viewName,
      creationParams: <String, dynamic>{
        'filePath': _viewModel.filePath,
        'fileType': _viewModel.fileType,
      },
      creationParamsCodec: const StandardMessageCodec(),
    );
  }

  Widget _createIOSView() {
    return UiKitView(
      viewType: Constants.viewName,
      creationParams: <String, String>{
        'filePath': _viewModel.filePath,
        'fileType': _viewModel.fileType,
      },
      creationParamsCodec: const StandardMessageCodec(),
    );
  }
}
