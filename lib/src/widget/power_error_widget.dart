import 'package:flutter/material.dart';
import 'package:power_file_view/power_file_view.dart';

class PowerErrorWidget extends StatelessWidget {
  final PowerViewType viewType;

  const PowerErrorWidget({Key? key, required this.viewType}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.red,
      child: Center(child: Text(_getErrorMsg())),
    );
  }

  _getErrorMsg() {
    if (viewType == PowerViewType.unsupportedPlatform) {
      return "不支持平台";
    } else if (viewType == PowerViewType.nonExistent) {
      return "文件不存在";
    } else if (viewType == PowerViewType.unsupportedType) {
      return "不支持文件类型";
    } else if (viewType == PowerViewType.engineFail) {
      return "引擎加载失败";
    } else if (viewType == PowerViewType.fileLoading) {
      return "文件下载失败";
    } else if (viewType == PowerViewType.fileFail) {
      return "文件下载失败";
    } else {
      return "未知错误";
    }
  }
}
