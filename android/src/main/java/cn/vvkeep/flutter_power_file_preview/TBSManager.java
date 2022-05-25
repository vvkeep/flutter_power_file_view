package cn.vvkeep.flutter_power_file_preview;

import android.content.Context;

import com.tencent.smtt.export.external.TbsCoreSettings;
import com.tencent.smtt.sdk.QbSdk;
import com.tencent.smtt.sdk.TbsListener;

import java.util.HashMap;

import io.flutter.Log;

public class TBSManager {

    //  0 未加载状态  1开始 10 完成 11 错误 20 下载完成 21 下载失败 22 下载中 30 安装成功 31 安装失败
    public  int engineState = 0;

    private static class SingletonHolder {
        private static final TBSManager instance = new TBSManager();
    }

    public static TBSManager getInstance() {
        return SingletonHolder.instance;
    }

    //禁止直接创建实例
    private TBSManager() {
    }

    public void initTBS(Context context, OnInitListener onInitListener) {
        if (engineState == 10) {
            onInitListener.onInit(engineState);
            return;
        }
        //禁用隐私API的获取
        ///不获取AndroidID
        QbSdk.canGetAndroidId(false);
        ///不获取设备IMEI
        QbSdk.canGetDeviceId(false);
        ///不获取IMSI
        QbSdk.canGetSubscriberId(false);

        //防止因为有缓存导致无法下载
        QbSdk.reset(context);


        // 在调用TBS初始化、创建WebView之前进行如下配置，以开启优化方案
        HashMap<String, Object> map = new HashMap<String, Object>();
        map.put(TbsCoreSettings.TBS_SETTINGS_USE_SPEEDY_CLASSLOADER, true);
        map.put(TbsCoreSettings.TBS_SETTINGS_USE_DEXLOADER_SERVICE, true);
        QbSdk.initTbsSettings(map);
        //运行使用WiFi下载内核
        QbSdk.setDownloadWithoutWifi(true);

        engineState=1;
        onInitListener.onInit(engineState);

        QbSdk.setTbsListener(new TbsListener() {
            @Override
            public void onDownloadFinish(int i) {
                Log.e("filePreview", "TBS下载完成");
                engineState=20;
                onInitListener.onInit(engineState);
            }

            @Override
            public void onInstallFinish(int i) {
                Log.e("filePreview", "TBS安装完成");
                engineState=30;
                onInitListener.onInit(engineState);
            }

            @Override
            public void onDownloadProgress(int i) {
                Log.e("filePreview", "TBS下载进度:" + i);
                engineState=22;
                onInitListener.onInit(engineState);
            }
        });

        //初始化x5环境
        QbSdk.initX5Environment(context, new QbSdk.PreInitCallback() {

            @Override
            public void onCoreInitFinished() {
                // 内核初始化完成，可能为x5内核，也可能为系统内核
                Log.e("filePreview", "onCoreInitFinished:");
            }

            /**
             * 预初始化结束
             * 由于X5内核体积较大，需要依赖网络动态下发，
             * 所以当内核不存在的时候，默认会回调false，此时将会使用系统内核代替
             *@param  isSuccess 是否使用X5内核
             */
            @Override
            public void onViewInitFinished(boolean isSuccess) {
                //x5內核初始化完成的回调，为true表示x5内核加载成功，
                // 否则表示x5内核加载失败，会自动切换到系统内核。
                Log.e("filePreview", "onViewInitFinished:" + isSuccess);
                if (isSuccess) {
                    engineState = 10;
                    onInitListener.onInit(engineState);
                } else {
                    engineState=11;
                    onInitListener.onInit(engineState);
                }
            }
        });
    }

    public interface OnInitListener {
        void onInit(int status);
    }
}
