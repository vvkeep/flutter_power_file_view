# Flutter PowerFileView

##### 一款本地文件预览插件，使用PowerFileView可以像android、ios一样方便的预览doc、docx、ppt、pptx、xls、xlsx、pdf等文件。

## 说明
* android使用腾讯TBS服务，支持doc、docx、ppt、pptx、xls、xlsx、pdf、txt、epub文件的预览
* ios使用WKWebView，WKWebView所支持的均可预览

## 支持格式
|格式|android|ios|
|:----|:----:|:----:|
|.doc| ✅ | ✅ |
|.docx| ✅ | ✅ |
|.ppt| ✅ | ✅ |
|.pptx| ✅ | ✅ |
|.xls| ✅ | ✅ |
|.xlsx| ✅ | ✅ |
|.pdf|✅ | ✅ |

## 集成
### 1、依赖
在pubspec.yaml文件下添加

### 2、快速集成
####1、安卓集成
由于使用android使用TBS服务，所以需要网络权限和存储权限。
在安卓的AndroidManifest文件中添加下列权限
```
    <uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
    <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
    <uses-permission android:name="android.permission.ACCESS_WIFI_STATE" />
    <uses-permission android:name="android.permission.INTERNET" />
```
为了避免release版本加载TBS内核库失败
在混淆文件proguard-rules.pro中加入下面的代码
```
-dontwarn dalvik.**
-dontwarn com.tencent.smtt.**

-keep class com.tencent.smtt.** {
    *;
}

-keep class com.tencent.tbs.** {
    *;
}
```

然后在build.gradle中开启删除无用资源，可以如下图所示配置
```
buildTypes {
        release {
            //关闭删除无用资源
            shrinkResources false
            //关闭删除无用代码
            minifyEnabled false
            zipAlignEnabled true
            proguardFiles getDefaultProguardFile('proguard-android.txt'), 'proguard-rules.pro'
        }
    }
```

####2、IOS集成

###3、TBS初始化
由于android使用TBS服务，所以在使用前需要初始化，耗时3-30秒左右
1、异步初始化（推荐）
可以在app的main.dart文件的main函数下执行异步初始化、这样用户打开文件就不需要等待TBS初始化了
```
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  PowerFileViewManager.initEngine();
  runApp(const MyApp());
}
```
2、打开时初始化
如不进行异步初始化配置，那么文件打开前会自动进行初始化操作，用户无需配置


### 4、快速使用
传入要预览的文件的downloadUrl和文件下载的存储路径downloadPath即可
```
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
      ),
    );
  }
}
```


### 5、Http配置（可选）
如果需要用到明文下载、需要进行以下配置
####1、android
在android/app/src/main/res/xml下新建network_config.xml
```
<?xml version="1.0" encoding="utf-8"?>
<network-security-config>
    <base-config cleartextTrafficPermitted="true"/>
</network-security-config>
```

在android/app/src/main/AndroidManifest.xml中使用
```
<application
       android:networkSecurityConfig="@xml/network_config">
```
####2、ios
在ios/Runner/Info.plist中
```
 <key>NSAppTransportSecurity</key>
        <dict>
            <key>NSAllowsArbitraryLoads</key>
            <true/>
        </dict>
```





