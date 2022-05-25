import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:flutter_power_file_preview/flutter_power_file_preview.dart';
import 'package:flutter_power_file_preview_example/preview_file_page.dart';
import 'package:path_provider/path_provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  List<String> files = [];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: ListView.builder(
            itemCount: files.length,
            itemBuilder: (context, index) {
              String filePath = files[index];
              String fileShowText = '';

              int i = filePath.lastIndexOf('/');
              if (i <= -1) {
                fileShowText = filePath;
              } else {
                fileShowText = filePath.substring(i + 1);
              }

              int j = fileShowText.lastIndexOf('.');
              String title = '';
              String type = '';
              if (j > -1) {
                title = fileShowText.substring(0, j);
                type = fileShowText.substring(j + 1).toLowerCase();
              }
              return Container(
                margin: const EdgeInsets.only(top: 10.0),
                padding: const EdgeInsets.symmetric(horizontal: 15.0),
                child: ElevatedButton(
                  onPressed: () async {
                    String tempfilePath = await setFilePath(type, title);
                    onNetworkTap(title, type, tempfilePath);
                  },
                  child: Text(fileShowText),
                ),
              );
            }),
      ),
    );
  }

  Future onNetworkTap(String title, String type, String downloadUrl) async {
    String filePath = await setFilePath(type, title);
    Navigator.of(context).push(MaterialPageRoute(builder: (ctx) {
      return PreviewFilePage(
        downloadUrl: downloadUrl,
        downloadPath: filePath,
      );
    }));
  }

  Future setFilePath(String type, String assetPath) async {
    final _directory = await getTemporaryDirectory();
    return "${_directory.path}/fileview/${base64.encode(utf8.encode(assetPath))}.$type";
  }
}
