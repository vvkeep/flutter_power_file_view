package cn.vvkeep.power_file_view;


import android.app.Activity;
import android.content.Context;

import androidx.annotation.NonNull;

import com.tencent.smtt.export.external.TbsCoreSettings;
import com.tencent.smtt.sdk.QbSdk;
import com.tencent.smtt.sdk.TbsListener;

import java.util.HashMap;

import io.flutter.Log;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;

public class PowerFileViewPlugin implements FlutterPlugin, ActivityAware {

    public static final String channelName = "vvkeep.power_file_view.io.channel";
    public static final String viewName = "vvkeep.power_file_view.view";

    private MethodChannel channel;
    private FlutterPluginBinding pluginBinding;
    private Activity activity;
    private EngineState engineState = EngineState.none;

    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
        LogUtils.e("PowerFileViewPlugin", "onAttachedToEngine");
        pluginBinding = flutterPluginBinding;
    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
        LogUtils.e("PowerFileViewPlugin", "onDetachedFromEngine");
        channel.setMethodCallHandler(null);
    }

    private void init(Context context, BinaryMessenger messenger) {
        channel = new MethodChannel(messenger, channelName);
        channel.setMethodCallHandler(new MethodCallHandler() {
            @Override
            public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
                switch (call.method) {
                    case "getPlatformVersion":
                        result.success("Android " + android.os.Build.VERSION.RELEASE);
                        break;
                    case "initEngine":
                        initX5(context);
                        break;
                    case "getEngineState":
                        result.success(engineState.getValue());
                        break;
                    case "pluginLogEnable":
                        LogUtils.enable = (boolean) call.arguments;
                        break;
                    default:
                        result.notImplemented();
                        break;
                }
            }
        });
    }

    @Override
    public void onAttachedToActivity(@NonNull ActivityPluginBinding binding) {
        activity = binding.getActivity();
        LogUtils.e("PowerFileViewPlugin", "onAttachedToActivity");
        init(pluginBinding.getApplicationContext(), pluginBinding.getBinaryMessenger());
        pluginBinding.getPlatformViewRegistry().registerViewFactory(viewName,
                new PowerFileViewFactory(pluginBinding.getBinaryMessenger(),
                        binding.getActivity(), this));
    }

    @Override
    public void onDetachedFromActivityForConfigChanges() {
        LogUtils.e("PowerFileViewPlugin", "onDetachedFromActivityForConfigChanges");
    }

    @Override
    public void onReattachedToActivityForConfigChanges(@NonNull ActivityPluginBinding binding) {
        LogUtils.e("PowerFileViewPlugin", "onReattachedToActivityForConfigChanges");
    }

    @Override
    public void onDetachedFromActivity() {
        LogUtils.e("PowerFileViewPlugin", "onDetachedFromActivity");
    }


    public void initX5(Context context) {
        if (NetworkUtils.isConnected(context)) {
            initTBS(context, new OnInitListener() {
                @Override
                public void onInit(EngineState status) {
                    activity.runOnUiThread(new Runnable() {
                        @Override
                        public void run() {
                            channel.invokeMethod("engineState", status.getValue());
                        }
                    });
                }

                @Override
                public void onDownload(int progress) {
                    activity.runOnUiThread(new Runnable() {
                        @Override
                        public void run() {
                            channel.invokeMethod("engineDownloadProgress", progress);
                        }
                    });
                }
            });
        } else {
            LogUtils.e("initFail", "networkError");
            channel.invokeMethod("engineState", EngineState.error.getValue());
        }
    }

    //初始化TBS服务
    public void initTBS(Context context, OnInitListener onInitListener) {
        //禁用隐私API的获取
        ///不获取AndroidID
        QbSdk.canGetAndroidId(false);
        ///不获取设备IMEI
        QbSdk.canGetDeviceId(false);
        ///不获取IMSI
        QbSdk.canGetSubscriberId(false);
        QbSdk.disableSensitiveApi();


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
                //110代表本次下载失败
                if (i == 110) {
                    engineState = EngineState.downloadFail;
                    if (onInitListener != null) {
                        onInitListener.onInit(engineState);
                    }
                    QbSdk.reset(context);
                    initX5(context);
                    return;
                }
                LogUtils.e("QbSdk", "onDownloadFinish -->下载X5内核状态：" + i);
                engineState = EngineState.downloadSuccess;
                if (onInitListener != null) {
                    onInitListener.onInit(engineState);
                }
            }

            @Override
            public void onInstallFinish(int i) {
                //安装结束时的状态，安装成功时errorCode为200,其他均为失败，外部不需要关注具体的失败原因
                LogUtils.e("QbSdk", "onInstallFinish -->安装X5内核进度：" + i);
                engineState = EngineState.installSuccess;
                if (onInitListener != null) {
                    onInitListener.onInit(engineState);
                }
            }

            @Override
            public void onDownloadProgress(int i) {
                //下载过程的通知，提供当前下载进度[0-100]
                LogUtils.e("QbSdk", "onDownloadProgress -->下载X5内核进度：" + i);
                engineState = EngineState.downloading;
                if (onInitListener != null) {
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
                LogUtils.e("QbSdk", "onCoreInitFinished: x5内核加载状态：" + tbsVersion);
                //大于0，代表加载的是x5内核
                if (tbsVersion > 0) {
                    engineState = EngineState.done;
                } else {
                    engineState = EngineState.error;
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
                LogUtils.e("QbSdk", "onViewInitFinished:" + isSuccess);
                if (isSuccess) {
                    engineState = EngineState.done;
                } else {
                    engineState = EngineState.error;
                    //如果内核加载失败、重置缓存、不然没法重新下载
                    QbSdk.reset(context);
                    initX5(context);
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
