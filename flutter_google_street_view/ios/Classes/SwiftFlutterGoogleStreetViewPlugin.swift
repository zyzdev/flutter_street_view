import Flutter
import UIKit

public class SwiftFlutterGoogleStreetViewPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
      let factory = FlutterGoogleStreetViewFactory(registrar: registrar)
            registrar.register(factory, withId: "my_street_view")
  }
}
