import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:power_file_view/src/constant/enums.dart';
import 'package:power_file_view/src/i18n/power_localizations.dart';
import 'package:power_file_view/src/power_file_view_manager.dart';
import 'package:power_file_view/src/utils/file_util.dart';
import 'package:power_file_view/src/widget/local_file_view_widget.dart';

class PowerFileViewWidget extends StatefulWidget {
  /// Download link for file
  /// [downloadUrl] will be used to obtain the file name and type
  final String downloadUrl;

  /// The file storage address is used to determine whether the file can be downloaded
  final String downloadPath;

  const PowerFileViewWidget({
    Key? key,
    required this.downloadUrl,
    required this.downloadPath,
  }) : super(key: key);

  @override
  State<PowerFileViewWidget> createState() => _PowerFileViewWidgetState();
}

class _PowerFileViewWidgetState extends State<PowerFileViewWidget> {
  late PowerLocalizations local = PowerLocalizations.of(context);

  /// Does it support downloading
  late bool isDownload = !FileUtil.isExistsFile(filePath);

  /// Download progress
  double progressValue = 0.0;

  /// File size
  String fileSize = '';

  PowerViewType viewType = PowerViewType.done;
  DownloadState downloadState = DownloadState.none;

  final CancelToken cancelToken = CancelToken();

  @override
  void initState() {
    super.initState();
    debugPrint('downloadUrl: ${widget.downloadUrl}, downloadPath: ${widget.downloadPath}');
    if (isDownload) {
      Future<void>.delayed(Duration.zero, () {
        getViewType();
      });
    } else {
      viewType = PowerViewType.done;
      downloadState = DownloadState.done;
      setState(() {});
    }
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
    if (viewType == PowerViewType.done) {
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
    debugPrint("_buildBodyWidget downloadState: $downloadState");
    if (downloadState == DownloadState.done) {
      return LocalFileViewWidget(filePath: widget.downloadPath);
    } else {
      return Center(
        child: _buildProgressWidget(),
      );
    }
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

  /// Download
  Future<DownloadState> download() async {
    downloadState = DownloadState.downloading;
    await PowerFileViewManager.downloadFile(
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

    downloadState = DownloadState.done;
    return downloadState;
  }

  /// Display different layouts by changing state
  Future<void> getViewType() async {
    final String? size = await PowerFileViewManager.getFileSize(
      context,
      fileLink,
      cancelToken: cancelToken,
    );

    setState(() {
      if (mounted) {
        fileSize = size ?? '';
        viewType = PowerViewType.done;
      }
    });

    debugPrint("download file size: $size .....");
    await download();

    setState(() {});
  }

  String get fileLink => widget.downloadUrl;

  String get filePath => widget.downloadPath;
}
