import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:power_file_view/power_file_view.dart';

import 'permission_util.dart';
import 'preview_file_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  PowerFileViewManager.initEngine();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<String> files = [
      "http://www.cztouch.com/upfiles/soft/testpdf.pdf",
      "http://blog.java1234.com/cizhi20211008.docx",
      "http://blog.java1234.com/moban20211008.xls"
    ];
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          '文件列表',
          style: TextStyle(color: Colors.black),
        ),
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
                  String savePath = await setFilePath(type, title);
                  onNetworkTap(context, title, type, filePath, savePath);
                },
                child: Text(fileShowText),
              ),
            );
          }),
    );
  }

  Future onNetworkTap(BuildContext context, String title, String type, String downloadUrl, String downloadPath) async {
    bool isGranted = await PermissionUtil.checkPhotos();
    if (isGranted) {
      Navigator.of(context).push(MaterialPageRoute(builder: (ctx) {
        return PreviewFilePage(
          downloadUrl: downloadUrl,
          downloadPath: downloadPath,
        );
      }));
    }
  }

  Future setFilePath(String type, String assetPath) async {
    final _directory = await getTemporaryDirectory();
    return "${_directory.path}/fileview/${base64.encode(utf8.encode(assetPath))}.$type";
  }
}
