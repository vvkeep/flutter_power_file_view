import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:power_file_view/power_file_view.dart';

class PowerLoadingWidget extends StatefulWidget {
  final PowerViewType viewType;
  final int? progress;
  const PowerLoadingWidget({Key? key, required this.viewType, required this.progress}) : super(key: key);

  @override
  State<PowerLoadingWidget> createState() => _PowerLoadingWidgetState();
}

class _PowerLoadingWidgetState extends State<PowerLoadingWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      width: double.infinity,
      height: double.infinity,
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          decoration: BoxDecoration(
            color: Colors.black54,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CupertinoActivityIndicator(
                radius: 14.0,
                color: Colors.white,
              ),
              Container(
                margin: const EdgeInsets.only(top: 15),
                child: Text(
                  _getLoadingMsg(),
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getLoadingMsg() {
    if (widget.viewType == PowerViewType.engineLoading) {
      return "引擎下载中(${widget.progress!}%)...";
    } else if (widget.viewType == PowerViewType.fileLoading) {
      return "文件加载中...";
    } else if (widget.viewType == PowerViewType.none) {
      return "页面初始化...";
    } else {
      return "未知状态...";
    }
  }
}
