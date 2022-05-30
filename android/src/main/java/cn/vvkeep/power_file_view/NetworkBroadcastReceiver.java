package cn.vvkeep.power_file_view;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.net.ConnectivityManager;

public class NetworkBroadcastReceiver extends BroadcastReceiver {

    private  OnNetworkChangeListener onNetworkChangeListener;

    public NetworkBroadcastReceiver(OnNetworkChangeListener onNetworkChangeListener) {
        this.onNetworkChangeListener = onNetworkChangeListener;
    }

    @Override
    public void onReceive(Context context, Intent intent) {
        if (intent.getAction() != null && intent.getAction().equals(ConnectivityManager.CONNECTIVITY_ACTION)) {
            boolean isConnected = NetworkUtils.isConnected(context);
            // 当网络发生变化，判断当前网络状态，并通过NetEvent回调当前网络状态
            if (onNetworkChangeListener != null) {
                onNetworkChangeListener.onNetworkChange(isConnected);
            }
        }
    }


    public  interface  OnNetworkChangeListener{
        void  onNetworkChange(boolean isConnected);
    }
}
