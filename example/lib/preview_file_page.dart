import 'package:flutter/material.dart';
import 'package:power_file_view/power_file_view.dart';

class PreviewFilePage extends StatefulWidget {
  final String downloadUrl;
  final String downloadPath;

  const PreviewFilePage({Key? key, required this.downloadUrl, required this.downloadPath}) : super(key: key);

  @override
  State<PreviewFilePage> createState() => _PreviewFilePageState();
}

class _PreviewFilePageState extends State<PreviewFilePage> {
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
      ),
    );
  }
}
