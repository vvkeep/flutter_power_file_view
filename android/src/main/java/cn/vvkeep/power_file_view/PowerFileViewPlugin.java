package cn.vvkeep.power_file_view;


import android.app.Activity;
import android.content.Context;
import android.content.IntentFilter;
import android.util.Log;

import androidx.annotation.NonNull;

import com.tencent.smtt.export.external.TbsCoreSettings;
import com.tencent.smtt.sdk.QbSdk;
import com.tencent.smtt.sdk.TbsDownloader;
import com.tencent.smtt.sdk.TbsListener;

import java.io.File;
import java.util.HashMap;
import java.util.Objects;

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
    private NetworkBroadcastReceiver mReceiver;
    private Activity activity;
    private Context context;
    private EngineState engineState = EngineState.none;

    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
        LogUtils.e("onAttachedToEngine");
        pluginBinding = flutterPluginBinding;
    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
        LogUtils.e("onDetachedFromEngine");
        channel.setMethodCallHandler(null);
        if (mReceiver != null && context != null) {
            context.unregisterReceiver(mReceiver);
        }
    }

    private void init(Context context, BinaryMessenger messenger) {
        this.context = context;
        registerBroadcast(context);
        channel = new MethodChannel(messenger, channelName);
        channel.setMethodCallHandler(new MethodCallHandler() {
            @Override
            public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
                switch (call.method) {
                    case "getPlatformVersion":
                        result.success("Android " + android.os.Build.VERSION.RELEASE);
                        break;
                    case "initEngine":
                        initX5(context, false);
                        break;
                    case "getEngineState":
                        result.success(engineState.getValue());
                        break;
                    case "pluginLogEnable":
                        LogUtils.enable = (boolean) call.arguments;
                        break;
                    case "resetEngine":
                        initX5(context, true);
                        break;
                    case "clearCache":
                        String dir = context.getCacheDir().toString() + File.separator + "TbsReaderTemp";
                        File dirPath = new File(dir);
                        clearCache(dirPath);
                        break;
                    default:
                        result.notImplemented();
                        break;
                }
            }
        });
    }

    private void registerBroadcast(Context context) {
        IntentFilter filter = new IntentFilter();
        filter.addAction("android.net.conn.CONNECTIVITY_CHANGE");
        mReceiver = new NetworkBroadcastReceiver(new NetworkBroadcastReceiver.OnNetworkChangeListener() {
            @Override
            public void onNetworkChange(boolean isConnected) {
                LogUtils.e("isConnected:"+isConnected);
                if (!isConnected && engineState == EngineState.downloading) {
                    engineState = EngineState.downloadFail;
                    TbsDownloader.stopDownload();
                    channel.invokeMethod("engineState", engineState.getValue());
                }
            }
        });
        context.registerReceiver(mReceiver, filter);
    }

    @Override
    public void onAttachedToActivity(@NonNull ActivityPluginBinding binding) {
        LogUtils.e("onAttachedToActivity");
        activity = binding.getActivity();
        init(pluginBinding.getApplicationContext(), pluginBinding.getBinaryMessenger());
        pluginBinding.getPlatformViewRegistry().registerViewFactory(viewName,
                new PowerFileViewFactory(pluginBinding.getBinaryMessenger(),
                        binding.getActivity(), this));
    }

    @Override
    public void onDetachedFromActivityForConfigChanges() {
        LogUtils.e("onDetachedFromActivityForConfigChanges");
    }

    @Override
    public void onReattachedToActivityForConfigChanges(@NonNull ActivityPluginBinding binding) {
        LogUtils.e("onReattachedToActivityForConfigChanges");
    }

    @Override
    public void onDetachedFromActivity() {
        LogUtils.e("onDetachedFromActivity");
    }


    public void initX5(Context context, boolean isReset) {
        if (isReset) {
            //If the download fails, the cache must be cleared or the initialization sdk will be invalidated
            //?????????????????????????????????????????????????????????sdk?????????
            QbSdk.reset(context);
        }
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

    }

    /**
     * Initialize the Tencent TBS service
     * <p>
     * ???????????????TBS??????
     */
    public void initTBS(Context context, OnInitListener onInitListener) {
        //Disable access to the privacy API
        //????????????API?????????
        QbSdk.canGetAndroidId(false);
        QbSdk.canGetDeviceId(false);
        QbSdk.canGetSubscriberId(false);
        QbSdk.disableSensitiveApi();

        //Before calling TBS initialization and creating a WebView, configure the following configuration to enable the optimization scheme
        // ?????????TBS??????????????????WebView????????????????????????????????????????????????
        HashMap<String, Object> map = new HashMap<String, Object>();
        map.put(TbsCoreSettings.TBS_SETTINGS_USE_SPEEDY_CLASSLOADER, true);
        map.put(TbsCoreSettings.TBS_SETTINGS_USE_DEXLOADER_SERVICE, true);
        QbSdk.initTbsSettings(map);

        //Allows the kernel to be downloaded using traffic
        //??????????????????????????????
        QbSdk.setDownloadWithoutWifi(true);

        engineState = EngineState.start;
        if (onInitListener != null) {
            onInitListener.onInit(engineState);
        }

        QbSdk.setTbsListener(new TbsListener() {
            @Override
            public void onDownloadFinish(int i) {
                if (i != 0) {
                    //The status at the end of the download, the errorcode is 100 when the download is successful, the others are failures, and the external does not need to pay attention to the specific reason for the failure
                    //??????????????????????????????????????????errorCode???100,???????????????????????????????????????????????????????????????
                    if (i == 100) {
                        engineState = EngineState.downloadSuccess;
                    } else {
                        engineState = EngineState.downloadFail;
                    }
                    LogUtils.e("onDownloadFinish -->Download X5 core status???" + i);
                    if (onInitListener != null) {
                        onInitListener.onInit(engineState);
                    }
                }
            }

            @Override
            public void onInstallFinish(int i) {
                //The status at the end of the installation, the errorcode is 200 when the installation is successful, the others are failures, and the external does not need to pay attention to the specific reason for the failure
                //??????????????????????????????????????????errorCode???200,???????????????????????????????????????????????????????????????
                LogUtils.e("onInstallFinish -->install X5 core status???" + i);
                if (i == 200) {
                    engineState = EngineState.installSuccess;
                } else {
                    engineState = EngineState.installFail;
                }
                if (onInitListener != null) {
                    onInitListener.onInit(engineState);
                }
            }

            @Override
            public void onDownloadProgress(int i) {
                //Notification of the download process, providing the current download progress [0-100]
                //????????????????????????????????????????????????[0-100]
                LogUtils.e("onDownloadProgress -->Download X5 core progress???" + i);
                engineState = EngineState.downloading;
                if (onInitListener != null) {
                    onInitListener.onDownload(i);
                }
            }
        });

        //Initialize the x5 environment
        //?????????x5??????
        QbSdk.initX5Environment(context, new QbSdk.PreInitCallback() {
            @Override
            public void onCoreInitFinished() {
                int tbsVersion = QbSdk.getTbsVersion(context);
                //x5 kernel initialization completion callback interface, this interface callback and indicates that x5 has been loaded, it is possible that the x5 kernel failed to load in special cases, switch to the system kernel.
                //x5?????????????????????????????????????????????????????????????????????????????????x5???????????????????????????x5?????????????????????????????????????????????
                LogUtils.e("onCoreInitFinished:  X5 core version???" + tbsVersion);
            }


            @Override
            public void onViewInitFinished(boolean isSuccess) {
                //The callback where the x5 kernel initialization is complete, true indicates that the x5 kernel load was successful, otherwise it means that the x5 kernel failed to load, and it will automatically switch to the system kernel.
                //x5????????????????????????????????????true??????x5?????????????????????????????????x5??????????????????????????????????????????????????????
                LogUtils.e("onViewInitFinished:  load X5 core:" + isSuccess);
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

    private void clearCache(File dirPath) {
        if (!dirPath.exists() || !dirPath.isDirectory()) {
            return;
        }
        if (dirPath.listFiles() != null) {
            for (File file : Objects.requireNonNull(dirPath.listFiles())) {
                if (file.isFile()) {
                    boolean isSuccess = file.delete();
                } else if (file.isDirectory()) {
                    clearCache(file);
                }
            }
        }
    }


}
