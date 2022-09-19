# flutter_google_street_view

A Flutter widget plugin to provide google street view. ([Web][web], [Android][android], [iOS][ios])

[web]:https://developers.google.com/maps/documentation/javascript/streetview#StreetViewPanoramas
[android]:https://developers.google.com/maps/documentation/android-sdk/streetview
[ios]:https://developers.google.com/maps/documentation/ios-sdk/streetview
## Getting Started

* Get an API key at <https://cloud.google.com/maps-platform/>.

* Enable Google Map SDK for each platform.
  * Go to [Google Developers Console](https://console.cloud.google.com/).
  * Choose the project that you want to enable Google Maps on.
  * Select the navigation menu and then select "Google Maps".
  * Select "APIs" under the Google Maps menu.
  * To enable Google Maps for Android, select "Maps SDK for Android" in the "Additional APIs" section, then select "ENABLE".
  * To enable Google Maps for iOS, select "Maps SDK for iOS" in the "Additional APIs" section, then select "ENABLE".
  * Make sure the APIs you enabled are under the "Enabled APIs" section.

For more details, see [Getting started with Google Maps Platform](https://developers.google.com/maps/gmp-get-started).

### Web

Specify your API key in the `web/index.html`:

```html
<head>
  
  <script src="https://maps.googleapis.com/maps/api/js?key=YOUR_API_KEY"></script>

</head>
```

### Android

Specify your API key in the application manifest `android/app/src/main/AndroidManifest.xml`:

```xml
<manifest ...
  <application ...
    <meta-data android:name="com.google.android.geo.API_KEY"
               android:value="YOUR KEY HERE"/>
```

### iOS

Specify your API key in the application delegate `ios/Runner/AppDelegate.m`:

```objectivec
#include "AppDelegate.h"
#include "GeneratedPluginRegistrant.h"
#import "GoogleMaps/GoogleMaps.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  [GMSServices provideAPIKey:@"YOUR KEY HERE"];
  [GeneratedPluginRegistrant registerWithRegistry:self];
  return [super application:application didFinishLaunchingWithOptions:launchOptions];
}
@end
```

Or in your swift code, specify your API key in the application delegate `ios/Runner/AppDelegate.swift`:

```swift
import UIKit
import Flutter
import GoogleMaps

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GMSServices.provideAPIKey("YOUR KEY HERE")
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
```

## ScreenShot
| Android  | Web | iOS |
| ------------- | ------------- | ------------- |
| <img title="Android" src="https://user-images.githubusercontent.com/16483162/145322579-e9f6e838-9b81-480c-a808-5d3ec67de3b6.png" width="300" />  | <img title="Web"  src="https://user-images.githubusercontent.com/16483162/145323571-c8acff70-5e33-4225-8627-b2e92ef7db36.png" width="650"/> |<img title="iOS"  src="https://user-images.githubusercontent.com/16483162/145323552-86f27e40-6334-4e5f-8382-c6b73ceb2ddb.png" width="300"/> |

## Control street view widget

Add FlutterGoogleStreetView widget to your widget tree.

You can control street view by `StreetViewController` that is received at `onStreetViewCreated` callback. 

## Sample Usage

For more usage, please run `example` to get complete sample app. 

The code shown below is how to init `FlutterGoogleStreetView`, and you can find it at `example/lib/demo/street_view_panorama_init.dart`

Before you run `example`, follow [Getting Started](#getting-started) to specify your API key first!

```dart
class StreetViewPanoramaInitDemo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Street View Init Demo'),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: SafeArea(
          child: Stack(
            children: [
              FlutterGoogleStreetView(
                /**
                 * It not necessary but you can set init position
                 * choice one of initPos or initPanoId
                 * do not feed param to both of them, or you should get assert error
                 */
                //initPos: SAN_FRAN,
                initPos: LatLng(25.0780892, 121.5753234),
                //initPanoId: SANTORINI,

                /**
                 *  It is worked while you set initPos or initPanoId.
                 *  initSource is a filter setting to filter panorama
                 */
                initSource: StreetViewSource.outdoor,

                /**
                 *  It is worked while you set initPos or initPanoId.
                 *  initBearing can set default bearing of camera.
                 */
                initBearing: 30,

                /**
                 *  It is worked while you set initPos or initPanoId.
                 *  initTilt can set default tilt of camera.
                 */
                //initTilt: 30,

                /**
                 *  It is worked while you set initPos or initPanoId.
                 *  initZoom can set default zoom of camera.
                 */
                //initZoom: 1.5,

                /**
                 *  iOS Only
                 *  It is worked while you set initPos or initPanoId.
                 *  initFov can set default fov of camera.
                 */
                //initFov: 120,

                /**
                 *  Web not support
                 *  Set street view can panning gestures or not.
                 *  default setting is true
                 */
                //panningGesturesEnabled: false,

                /**
                 *  Set street view shows street name or not.
                 *  default setting is true
                 */
                //streetNamesEnabled: true,

                /**
                 *  Set street view can allow user move to other panorama or not.
                 *  default setting is true
                 */
                //userNavigationEnabled: true,

                /**
                 *  Web not support
                 *  Set street view can zoom gestures or not.
                 *  default setting is true
                 */
                zoomGesturesEnabled: false,

                // Web only
                //addressControl: false,
                //addressControlOptions: ControlPosition.bottom_center,
                //enableCloseButton: false,
                //fullscreenControl: false,
                //fullscreenControlOptions: ControlPosition.bottom_center,
                //linksControl: false,
                //scrollwheel: false,
                //panControl: false,
                //panControlOptions: ControlPosition.bottom_center,
                //zoomControl: false,
                //zoomControlOptions: ControlPosition.bottom_center,
                //visible: false,
                //onCloseClickListener: () {},
                // Web only

                /**
                 *  To control street view after street view was initialized.
                 *  You should set [StreetViewCreatedCallback] to onStreetViewCreated.
                 *  And you can using [controller] to control street view.
                 */
                onStreetViewCreated: (StreetViewController controller) async {
                  /*controller.animateTo(
                      duration: 750,
                      camera: StreetViewPanoramaCamera(
                          bearing: 90, tilt: 30, zoom: 3));*/
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```
## Created Count
Google is starting billing when instantiation panorama for all platform. ([JavaScript](https://developers.google.com/maps/documentation/javascript/usage-and-billing#dynamic-street-view), [Android](https://developers.google.com/maps/documentation/android-sdk/usage-and-billing#dynamic-street-view), [iOS](https://developers.google.com/maps/documentation/ios-sdk/usage-and-billing#dynamic-street-view))

To known the created count of street view, you can call api:
```Dart
int count = FlutterGoogleStreetView.createdCount;
```