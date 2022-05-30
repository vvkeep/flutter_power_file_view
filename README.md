# Flutter PowerFileView

A local file preview plugin, using PowerFileView, you can preview doc, docx, ppt, pptx, xls, xlsx, pdf and other files as easily as android and ios.

## illustrate
* Android uses Tencent TBS service, supports preview of doc, docx, ppt, pptx, xls, xlsx, pdf, txt, epub files
* ios uses WKWebView, all supported by WKWebView can be previewed

## Supported formats
|Format|android|ios|
|:----|:----:|:----:|
|.doc| ✅ | ✅ |
|.docx| ✅ | ✅ |
|.ppt| ✅ | ✅ |
|.pptx| ✅ | ✅ |
|.xls| ✅ | ✅ |
|.xlsx| ✅ | ✅ |
|.pdf|✅ | ✅ |

## Integration
### 1. Dependency
Add under the pubspec.yaml file
power_file_view: ^1.0.0

### 2. Quick integration
#### 1. Android
Since using android to use TBS service, network permission and storage permission are required.
Add the following permissions to the AndroidManifest file of Android.
````
    <uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
    <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
    <uses-permission android:name="android.permission.ACCESS_WIFI_STATE" />
    <uses-permission android:name="android.permission.INTERNET" />
````
In order to prevent the release version from failing to load the TBS kernel library.
Add the following code to the obfuscation file proguard-rules.pro.
````
-dontwarn dalvik.**
-dontwarn com.tencent.smtt.**

-keep class com.tencent.smtt.** {
    *;
}

-keep class com.tencent.tbs.** {
    *;
}
````

Then enable delete useless resources in build.gradle, which can be configured as shown in the following figure
````
buildTypes {
        release {
            //Close delete useless resources
            shrinkResources false
            //Close delete useless code
            minifyEnabled false
            zipAlignEnabled true
            proguardFiles getDefaultProguardFile('proguard-android.txt'), 'proguard-rules.pro'
        }
    }
````

### 2. TBS initialization

Since android uses the TBS service, it needs to be initialized before use, which takes about 3-30 seconds.

1. Asynchronous initialization (recommended)

Asynchronous initialization can be performed under the main function of the app's main.dart file, so that the user does not need to wait for TBS initialization when opening the file.
````
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  PowerFileViewManager.initEngine();
  runApp(const MyApp());
}
````
2. Initialize when opening

If the asynchronous initialization configuration is not performed, the initialization operation will be performed automatically before the file is opened, and the user does not need to configure


### 4. Quick use
#### file preview
1. Network files: Just pass in the downloadUrl of the file to be previewed and the downloadPath of the storage path of the file to download.
##### define downloadPath
````
  import 'package:path_provider/path_provider.dart';
  ...
  final _directory = await getTemporaryDirectory();
  final downloadPath = "${_directory.path}/fileview/"fileName.pdf";//Set a name you like
````

2. Local file: Just pass in the downloadPath of the path where the local file is located.


````
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
        title: const Text('File Preview'),
      ),
      body: PowerFileViewWidget(
        downloadUrl: widget.downloadUrl,
        filePath: widget.downloadPath,
      ),
    );
  }
}
````

#### Custom progress display and error display
You can customize the display style of progress loading and the display style of errors in loadingBuilder and errorBuilder.
````
 PowerFileViewWidget(
        downloadUrl: widget.downloadUrl,
        filePath: widget.downloadPath,
        loadingBuilder: (viewType, progress) {
          return Container(
            color: Colors.grey,
            alignment: Alignment.center,
            child: Text("Loading: $progress"),
          );
        },
        errorBuilder: (viewType) {
          return Container(
            color: Colors.red,
            alignment: Alignment.center,
            child: const Text("Something went wrong!!!!"),
          );
        },
      ),
````

### 5. HTTP configuration (optional)
If you need to use plaintext download, you need to configure the following
#### 1. android
Create a new network_config.xml under android/app/src/main/res/xml
````
<?xml version="1.0" encoding="utf-8"?>
<network-security-config>
    <base-config cleartextTrafficPermitted="true"/>
</network-security-config>
````

and configure in android/app/src/main/AndroidManifest.xml
````
<application
       android:networkSecurityConfig="@xml/network_config">
````
#### 2. iOS
Make sure to add the following keys in ios/Runner/Info.plist
````
 <key>NSAppTransportSecurity</key>
        <dict>
            <key>NSAllowsArbitraryLoads</key>
            <true/>
        </dict>
````