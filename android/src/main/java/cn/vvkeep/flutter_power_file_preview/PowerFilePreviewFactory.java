package cn.vvkeep.flutter_power_file_preview;

import android.content.Context;

import java.util.Map;

import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.StandardMessageCodec;
import io.flutter.plugin.platform.PlatformView;
import io.flutter.plugin.platform.PlatformViewFactory;

public class PowerFilePreviewFactory extends PlatformViewFactory {

    private Context mContext;
    private FlutterPowerFilePreviewPlugin plugin;
    private final BinaryMessenger messenger;

    public PowerFilePreviewFactory(BinaryMessenger messenger,
                                   Context context,
                                   FlutterPowerFilePreviewPlugin plugin) {
        super(StandardMessageCodec.INSTANCE);
        this.mContext = context;
        this.plugin = plugin;
        this.messenger = messenger;
    }

    @Override
    public PlatformView create(Context context, int viewId, Object args) {
        Map<String, Object> params = (Map<String, Object>) args;

        return new PowerFilePreview(mContext,messenger,viewId,params,plugin);
    }
}
