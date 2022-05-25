import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_power_file_preview/flutter_power_file_preview.dart';
import 'package:flutter_power_file_preview/src/constant/constant.dart';
import 'package:flutter_power_file_preview/src/enum/download_state.dart';
import 'package:flutter_power_file_preview/src/enum/perview_type.dart';
import 'package:flutter_power_file_preview/src/i18n/power_localizations.dart';
import 'package:flutter_power_file_preview/src/utils/file_util.dart';

class PowerFilePreviewWidget extends StatefulWidget {
  /// Download link for file
  /// [downloadUrl] will be used to obtain the file name and type
  final String downloadUrl;

  /// The file storage address is used to determine whether the file can be downloaded
  final String downloadPath;

  /// File viewing function
  /// Will be removed in future releases
  final VoidCallback onViewPressed;

  const PowerFilePreviewWidget({
    Key? key,
    required this.downloadUrl,
    required this.downloadPath,
    required this.onViewPressed,
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

  PerviewType viewType = PerviewType.none;

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
    if (viewType == PerviewType.done) {
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
    return Column(
      children: <Widget>[
        centerWidget(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: _buildTopWidget(),
          ),
        ),
        centerWidget(
          child: progressValue > 0 ? _buildProgressWidget() : _buildButtonWidget(),
        ),
      ],
    );
  }

  List<Widget> _buildTopWidget() {
    return <Widget>[
      Image.asset(fileTypeImage, package: Constants.packageName, width: 48, height: 48),
      Container(
        margin: const EdgeInsets.only(top: 40.0, bottom: 10.0),
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Text(
          fileName,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyText1?.copyWith(fontWeight: FontWeight.bold),
        ),
      ),
      Text(
        fileSize,
        style: Theme.of(context).textTheme.bodyText2,
      ),
    ];
  }

  Widget _buildButtonWidget() {
    final double screenWidth = MediaQuery.of(context).size.width;
    double defaultWidth = screenWidth / 3;
    defaultWidth = defaultWidth < 120 ? 120 : defaultWidth;
    double defaultHeight = defaultWidth / 3;
    defaultHeight = defaultHeight < 40 ? 40 : defaultHeight;

    final Size size = Size(defaultWidth, defaultHeight);

    return ElevatedButton(
      onPressed: () async => isDownload ? download() : widget.onViewPressed.call(),
      style: ButtonStyle(
        foregroundColor: MaterialStateProperty.resolveWith((Set<MaterialState> states) {
          return Colors.white;
        }),
        backgroundColor: MaterialStateProperty.resolveWith((Set<MaterialState> states) {
          // 当按钮无法点击时 设置背景色
          if (states.contains(MaterialState.disabled)) {
            return Colors.grey[350];
          } else {
            return Theme.of(context).primaryColor;
          }
        }),
        minimumSize: MaterialStateProperty.all(size),
      ),
      child: Text(btnName),
    );
  }

  Widget _buildProgressWidget() {
    final double size = 60.0;
    return SizedBox(
      width: size,
      height: size,
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
        viewType = PerviewType.done;
      }
    });
  }

  String get btnName {
    return isDownload ? local.downloadTitle : local.viewTitle;
  }

  String get fileTypeImage {
    String type = 'assets/images/';

    switch (fileType) {
      case 'doc':
      case 'docx':
        type += 'ic_file_doc.png';
        break;
      case 'xls':
      case 'xlsx':
        type += 'ic_file_xls.png';
        break;
      case 'ppt':
      case 'pptx':
        type += 'ic_file_ppt.png';
        break;
      case 'txt':
        type += 'ic_file_txt.png';
        break;
      case 'pdf':
        type += 'ic_file_pdf.png';
        break;
      default:
        type += 'ic_file_other.png';
        break;
    }

    return type;
  }

  String get fileLink => widget.downloadUrl;

  String get filePath => widget.downloadPath;

  String get fileName => FileUtil.getFileName(fileLink);

  String get fileType => FileUtil.getFileType(fileLink);
}
