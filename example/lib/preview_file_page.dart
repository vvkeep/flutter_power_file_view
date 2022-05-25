import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_power_file_preview/src/widget/power_file_preview_widget.dart';

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
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: PowerFilePreviewWidget(
        downloadUrl: widget.downloadUrl,
        downloadPath: widget.downloadPath,
      ),
    );
  }
}
