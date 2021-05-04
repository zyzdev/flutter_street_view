#import "FlutterGoogleStreetViewPlugin.h"
#if __has_include(<flutter_google_street_view/flutter_google_street_view-Swift.h>)
#import <flutter_google_street_view/flutter_google_street_view-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "flutter_google_street_view-Swift.h"
#endif

@implementation FlutterGoogleStreetViewPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftFlutterGoogleStreetViewPlugin registerWithRegistrar:registrar];
}
@end
