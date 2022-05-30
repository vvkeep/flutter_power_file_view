import 'package:flutter/material.dart';
import 'package:power_file_view/power_file_view.dart';

class PowerFileViewPage extends StatefulWidget {
  final String downloadUrl;
  final String downloadPath;

  const PowerFileViewPage({Key? key, required this.downloadUrl, required this.downloadPath}) : super(key: key);

  @override
  State<PowerFileViewPage> createState() => _PowerFileViewPageState();
}

class _PowerFileViewPageState extends State<PowerFileViewPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('文件预览'),
      ),
      body: PowerFileViewWidget(
        downloadUrl: widget.downloadUrl,
        filePath: widget.downloadPath,
        // loadingBuilder: (viewType, progress) {
        //   return Container(
        //     color: Colors.grey,
        //     alignment: Alignment.center,
        //     child: Text("加载中: $progress"),
        //   );
        // },
        // errorBuilder: (viewType) {
        //   return Container(
        //     color: Colors.red,
        //     alignment: Alignment.center,
        //     child: const Text("出错了"),
        //   );
        // },
      ),
    );
  }
}
