import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_power_file_preview/flutter_power_file_preview.dart';
import 'package:flutter_power_file_preview/src/constant/constant.dart';
import 'package:flutter_power_file_preview/src/enum/engine_state.dart';
import 'package:flutter_power_file_preview/src/enum/perview_type.dart';
import 'package:flutter_power_file_preview/src/i18n/power_localizations.dart';
import 'package:flutter_power_file_preview/src/utils/file_util.dart';

class LocalFilePreviewWidget extends StatefulWidget {
  /// Path to local file
  final String filePath;

  const LocalFilePreviewWidget({Key? key, required this.filePath}) : super(key: key);

  @override
  State<LocalFilePreviewWidget> createState() => _LocalFilePreviewWidgetState();
}

class _LocalFilePreviewWidgetState extends State<LocalFilePreviewWidget> {
  late PowerLocalizations local = PowerLocalizations.of(context);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<PerviewType>(
      future: getViewType(),
      initialData: PerviewType.none,
      builder: (BuildContext context, AsyncSnapshot<PerviewType> snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          switch (snapshot.data ?? PerviewType.none) {
            case PerviewType.unsupportedPlatform:
              return _buildUnSupportPlatformWidget();
            case PerviewType.nonExistent:
              return _buildNonexistentWidget();
            case PerviewType.unsupportedType:
              return _buildUnsupportTypeWidget();
            case PerviewType.engineLoading:
              return _buildEngineLoadingWidget();
            case PerviewType.engineFail:
              return _buildEngineFailWidget();
            case PerviewType.done:
              if (Platform.isAndroid) {
                return _createAndroidView();
              } else {
                return _createIOSView();
              }
            case PerviewType.none:
              return _buildPlaceholderWidget();
          }
        }

        return _buildPlaceholderWidget();
      },
    );
  }

  Widget _buildPlaceholderWidget() {
    return Center(
      child: CupertinoTheme(
        data: CupertinoThemeData(brightness: Theme.of(context).brightness),
        child: const CupertinoActivityIndicator(radius: 14.0),
      ),
    );
  }

  Widget _buildUnSupportPlatformWidget() {
    return showTipWidget(local.unsupportedPlatformTip);
  }

  Widget _buildNonexistentWidget() {
    return showTipWidget(local.nonExistentTip);
  }

  Widget _buildUnsupportTypeWidget() {
    return showTipWidget(sprintf(local.unsupportedType, fileType));
  }

  Widget _buildEngineLoadingWidget() {
    return showTipWidget(local.engineLoading);
  }

  Widget _buildEngineFailWidget() {
    return showTipWidget(local.engineFail);
  }

  Widget _createAndroidView() {
    return AndroidView(
      viewType: Constants.viewName,
      creationParams: <String, dynamic>{
        'filePath': filePath,
        'fileType': fileType,
      },
      creationParamsCodec: const StandardMessageCodec(),
    );
  }

  Widget _createIOSView() {
    return UiKitView(
      viewType: Constants.viewName,
      creationParams: <String, String>{
        'filePath': filePath,
        'fileType': fileType,
      },
      creationParamsCodec: const StandardMessageCodec(),
    );
  }

  /// Widgets for presenting information
  Widget showTipWidget(String tip) {
    return Center(child: Text(tip));
  }

  /// Display different layouts by changing status
  Future<PerviewType> getViewType() async {
    if (Platform.isAndroid || Platform.isIOS) {
      if (FileUtil.isExistsFile(filePath)) {
        if (FileUtil.isSupportOpen(fileType)) {
          if (Platform.isAndroid) {
            final EngineState? state = await FlutterPowerFilePreview.engineState();
            if (state == EngineState.done) {
              return PerviewType.done;
            } else if (state == EngineState.error) {
              return PerviewType.engineFail;
            } else {
              FlutterPowerFilePreview.engineInitStream.listen((EngineState e) async {
                if (e == EngineState.done) {
                  setState(() {});
                } else {
                  await FlutterPowerFilePreview.initEngine();
                  setState(() {});
                }
              });

              return PerviewType.engineLoading;
            }
          } else {
            return PerviewType.done;
          }
        } else {
          return PerviewType.unsupportedType;
        }
      } else {
        return PerviewType.nonExistent;
      }
    } else {
      return PerviewType.unsupportedPlatform;
    }
  }

  String sprintf(String stringtf, String msg) {
    return stringtf.replaceAll(r'%s', msg);
  }

  String get filePath => widget.filePath;

  String get fileType => FileUtil.getFileType(filePath);
}
