package cn.vvkeep.power_file_view;

import android.content.Context;

import com.tencent.smtt.export.external.TbsCoreSettings;
import com.tencent.smtt.sdk.QbSdk;
import com.tencent.smtt.sdk.TbsListener;

import java.util.HashMap;

import io.flutter.Log;

public class TBSManager {

    public EngineState engineState = EngineState.none;

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
        Log.e("initTBS：", engineState.toString());
        if (engineState == EngineState.done) {
            if (onInitListener != null) {
                onInitListener.onInit(engineState);
            }
            return;
        }
//        //禁用隐私API的获取
//        ///不获取AndroidID
//        QbSdk.canGetAndroidId(false);
//        ///不获取设备IMEI
//        QbSdk.canGetDeviceId(false);
//        ///不获取IMSI
//        QbSdk.canGetSubscriberId(false);

        //防止因为有缓存导致无法下载
        QbSdk.reset(context);


        // 在调用TBS初始化、创建WebView之前进行如下配置，以开启优化方案
        HashMap<String, Object> map = new HashMap<String, Object>();
        map.put(TbsCoreSettings.TBS_SETTINGS_USE_SPEEDY_CLASSLOADER, true);
        map.put(TbsCoreSettings.TBS_SETTINGS_USE_DEXLOADER_SERVICE, true);
        QbSdk.initTbsSettings(map);
        //运行使用WiFi下载内核
        QbSdk.setDownloadWithoutWifi(true);

        engineState = EngineState.start;
        if (onInitListener != null) {
            onInitListener.onInit(engineState);
        }

        QbSdk.setTbsListener(new TbsListener() {
            @Override
            public void onDownloadFinish(int i) {
                //下载结束时的状态，下载成功时errorCode为100,其他均为失败，外部不需要关注具体的失败原因
                Log.e("QbSdk", "onDownloadFinish -->下载X5内核状态：" + i);
                engineState = EngineState.downloadSuccess;
                if (onInitListener != null) {
                    onInitListener.onInit(engineState);
                }
            }

            @Override
            public void onInstallFinish(int i) {
                //安装结束时的状态，安装成功时errorCode为200,其他均为失败，外部不需要关注具体的失败原因
                Log.e("QbSdk", "onInstallFinish -->安装X5内核进度：" + i);
                engineState = EngineState.installSuccess;
                if (onInitListener != null) {
                    onInitListener.onInit(engineState);
                }
            }

            @Override
            public void onDownloadProgress(int i) {
                //下载过程的通知，提供当前下载进度[0-100]
                Log.e("QbSdk", "onDownloadProgress -->下载X5内核进度：" + i);
                engineState = EngineState.downloading;
                if (onInitListener != null) {
                    onInitListener.onInit(engineState);
                    onInitListener.onDownload(i);
                }
            }
        });

        //初始化x5环境
        QbSdk.initX5Environment(context, new QbSdk.PreInitCallback() {

            @Override
            public void onCoreInitFinished() {
                int tbsVersion = QbSdk.getTbsVersion(context);
                //x5内核初始化完成回调接口，此接口回调并表示已经加载起来了x5，
                // 有可能特殊情况下x5内核加载失败，切换到系统内核。
                Log.e("QbSdk", "onCoreInitFinished: x5内核加载成功");
                Log.e("QbSdk", "onCoreInitFinished: x5内核加载成功" + tbsVersion);
                //大于0，代表加载的是x5内核
                if (tbsVersion > 0) {
                    engineState = EngineState.done;
                    SPUtils.put(context, SPUtils.STATUS_KEY, EngineState.done.getValue());
                } else {
                    engineState = EngineState.error;
                    SPUtils.put(context, SPUtils.STATUS_KEY, EngineState.error.getValue());
                }
                if (onInitListener != null) {
                    onInitListener.onInit(engineState);
                }
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
                Log.e("QbSdk", "onViewInitFinished:" + isSuccess);
                if (isSuccess) {
                    engineState = EngineState.done;
                } else {
                    engineState = EngineState.error;
                }
                if (onInitListener != null) {
                    onInitListener.onInit(engineState);
                }
            }
        });
    }

    public interface OnInitListener {
        void onInit(EngineState status);

        void onDownload(int progress);
    }
}
