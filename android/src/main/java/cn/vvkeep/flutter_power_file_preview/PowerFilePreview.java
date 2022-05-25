package cn.vvkeep.flutter_power_file_preview;

import android.content.Context;
import android.os.Bundle;
import android.text.TextUtils;
import android.view.View;
import android.view.ViewGroup;

import com.tencent.smtt.sdk.TbsReaderView;

import java.io.File;
import java.util.Map;

import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.platform.PlatformView;

public class PowerFilePreview implements PlatformView {

    private MethodChannel methodChannel;
    private TbsReaderView readerView;
    private String tempPath;
    private String filePath;
    private String fileType;
    private FlutterPowerFilePreviewPlugin plugin;

    public PowerFilePreview(Context context,
                            BinaryMessenger messenger,
                            int id,
                            Map<String, Object> params,
                            FlutterPowerFilePreviewPlugin plugin) {
        this.plugin = plugin;
        tempPath = context.getCacheDir() + "/" + "TbsReaderTemp";
        readerView = new TbsReaderView(context, new TbsReaderView.ReaderCallback() {
            @Override
            public void onCallBackAction(Integer integer, Object o, Object o1) {

            }
        });
        readerView.setLayoutParams(new ViewGroup.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT));
        methodChannel = new MethodChannel(messenger, FlutterPowerFilePreviewPlugin.channelName + "_" + id);
        filePath = (String) params.get("filePath");
        fileType = (String) params.get("fileType");
        loadFile();
    }

    private void loadFile() {
        openFile();
    }

    private void openFile() {
        if (isSupportFile(filePath)) {
            //增加下面一句解决没有TbsReaderTemp文件夹存在导致加载文件失败
            File bsReaderTempFile = new File(tempPath);
            if (!bsReaderTempFile.exists()) {
                bsReaderTempFile.mkdir();
            }
            //加载文件
            Bundle localBundle = new Bundle();
            localBundle.putString("filePath", filePath);
            localBundle.putBoolean("is_bar_show", false);
            localBundle.putBoolean("menu_show", false);
            localBundle.putBoolean("is_bar_animating", false);
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
        if (i < -1) {
            return type;
        }

        type = fileType.substring(i + 1);

        return type;
    }

    @Override
    public View getView() {
        return readerView;
    }

    @Override
    public void dispose() {
        readerView.onStop();
    }
}
