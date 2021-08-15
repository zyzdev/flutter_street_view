import Flutter
import UIKit

public class SwiftFlutterGoogleStreetViewPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
      let factory = FlutterGoogleStreetViewFactory(messenger: registrar.messenger())
            registrar.register(factory, withId: "my_street_view")
  }
}
