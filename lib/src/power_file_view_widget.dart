import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:power_file_view/power_file_view.dart';
import 'package:power_file_view/src/power_file_view_model.dart';
import 'package:power_file_view/src/widget/power_error_widget.dart';
import 'package:power_file_view/src/widget/power_loading_widget.dart';

import 'constant/constants.dart';

typedef PowerFileViewLoadingBuilder = Widget Function(PowerViewType type, int progress);
typedef PowerFileViewErrorBuilder = Widget Function(PowerViewType type);

class PowerFileViewWidget extends StatefulWidget {
  // file server url
  //
  // 文件的服务端地址
  final String? downloadUrl;

  // file's local cache path
  //
  // 文件的本地缓存路径
  final String filePath;

  // If you need to customize Loading UI, you can use this property
  //
  // 如果你需要自定义Loading, 可以使用此属性
  final PowerFileViewLoadingBuilder? loadingBuilder;

  // If you need to customize the error, you can use this property
  //
  // 如果你需要自定义error, 可以使用此属性
  final PowerFileViewErrorBuilder? errorBuilder;

  const PowerFileViewWidget({
    Key? key,
    required this.filePath,
    this.downloadUrl,
    this.loadingBuilder,
    this.errorBuilder,
  }) : super(key: key);

  @override
  State<PowerFileViewWidget> createState() => _PowerFileViewWidgetState();
}

class _PowerFileViewWidgetState extends State<PowerFileViewWidget> {
  late final PowerLocalizations _local = PowerLocalizations.of(context);
  late PowerFileViewModel _viewModel;

  MethodChannel? _channel;

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
      },
    );

    updatePowerViewType();
  }

  void updatePowerViewType({PowerViewType? type}) async {
    await _viewModel.updateViewType();
    setState(() {});
  }

  @override
  void dispose() {
    super.dispose();
    _viewModel.clearTask();
  }

  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(
      builder: (BuildContext context, Orientation orientation) {
        _channel?.invokeMethod('refreshView');
        return _buildPowerFileWidget();
      },
    );
  }

  Widget _buildPowerFileWidget() {
    final viewType = _viewModel.getViewType;
    switch (viewType) {
      case PowerViewType.none:
      case PowerViewType.engineLoading:
      case PowerViewType.fileLoading:
        return _loadingWidget(viewType);
      case PowerViewType.unsupportedPlatform:
      case PowerViewType.nonExistent:
      case PowerViewType.unsupportedType:
      case PowerViewType.engineFail:
      case PowerViewType.fileFail:
        return _errorWidget(viewType);
      case PowerViewType.done:
        if (Platform.isAndroid) {
          return _createAndroidView();
        } else {
          return _createIOSView();
        }
    }
  }

  Widget _loadingWidget(PowerViewType viewType) {
    final builder = widget.loadingBuilder;
    Widget _widget;
    if (builder == null) {
      _widget = PowerLoadingWidget(msg: _viewModel.getMsg(_local));
    } else {
      _widget = builder(viewType, _viewModel.progress);
    }
    return SizedBox.expand(
      child: _widget,
    );
  }

  Widget _errorWidget(PowerViewType viewType) {
    final builder = widget.errorBuilder;
    Widget _widget;

    if (builder == null) {
      _widget = PowerErrorWidget(
        viewType: viewType,
        errorMsg: _viewModel.getMsg(_local),
        retryOnTap: () async {
          await _viewModel.reset();
          setState(() {});
        },
      );
    } else {
      _widget = builder(viewType);
    }

    return SizedBox.expand(
      child: _widget,
    );
  }

  Widget _createAndroidView() {
    return AndroidView(
      viewType: Constants.viewName,
      creationParams: <String, dynamic>{
        'filePath': _viewModel.filePath,
        'fileType': _viewModel.fileType,
      },
      onPlatformViewCreated: (id) {
        _channel = MethodChannel("${Constants.channelName}_$id");
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
      onPlatformViewCreated: (id) {
        _channel = MethodChannel("${Constants.channelName}_$id");
      },
      creationParamsCodec: const StandardMessageCodec(),
    );
  }
}
