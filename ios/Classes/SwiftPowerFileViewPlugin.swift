import Flutter
import UIKit

let channelName = "vvkeep.power_file_view.io.channel"
let viewName = "vvkeep.power_file_view.view"

public class SwiftPowerFileViewPlugin: NSObject, FlutterPlugin {
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: channelName, binaryMessenger: registrar.messenger())
        let instance = SwiftPowerFileViewPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
        registrar.register(PowerFileViewFactory.init(messenger: registrar.messenger()), withId: viewName)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "getPlatformVersion":
            result("iOS " + UIDevice.current.systemVersion);
        default:
            break;
        }
    }
}
