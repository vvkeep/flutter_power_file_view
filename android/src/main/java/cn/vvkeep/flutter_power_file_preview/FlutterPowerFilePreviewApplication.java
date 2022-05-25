package cn.vvkeep.flutter_power_file_preview;

import io.flutter.app.FlutterApplication;


/**
 * 在android目录下新建Application继承FlutterPowerFilePreviewApplication
 * 就能在app冷启动时初始化TBS服务，无需手动加载
 */
public class FlutterPowerFilePreviewApplication extends FlutterApplication {
    @Override
    public void onCreate() {
        super.onCreate();
        //初始化TBS服务
        TBSManager.getInstance().initTBS(this,null);
    }
}
