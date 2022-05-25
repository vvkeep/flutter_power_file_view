#import "FlutterPowerFilePreviewPlugin.h"
#if __has_include(<flutter_power_file_preview/flutter_power_file_preview-Swift.h>)
#import <flutter_power_file_preview/flutter_power_file_preview-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "flutter_power_file_preview-Swift.h"
#endif

@implementation FlutterPowerFilePreviewPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftFlutterPowerFilePreviewPlugin registerWithRegistrar:registrar];
}
@end
