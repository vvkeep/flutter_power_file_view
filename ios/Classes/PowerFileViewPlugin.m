#import "PowerFileViewPlugin.h"
#if __has_include(<power_file_view/power_file_view-Swift.h>)
#import <power_file_view/power_file_view-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "power_file_view-Swift.h"
#endif

@implementation PowerFileViewPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftPowerFileViewPlugin registerWithRegistrar:registrar];
}
@end
