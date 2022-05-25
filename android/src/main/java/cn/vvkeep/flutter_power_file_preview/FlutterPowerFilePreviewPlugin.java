package cn.vvkeep.flutter_power_file_preview;


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
public class FlutterPowerFilePreviewPlugin implements FlutterPlugin, MethodCallHandler, ActivityAware {

  public static final String channelName = "vvkeep.flutter_power_file_preview.io.channel";
  public static final String viewName = "vvkeep.flutter_file_view.io.view";

  private MethodChannel channel;
  private Context context;
  private FlutterPluginBinding pluginBinding;
  //  0 未加载状态  1开始 10 完成 11 错误 20 下载完成 21 下载失败 22 下载中 30 安装成功 31 安装失败
  private int engineState = 0;
  private Activity activity;


  private void init(Context context, BinaryMessenger messenger) {
    this.context = context;
    channel = new MethodChannel(messenger, channelName);
    channel.setMethodCallHandler(this);
  }

  @Override
  public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
    if (call.method.equals("getPlatformVersion")) {
      result.success("Android " + android.os.Build.VERSION.RELEASE);
    } else if (call.method.equals("initEngine")) {
      TBSManager.getInstance().initTBS(context, new TBSManager.OnInitListener() {
        @Override
        public void onInit(int status) {
          activity.runOnUiThread(new Runnable() {
            @Override
            public void run() {
              channel.invokeMethod("engineState",status);
            }
          });
        }
      });
    }
    else if (call.method.equals("getEngineState")) {
      result.success(TBSManager.getInstance().engineState);
    } else {
      result.notImplemented();
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
    activity=binding.getActivity();
    init(pluginBinding.getApplicationContext(), pluginBinding.getBinaryMessenger());
    pluginBinding.getPlatformViewRegistry().registerViewFactory(viewName,
            new PowerFilePreviewFactory(pluginBinding.getBinaryMessenger(),
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
