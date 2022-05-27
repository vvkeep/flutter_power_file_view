package cn.vvkeep.power_file_view;

import android.content.Context;
import android.os.Bundle;
import android.text.TextUtils;
import android.view.View;
import android.view.ViewGroup;
import android.widget.FrameLayout;

import androidx.annotation.NonNull;

import com.tencent.smtt.sdk.TbsReaderView;

import java.io.File;
import java.util.Map;

import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.platform.PlatformView;

public class PowerFileView implements PlatformView {

    private MethodChannel channel;
    private TbsReaderView readerView;
    private final FrameLayout frameLayout;
    private final String tempPath;
    private final String filePath;

    public PowerFileView(Context context,
                         BinaryMessenger messenger,
                         int id,
                         Map<String, Object> params,
                         PowerFileViewPlugin plugin) {

        channel = new MethodChannel(messenger, PowerFileViewPlugin.channelName + "_" + id);
        channel.setMethodCallHandler(new MethodChannel.MethodCallHandler() {
            @Override
            public void onMethodCall(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
                if (call.method.equals("refreshView")) {
                    refresh(context);
                }
            }
        });
        tempPath = context.getCacheDir().toString() + File.separator + "TbsReaderTemp";
        // The Context here requires Activity  这里的Context需要Activity
        frameLayout = new FrameLayout(context);
        readerView = new TbsReaderView(context, new TbsReaderView.ReaderCallback() {
            @Override
            public void onCallBackAction(Integer integer, Object o, Object o1) {
            }
        });
        frameLayout.setLayoutParams(new ViewGroup.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT));
        readerView.setLayoutParams(new ViewGroup.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT));
        frameLayout.addView(readerView);
        filePath = (String) params.get("filePath");
        openFile();
    }

    private void openFile() {
        if (isSupportFile(filePath)) {
            LogUtils.e("openFile");
            //Fix the problem that no TbsReaderTemp folder exists causing the file to fail to load
            //增加下面一句解决没有TbsReaderTemp文件夹存在导致加载文件失败
            File bsReaderTempFile = new File(tempPath);
            if (!bsReaderTempFile.exists()) {
                boolean isSuccess = bsReaderTempFile.mkdir();
            }

            // load file 加载文件
            Bundle localBundle = new Bundle();
            localBundle.putString("filePath", filePath);
            localBundle.putString("tempPath", tempPath);
            readerView.openFile(localBundle);
        }

    }

    private boolean isSupportFile(String filePath) {
        return readerView.preOpen(getFileType(filePath), false);
    }

    private String getFileType(String filePath) {
        String type = "";
        if (TextUtils.isEmpty(filePath)) {
            return type;
        }

        int i = filePath.lastIndexOf(".");
        if (i <= -1) {
            return type;
        }

        type = filePath.substring(i + 1);

        return type;
    }

    private void refresh(Context context) {
        frameLayout.removeView(readerView);
        readerView.onStop();
        readerView = null;
        readerView = new TbsReaderView(context, new TbsReaderView.ReaderCallback() {
            @Override
            public void onCallBackAction(Integer integer, Object o, Object o1) {
            }
        });
        frameLayout.addView(readerView);
        openFile();
        frameLayout.requestLayout();
    }

    @Override
    public View getView() {
        return frameLayout;
    }

    @Override
    public void dispose() {
        readerView.onStop();
        channel.setMethodCallHandler(null);
    }
}
