import 'package:flutter/material.dart';
import 'package:power_file_view/power_file_view.dart';

class PowerErrorWidget extends StatelessWidget {
  final PowerViewType viewType;
  final VoidCallback retryOnTap;

  const PowerErrorWidget({Key? key, required this.viewType, required this.retryOnTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.white,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            _getErrorMsg(),
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: Colors.black),
          ),
          const SizedBox(height: 8),
          TextButton(
              onPressed: retryOnTap,
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Colors.blue),
                shape: MaterialStateProperty.all(const StadiumBorder()),
              ),
              child: const SizedBox(
                width: 80,
                child: Center(
                  child: Text(
                    '重新加载',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Colors.white,
                    ),
                  ),
                ),
              ))
        ],
      ),
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
