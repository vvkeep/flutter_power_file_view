package cn.vvkeep.power_file_view;


import android.content.Context;
import android.net.ConnectivityManager;
import android.net.NetworkCapabilities;
import android.net.NetworkInfo;
import android.os.Build;

public final class NetworkUtils {
    /**
     * 判断网络连接是否已开
     * true 已打开  false 未打开
     *
     * @param context
     * @return
     */
    public static boolean isConnected(Context context) {
        ConnectivityManager manager = (ConnectivityManager) context.getSystemService(Context.CONNECTIVITY_SERVICE);
        if (manager != null) {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                NetworkCapabilities networkCapabilities = manager.getNetworkCapabilities(manager.getActiveNetwork());
                if (networkCapabilities != null) {
                    return networkCapabilities.hasTransport(NetworkCapabilities.TRANSPORT_WIFI)//WIFI
                            || networkCapabilities.hasTransport(NetworkCapabilities.TRANSPORT_CELLULAR)//移动数据
                            || networkCapabilities.hasTransport(NetworkCapabilities.TRANSPORT_ETHERNET);//以太网
                }
            } else {//23以下
                NetworkInfo networkInfo = manager.getActiveNetworkInfo();
                return networkInfo != null
                        && (networkInfo.getType() == ConnectivityManager.TYPE_WIFI || networkInfo.getType() == ConnectivityManager.TYPE_MOBILE);
            }
        }
        return false;
    }
}
