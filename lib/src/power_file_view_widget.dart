import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:power_file_view/src/constant/enums.dart';
import 'package:power_file_view/src/i18n/power_localizations.dart';
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

  final CancelToken cancelToken = CancelToken();

  @override
  void initState() {
    super.initState();
    _viewModel = PowerFileViewModel(
        downloadUrl: widget.downloadUrl,
        filePath: widget.filePath,
        viewTypeChanged: (type) {
          updatePowerViewType(type: type);
        },
        progressChanged: (progress) {
          setState(() {});
        });

    updatePowerViewType();
  }

  void updatePowerViewType({PowerViewType? type}) async {
    await _viewModel.updateViewType();
    setState(() {});
  }

  @override
  void dispose() {
    super.dispose();
    _viewModel.removeListenStream();
    if (!cancelToken.isCancelled) {
      cancelToken.cancel('The page is closed.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return _buildPowerFileWidget();
  }

  Widget _buildPowerFileWidget() {
    final viewType = _viewModel.getViewType;
    switch (viewType) {
      case PowerViewType.none:
      case PowerViewType.engineLoading:
      case PowerViewType.fileLoading:
        return PowerLoadingWidget(viewType: viewType, progress: _viewModel.progress);
      case PowerViewType.unsupportedPlatform:
      case PowerViewType.nonExistent:
      case PowerViewType.unsupportedType:
      case PowerViewType.engineFail:
      case PowerViewType.fileFail:
        return PowerErrorWidget(
          viewType: viewType,
          retryOnTap: () {},
        );
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
