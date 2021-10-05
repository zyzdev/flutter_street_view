import Flutter
import UIKit

class FlutterGoogleStreetViewFactory: NSObject, FlutterPlatformViewFactory {
    private var _registrar: FlutterPluginRegistrar
    private var messenger: FlutterBinaryMessenger

    init(registrar: FlutterPluginRegistrar) {
        _registrar = registrar;
        self.messenger = registrar.messenger()
        super.init()
    }

    func create(
        withFrame frame: CGRect,
        viewIdentifier viewId: Int64,
        arguments args: Any?
    ) -> FlutterPlatformView {
        return FlutterGoogleStreetView(
            frame: frame,
            viewIdentifier: viewId,
            arguments: args,
            binaryMessenger: messenger,
            flutterPluginRegistrar: _registrar)
    }
    
    public func createArgsCodec() -> FlutterMessageCodec & NSObjectProtocol {
          return FlutterStandardMessageCodec.sharedInstance()
    }
}
