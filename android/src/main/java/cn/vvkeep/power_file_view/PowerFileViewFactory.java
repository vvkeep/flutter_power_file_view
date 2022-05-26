package cn.vvkeep.power_file_view;

import android.content.Context;

import java.util.Map;

import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.StandardMessageCodec;
import io.flutter.plugin.platform.PlatformView;
import io.flutter.plugin.platform.PlatformViewFactory;

public class PowerFileViewFactory extends PlatformViewFactory {

    private Context mContext;
    private PowerFileViewPlugin plugin;
    private final BinaryMessenger messenger;

    public PowerFileViewFactory(BinaryMessenger messenger,
                                Context context,
                                PowerFileViewPlugin plugin) {
        super(StandardMessageCodec.INSTANCE);
        this.mContext = context;
        this.plugin = plugin;
        this.messenger = messenger;
    }

    @Override
    public PlatformView create(Context context, int viewId, Object args) {
        Map<String, Object> params = (Map<String, Object>) args;

        return new PowerFileView(mContext, messenger, viewId, params, plugin);
    }
}
