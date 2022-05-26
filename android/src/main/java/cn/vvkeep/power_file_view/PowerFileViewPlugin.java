package cn.vvkeep.power_file_view;


import android.app.Activity;
import android.content.Context;

import androidx.annotation.NonNull;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;

/**
 * FlutterPowerFilePreviewPlugin
 */
public class PowerFileViewPlugin implements FlutterPlugin, MethodCallHandler, ActivityAware {

    public static final String channelName = "vvkeep.power_file_view.io.channel";
    public static final String viewName = "vvkeep.power_file_view.view";

    private MethodChannel channel;
    private Context context;
    private FlutterPluginBinding pluginBinding;
    private Activity activity;


    private void init(Context context, BinaryMessenger messenger) {
        this.context = context;
        channel = new MethodChannel(messenger, channelName);
        channel.setMethodCallHandler(this);
    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
        switch (call.method) {
            case "getPlatformVersion":
                result.success("Android " + android.os.Build.VERSION.RELEASE);
                break;
            case "initEngine":
                if (SPUtils.contains(context, SPUtils.STATUS_KEY)) {
                    int engineState = (int) SPUtils.get(context, SPUtils.STATUS_KEY, EngineState.none.getValue());
                    if (engineState == EngineState.done.getValue()) {
                        activity.runOnUiThread(new Runnable() {
                            @Override
                            public void run() {
                                channel.invokeMethod("engineState", engineState);
                            }
                        });
                        return;
                    }
                }
                TBSManager.getInstance().initTBS(context, new TBSManager.OnInitListener() {
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
                break;
            case "getEngineState":
                if (SPUtils.contains(context, SPUtils.STATUS_KEY)) {
                    int engineState = (int) SPUtils.get(context, SPUtils.STATUS_KEY, EngineState.none.getValue());
                    if (engineState == EngineState.done.getValue()) {
                        result.success(EngineState.done.getValue());
                        break;
                    }
                }
                result.success(TBSManager.getInstance().engineState.getValue());
                break;
            default:
                result.notImplemented();
                break;
        }
    }

    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
        pluginBinding = flutterPluginBinding;
    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
        channel.setMethodCallHandler(null);
    }

    @Override
    public void onAttachedToActivity(@NonNull ActivityPluginBinding binding) {
        activity = binding.getActivity();
        init(pluginBinding.getApplicationContext(), pluginBinding.getBinaryMessenger());
        pluginBinding.getPlatformViewRegistry().registerViewFactory(viewName,
                new PowerFileViewFactory(pluginBinding.getBinaryMessenger(),
                        binding.getActivity(), this));
    }

    @Override
    public void onDetachedFromActivityForConfigChanges() {

    }

    @Override
    public void onReattachedToActivityForConfigChanges(@NonNull ActivityPluginBinding binding) {

    }

    @Override
    public void onDetachedFromActivity() {

    }


}
