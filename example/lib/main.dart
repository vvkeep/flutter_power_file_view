import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:power_file_view/power_file_view.dart';
import 'package:power_file_view_example/power_file_view_page.dart';

import 'permission_util.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  PowerFileViewManager.initLogEnable(true, true);
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

const List<String> files = [
  "https://google-developer-training.github.io/android-developer-fundamentals-course-concepts/en/android-developer-fundamentals-course-concepts-en.pdf",
  "http://www.cztouch.com/upfiles/soft/testpdf.pdf",
  "http://blog.java1234.com/cizhi20211008.docx",
  "http://blog.java1234.com/moban20211008.xls"
];

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('文件列表'),
      ),
      body: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListView.builder(
              shrinkWrap: true,
              itemCount: files.length,
              itemBuilder: (context, index) {
                String filePath = files[index];
                final fileName = FileUtil.getFileName(filePath);
                final fileType = FileUtil.getFileType(filePath);
                return Container(
                  margin: const EdgeInsets.only(top: 10.0),
                  padding: const EdgeInsets.symmetric(horizontal: 15.0),
                  child: ElevatedButton(
                    onPressed: () async {
                      String savePath = await getFilePath(fileType, fileName);
                      onTap(context, filePath, savePath);
                    },
                    child: Text(fileName),
                  ),
                );
              }),
          Container(
            margin: const EdgeInsets.only(top: 10.0),
            padding: const EdgeInsets.symmetric(horizontal: 15.0),
            child: ElevatedButton(
              onPressed: () async {
                // pick file from storage
                File? file = await FileUtil.getFilePathFromStorage();

                if (file == null) {
                  debugPrint('file null');
                  // toast info
                  showCustomToast(context, 'file null');
                  return;
                }

                var filePath = file.path;
                bool isGranted = await PermissionUtil.check();
                if (isGranted) {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (ctx) {
                      return PowerFileViewPage(
                        downloadUrl: '',
                        downloadPath: filePath,
                      );
                    }),
                  );
                } else {
                  debugPrint('no permission');
                }
              },
              child: Text('Open File'),
            ),
          ),
        ],
      ),
    );
  }

  void showCustomToast(BuildContext context, String message) {
    OverlayState overlayState = Overlay.of(context)!;
    OverlayEntry overlayEntry;
    overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).size.height * 0.8,
        width: MediaQuery.of(context).size.width,
        child: Material(
          color: Colors.transparent,
          child: Container(
            alignment: Alignment.center,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(8),
              ),
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
              child: Text(
                message,
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ),
    );

    overlayState.insert(overlayEntry);

    Future.delayed(Duration(seconds: 2)).then((_) {
      overlayEntry.remove();
    });
  }

  Future onTap(
      BuildContext context, String downloadUrl, String downloadPath) async {
    bool isGranted = await PermissionUtil.check();
    if (isGranted) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (ctx) {
          return PowerFileViewPage(
            downloadUrl: downloadUrl,
            downloadPath: downloadPath,
          );
        }),
      );
    } else {
      debugPrint('no permission');
    }
  }

  Future getFilePath(String type, String assetPath) async {
    final _directory = await getTemporaryDirectory();
    return "${_directory.path}/fileview/${base64.encode(utf8.encode(assetPath))}.$type";
  }
}
