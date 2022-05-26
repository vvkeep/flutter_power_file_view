import 'package:flutter/material.dart';
import 'package:power_file_view/power_file_view.dart';

class PowerLoadingWidget extends StatefulWidget {
  final PowerViewType viewType;
  const PowerLoadingWidget({Key? key, required this.viewType}) : super(key: key);

  @override
  State<PowerLoadingWidget> createState() => _PowerLoadingWidgetState();
}

class _PowerLoadingWidgetState extends State<PowerLoadingWidget> {
  @override
  Widget build(BuildContext context) {
    return _buildBackground(children: [
      const CircularProgressIndicator(
        strokeWidth: 3,
        valueColor: AlwaysStoppedAnimation(Colors.white),
      ),
      Container(
        margin: const EdgeInsets.only(top: 20),
        child: Text(
          _getLoadingMsg(),
          style: const TextStyle(color: Colors.white),
        ),
      ),
    ]);
  }

  String _getLoadingMsg() {
    if (widget.viewType == PowerViewType.engineLoading) {
      return "引擎加载中...";
    } else if (widget.viewType == PowerViewType.fileLoading) {
      return "文件加载中...";
    } else if (widget.viewType == PowerViewType.none) {
      return "页面初始化...";
    } else {
      return "未知状态...";
    }
  }

  Widget _buildBackground({required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: children,
      ),
    );
  }
}
