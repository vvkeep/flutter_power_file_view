import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_power_file_preview/src/flutter_power_file_preview.dart';
import 'package:flutter_power_file_preview/src/enum/download_state.dart';
import 'package:flutter_power_file_preview/src/enum/preview_type.dart';
import 'package:flutter_power_file_preview/src/i18n/power_localizations.dart';
import 'package:flutter_power_file_preview/src/utils/file_util.dart';
import 'package:flutter_power_file_preview/src/widget/file_preview_widget.dart';

class PowerFilePreviewWidget extends StatefulWidget {
  /// Download link for file
  /// [downloadUrl] will be used to obtain the file name and type
  final String downloadUrl;

  /// The file storage address is used to determine whether the file can be downloaded
  final String downloadPath;

  const PowerFilePreviewWidget({
    Key? key,
    required this.downloadUrl,
    required this.downloadPath,
  }) : super(key: key);

  @override
  State<PowerFilePreviewWidget> createState() => _PowerFilePreviewWidgetState();
}

class _PowerFilePreviewWidgetState extends State<PowerFilePreviewWidget> {
  late PowerLocalizations local = PowerLocalizations.of(context);

  /// Does it support downloading
  late bool isDownload = !FileUtil.isExistsFile(filePath);

  /// Download progress
  double progressValue = 0.0;

  /// File size
  String fileSize = '';

  PreviewType viewType = PreviewType.none;

  final CancelToken cancelToken = CancelToken();

  @override
  void initState() {
    super.initState();

    Future<void>.delayed(Duration.zero, () {
      getViewType();
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
    if (viewType == PreviewType.done) {
      return _buildBodyWidget();
    } else {
      return _buildPlaceholderWidget();
    }
  }

  Widget _buildPlaceholderWidget() {
    return Center(
      child: CupertinoTheme(
        data: CupertinoThemeData(brightness: Theme.of(context).brightness),
        child: const CupertinoActivityIndicator(radius: 14.0),
      ),
    );
  }

  Widget _buildBodyWidget() {
    return centerWidget(
      child: progressValue > 0 ? _buildProgressWidget() : FilePreviewWidget(filePath: widget.downloadPath),
    );
  }

  Widget _buildProgressWidget() {
    return SizedBox(
      width: 60.0,
      height: 60.0,
      child: CircularProgressIndicator(
        value: progressValue,
        strokeWidth: 6.0,
        backgroundColor: Theme.of(context).primaryColor,
        valueColor: const AlwaysStoppedAnimation<Color>(
          Colors.tealAccent,
        ),
      ),
    );
  }

  Widget centerWidget({required Widget child}) {
    return Expanded(child: Center(child: child));
  }

  /// Download
  Future<DownloadState> download() async {
    await FlutterPowerFilePreview.downloadFile(
      fileLink,
      filePath,
      callback: (DownloadState state) {
        setState(() {
          if (mounted) {
            isDownload = !(state == DownloadState.done);
            progressValue = 0.0;
          }
        });
      },
      onProgress: (int count, int total) async {
        setState(() {
          if (mounted) {
            progressValue = count / total;
          }
        });
      },
      cancelToken: cancelToken,
    );
    return DownloadState.none;
  }

  /// Display different layouts by changing state
  Future<void> getViewType() async {
    final String? size = await FlutterPowerFilePreview.getFileSize(
      context,
      fileLink,
      cancelToken: cancelToken,
    );

    setState(() {
      if (mounted) {
        fileSize = size ?? '';
        viewType = PreviewType.done;
      }
    });
  }

  String get fileLink => widget.downloadUrl;

  String get filePath => widget.downloadPath;
}
