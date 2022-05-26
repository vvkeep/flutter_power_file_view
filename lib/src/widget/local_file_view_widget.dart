import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:power_file_view/src/constant/constants.dart';
import 'package:power_file_view/src/constant/enums.dart';
import 'package:power_file_view/src/i18n/power_localizations.dart';
import 'package:power_file_view/src/power_file_view_manager.dart';
import 'package:power_file_view/src/utils/file_util.dart';

class LocalFileViewWidget extends StatefulWidget {
  /// Path to local file
  final String filePath;

  const LocalFileViewWidget({Key? key, required this.filePath}) : super(key: key);

  @override
  State<LocalFileViewWidget> createState() => _LocalFileViewWidgetState();
}

class _LocalFileViewWidgetState extends State<LocalFileViewWidget> {
  late PowerLocalizations local = PowerLocalizations.of(context);

  @override
  Widget build(BuildContext context) {
    final viewType = getViewType();
    debugPrint("viewType: ${viewType.toString()}");
    return FutureBuilder<PreviewType>(
      future: viewType,
      initialData: PreviewType.none,
      builder: (BuildContext context, AsyncSnapshot<PreviewType> snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          switch (snapshot.data ?? PreviewType.none) {
            case PreviewType.unsupportedPlatform:
              return _buildUnSupportPlatformWidget();
            case PreviewType.nonExistent:
              return _buildNonexistentWidget();
            case PreviewType.unsupportedType:
              return _buildUnsupportTypeWidget();
            case PreviewType.engineLoading:
              return _buildEngineLoadingWidget();
            case PreviewType.engineFail:
              return _buildEngineFailWidget();
            case PreviewType.done:
              if (Platform.isAndroid) {
                return _createAndroidView();
              } else {
                return _createIOSView();
              }
            case PreviewType.none:
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
  Future<PreviewType> getViewType() async {
    if (Platform.isAndroid || Platform.isIOS) {
      if (FileUtil.isExistsFile(filePath)) {
        if (FileUtil.isSupportOpen(fileType)) {
          if (Platform.isAndroid) {
            final EngineState? state = await PowerFileViewManager.engineState();
            if (state == EngineState.done) {
              return PreviewType.done;
            } else if (state == EngineState.error) {
              return PreviewType.engineFail;
            } else {
              PowerFileViewManager.engineInitStream.listen((EngineState e) async {
                if (e == EngineState.done) {
                  setState(() {});
                } else {
                  await PowerFileViewManager.initEngine();
                  setState(() {});
                }
              });

              return PreviewType.engineLoading;
            }
          } else {
            return PreviewType.done;
          }
        } else {
          return PreviewType.unsupportedType;
        }
      } else {
        return PreviewType.nonExistent;
      }
    } else {
      return PreviewType.unsupportedPlatform;
    }
  }

  String sprintf(String stringtf, String msg) {
    return stringtf.replaceAll(r'%s', msg);
  }

  String get filePath => widget.filePath;

  String get fileType => FileUtil.getFileType(filePath);
}
