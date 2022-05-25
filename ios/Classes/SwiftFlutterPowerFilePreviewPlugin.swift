import Flutter
import UIKit

let channelName = "vvkeep.flutter_power_file_preview.io.channel"
let viewName = "vvkeep.flutter_file_view.io.view"

public class SwiftFlutterPowerFilePreviewPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: channelName, binaryMessenger: registrar.messenger())
    let instance = SwiftFlutterPowerFilePreviewPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
    registrar.register(LocalFileViewerFactory.init(messenger: registrar.messenger()), withId: viewName)

  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    result("iOS " + UIDevice.current.systemVersion)
  }
}
