import Flutter
import UIKit
import GoogleMaps
import os.log

class FlutterGoogleStreetView: NSObject, FlutterPlatformView {

    private static var lockStreetView:[GMSPanoramaView : Bool] = [:]
    private let DEBUG = false;

    private var registrar: FlutterPluginRegistrar
    private var streetViewPanorama:GMSPanoramaView!
    private var methodChannel: FlutterMethodChannel
    private var initResult:FlutterResult? = nil
    private var streetViewInit = false
    private var lastMoveToPos :CLLocationCoordinate2D? = nil
    private var lastMoveToPanoId : String? = nil
    private var _markersController:FLTStreetViewMarkersController
    private var gestureDetector:UILongPressGestureRecognizer?
    private var creationParams: Any?
    private var reuseStreetView:Bool = false
    init(
        frame: CGRect,
        viewIdentifier viewId: Int64,
        arguments args: Any?,
        binaryMessenger messenger: FlutterBinaryMessenger,
        flutterPluginRegistrar: FlutterPluginRegistrar
    ) {
        registrar = flutterPluginRegistrar
        for it in FlutterGoogleStreetView.lockStreetView {
            let sv:GMSPanoramaView = it.key
            let inUse:Bool = it.value
            if(!inUse) {
                streetViewPanorama = sv
                FlutterGoogleStreetView.lockStreetView[streetViewPanorama] = true
                reuseStreetView = true
                break
            }
        }
        if(!reuseStreetView){
            streetViewPanorama = GMSPanoramaView(frame: .zero)
            FlutterGoogleStreetView.lockStreetView[streetViewPanorama] = true
        }
        methodChannel = FlutterMethodChannel(name: "flutter_google_street_view_\(viewId)", binaryMessenger: messenger)
        _markersController = FLTStreetViewMarkersController(methodChannel, streetViewPanorama: streetViewPanorama, registrar: registrar)
        super.init()
        methodChannel.setMethodCallHandler(handle)
        // iOS views can be created here
        let initParam = args as? NSDictionary
        creationParams = initParam
        setupListener()
        if(!reuseStreetView) {
            updateInitOptions(initParam, nil)
        }
    }

    func view() -> UIView {
        return streetViewPanorama
    }

    private func setupListener() {
        gestureDetector = UILongPressGestureRecognizer(target: self, action: #selector(self.onStreetViewPanoramaLongClick(_:)))
        streetViewPanorama.delegate = self
        streetViewPanorama.addGestureRecognizer(gestureDetector!)
    }

    func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let method = call.method
        let args = call.arguments
        debug(method)
        switch method {
        case "streetView#waitForStreetView":
            if(streetViewInit) {
                streetViewIsReady(result)
            } else {
                initResult = result
            }
            if(reuseStreetView) {
                updateInitOptions(creationParams, result)
                streetViewPanorama.alpha = 1
            }
        case "streetView#updateOptions":
            updateInitOptions(args, result)
        case "streetView#animateTo":
            animateTo(args, result)
        case "streetView#getLocation":
            getLocation(result)
        case "streetView#getPanoramaCamera":
            getPanoramaCamera(result)
        case "streetView#isPanningGesturesEnabled":
            result(isPanningGesturesEnabled())
        case "streetView#isStreetNamesEnabled":
            result(isStreetNamesEnabled())
        case "streetView#isUserNavigationEnabled":
            result(isUserNavigationEnabled())
        case "streetView#isZoomGesturesEnabled":
            result(isZoomGesturesEnabled())
        case "streetView#orientationToPoint":
            orientationToPoint(args, result)
        case "streetView#pointToOrientation":
            pointToOrientation(args, result)
        case "streetView#movePos":
            setPosition(args, result)
        case "streetView#setPanningGesturesEnabled":
            setPanningGesturesEnabled(args, result)
        case "streetView#setStreetNamesEnabled":
            setStreetNamesEnabled(args, result)
        case "streetView#setUserNavigationEnabled":
            setUserNavigationEnabled(args,result)
        case "streetView#setZoomGesturesEnabled":
            setZoomGesturesEnabled(args, result)
        case "markers#update":
            markerUpdate(args, result)
        case "streetView#deactivate":
            deactivateStreetView(result)
        default:
            print()
        }
    }
}

extension FlutterGoogleStreetView {

    private func toS(_ arg:Any?) -> String {
        return arg != nil ? String(describing: arg) : ""
    }

    private func debug(_ log:Any?,_ debug:Bool = false) {
        if(!DEBUG && !debug) {return}
        methodChannel.invokeMethod("log#onSend", arguments: "iOS flutter_google_street_view: \((log is String ? log as! String : self.toS(log)))")
    }

    private func streetViewIsReady(_ result:FlutterResult) {
        debug("streetViewIsReady")
        result(
            ["isPanningGesturesEnabled" : streetViewPanorama.orientationGestures,
             "isStreetNamesEnabled" : !streetViewPanorama.streetNamesHidden, "isUserNavigationEnabled" : streetViewPanorama.navigationGestures, "isZoomGesturesEnabled":streetViewPanorama.zoomGestures, "streetViewCount":FlutterGoogleStreetView.lockStreetView.count]
        )
    }

    private func updateInitOptions(_ args:Any?, _ result:FlutterResult?) {
        //debug("updateInitOptions:\(isNSDictionary(args))")
        if(!isNSDictionary(args)) {
            return
        }

        //let param = args as! NSDictionary
        //param.forEach { (key: Any, value: Any) in
        //    debug("key:\(String(describing: key)), value:\(String(describing: value))")
        //}
        setPosition(args)
        setPanningGesturesEnabled(args)
        setStreetNamesEnabled(args)
        setUserNavigationEnabled(args)
        setZoomGesturesEnabled(args)
        animateTo(args)
        if(result != nil) {
            streetViewIsReady(result!)
        }
    }

    private func animateTo(_ args: Any?, _ result:FlutterResult? = nil) {
        if(!isNSDictionary(args)) {
            return
        }
        let param = args as! NSDictionary
        let camera = streetViewPanorama.camera
        let zoom = Float((param["zoom"] as? Double ?? 1.0))
        let pitch = param["tilt"] as? Double ?? camera.orientation.pitch
        let heading = param["bearing"] as? CLLocationDirection ?? camera.orientation.heading
        let fov = param["fov"] as? Double ?? camera.fov
        let orientation = GMSOrientation(heading: heading, pitch: pitch)
        let to = GMSPanoramaCamera.init(orientation: orientation, zoom: zoom, fov: fov)
        //duration unit from dart is ms, but the unit of animationDuration is s
        let duration :Double = param["duration"] != nil ? (param["duration"] as! Double) / 1000 : 0.3
        debug("zoom:\(zoom), orientation:\(self.toS(orientation)), fov:\(fov), duration:\(duration)")
        streetViewPanorama.animate(to:to, animationDuration: duration)
        result?.self("animateTo done")
    }

    private func getLocation(_ result:FlutterResult) {
        let panorama = streetViewPanorama.panorama
        if(panorama != nil) {
            let panorama_ = panorama!
            result(streetViewPanoramaLocationToJson(panorama_))
            debug("getLocation is \(toS(streetViewPanoramaLocationToJson(panorama_)))")
        } else {
            debug("getLocation is nil")
            result(nil)
        }
    }

    private func getPanoramaCamera(_ result:FlutterResult) {
        result(streetViewPanoramaCameraToJson(streetViewPanorama.camera))
    }

    private func setPosition(_ args:Any?, _ result:FlutterResult? = nil) {
        if(!isNSDictionary(args)) {
            return
        }
        lastMoveToPos = nil
        lastMoveToPanoId = nil
        let param = args as! NSDictionary
        if(param["panoId"] != nil) {
            let panoId = param["panoId"] as! String
            lastMoveToPanoId = panoId
            streetViewPanorama.move(toPanoramaID: panoId)
        } else if(param["position"] != nil) {
            let tmp = param["position"]
            let pos = toLocation(tmp)
            lastMoveToPos = pos
            if(pos != nil) {
                let radius = param["radius"] as? UInt
                let source = toSource(param["source"])
                debug("pos:\(toS(pos)), radius:\(toS(radius)), source:\(toS(source?.rawValue))")
                if(radius != nil && source != nil) {
                    streetViewPanorama.moveNearCoordinate(pos!, radius: radius!, source: source!)
                } else if(radius != nil && source == nil) {
                    streetViewPanorama.moveNearCoordinate(pos!, radius: radius!)
                } else if(radius == nil && source != nil) {
                    streetViewPanorama.moveNearCoordinate(pos!, source: source!)
                } else {
                    streetViewPanorama.moveNearCoordinate(pos!)
                }
            }
        }
        result?.self(["setPosition done"])
    }

    private func setPanningGesturesEnabled(_ arg: Any?, _ result:FlutterResult? = nil) {
        var panningGesturesEnabled: Bool?
        if(!isNSDictionary(arg) && !isBool(arg)) {return}
        if(isNSDictionary(arg)) {
            let param = arg as! NSDictionary
            panningGesturesEnabled = param["panningGesturesEnabled"] != nil ? (param["panningGesturesEnabled"] as! Bool) : nil
        } else if(isBool(arg)) {
            panningGesturesEnabled = (arg as! Bool)
        }
        debug("panningGesturesEnabled:\(toS(panningGesturesEnabled))")
        if(panningGesturesEnabled != nil && isPanningGesturesEnabled() != panningGesturesEnabled) {
            streetViewPanorama.orientationGestures = panningGesturesEnabled!
        }
        if(result != nil) {
            result!("setPanningGesturesEnabled done")
        }
    }

    private func setStreetNamesEnabled(_ arg: Any?, _ result:FlutterResult? = nil) {
        var streetNamesEnabled: Bool?
        if(!isNSDictionary(arg) && !isBool(arg)) {return}
        if(isNSDictionary(arg)) {
            let param = arg as! NSDictionary
            streetNamesEnabled = param["streetNamesEnabled"] != nil ? (param["streetNamesEnabled"] as! Bool) : nil
        } else if(isBool(arg)) {
            streetNamesEnabled = (arg as! Bool)
        }
        debug("streetNamesEnabled:\(toS(streetNamesEnabled))")
        if(streetNamesEnabled != nil && isStreetNamesEnabled() != streetNamesEnabled) {
            streetViewPanorama.streetNamesHidden = !streetNamesEnabled!
        }
        result?.self("setStreetNamesEnabled done")
    }

    private func setUserNavigationEnabled(_ arg: Any?, _ result:FlutterResult? = nil) {
        var userNavigationEnabled: Bool?
        if(!isNSDictionary(arg) && !isBool(arg)) {return}
        if(isNSDictionary(arg)) {
            let param = arg as! NSDictionary
            userNavigationEnabled = param["userNavigationEnabled"] != nil ? (param["userNavigationEnabled"] as! Bool) : nil
        } else if(isBool(arg)) {
            userNavigationEnabled = (arg as! Bool)
        }
        debug("userNavigationEnabled:\(toS(userNavigationEnabled))")
        if(userNavigationEnabled != nil && isUserNavigationEnabled() != userNavigationEnabled) {
            streetViewPanorama.navigationGestures = userNavigationEnabled!
        }
        result?.self("setUserNavigationEnabled done")
    }

    private func setZoomGesturesEnabled(_ arg: Any?, _ result:FlutterResult? = nil) {
        var zoomGesturesEnabled: Bool?
        if(!isNSDictionary(arg) && !isBool(arg)) {return}
        if(isNSDictionary(arg)) {
            let param = arg as! NSDictionary
            zoomGesturesEnabled = param["zoomGesturesEnabled"] != nil ? (param["zoomGesturesEnabled"] as! Bool) : nil
        } else if(isBool(arg)) {
            zoomGesturesEnabled = (arg as! Bool)
        }
        debug("zoomGesturesEnabled:\(toS(zoomGesturesEnabled))")
        if(zoomGesturesEnabled != nil && isZoomGesturesEnabled() != zoomGesturesEnabled) {
            streetViewPanorama.zoomGestures = zoomGesturesEnabled!
        }
        result?.self("setZoomGesturesEnabled done")
    }

    private func isPanningGesturesEnabled() -> Bool{return streetViewPanorama.orientationGestures}

    private func isStreetNamesEnabled()-> Bool{return !streetViewPanorama.streetNamesHidden}

    private func isUserNavigationEnabled()-> Bool{return streetViewPanorama.navigationGestures}

    private func isZoomGesturesEnabled()-> Bool{return streetViewPanorama.zoomGestures}


    private func orientationToPoint(_ arg: Any?,_ result:FlutterResult) {
        if(!isNSDictionary(arg)) {return}
        let param = arg as! NSDictionary
        let bearing = param["bearing"] != nil ? toCLLocationDirection(param["bearing"]!) : nil
        let tilt = param["tilt"] != nil ? toDouble(param["tilt"]!) : nil
        if(bearing != nil && tilt != nil) {
            result(pointToJson(streetViewPanorama.point(for: GMSOrientation(heading: bearing!, pitch: tilt!))))
        } else {
            result(FlutterError(code: "streetView#orientationToPoint", message: "param include nil!", details: "bearing:\(toS(bearing)), tilt:\(toS(tilt))"))
        }
    }


    private func pointToOrientation(_ arg: Any?,_ result:FlutterResult) {
        if(!isNSArray(arg)) {return}
        let param = arg as! NSArray
        let x = param[0] as? Int
        let y = param[1] as? Int
        if(x != nil && y != nil) {
            result(orientationToJson(streetViewPanorama.orientation(for: CGPoint(x:x!, y:y!))))
        } else {
            result(FlutterError(code: "streetView#orientationToPoint", message: "param include nil!", details: "x:\(toS(x)), y:\(toS(y))"))
        }
    }

    private func markerUpdate(_ args:Any?, _ result:FlutterResult? = nil) {
        if(!isNSDictionary(args)) {
            return
        }
        let param = args as! NSDictionary
        if(param["markersToAdd"] is NSArray) {
            let markersToAdd = param["markersToAdd"] as! [Any];
            _markersController.addMarkers(markersToAdd)
        }
        if(param["markersToChange"] is NSArray) {
            let markersToChange = param["markersToChange"] as! [Any];
            _markersController.changeMarkers(markersToChange)
        }
        if(param["markerIdsToRemove"] is NSArray) {
            let markerIdsToRemove = param["markerIdsToRemove"] as! [Any];
            _markersController.removeMarkerIds(markerIdsToRemove)
        }
        result?.self(nil)
    }

    private func deactivateStreetView(_ result:FlutterResult) {
        // set to invisible like black screen
        streetViewPanorama.alpha = 0
        // remove listener
        streetViewPanorama.delegate = nil
        streetViewPanorama.removeGestureRecognizer(gestureDetector!)
        // reset control setting
        streetViewPanorama.zoomGestures = true
        streetViewPanorama.orientationGestures = true
        streetViewPanorama.streetNamesHidden = true
        streetViewPanorama.navigationGestures = true
        // reset pitch, heading and zoom
        streetViewPanorama.camera = GMSPanoramaCamera.init(orientation: GMSOrientation(heading: 0, pitch: 0), zoom: 1.0, fov: 90)
        FlutterGoogleStreetView.lockStreetView[streetViewPanorama] = false
        result(nil)
    }
    
    private func isNil(_ args : Any?) -> Bool { return args == nil }
    
    private func isNSDictionary(_ args:Any?) -> Bool {
        return args is NSDictionary
    }
    private func isNSArray(_ args:Any?) -> Bool {
        return args is NSArray
    }
    
    private func isBool(_ args:Any?) -> Bool {
        return args is Bool
    }
}

extension FlutterGoogleStreetView: GMSPanoramaViewDelegate, UIGestureRecognizerDelegate{
    
    func panoramaView(_ view: GMSPanoramaView, willMoveToPanoramaID panoramaID: String) {
        //debug("willMoveToPanoramaID:\(panoramaID)")
    }
    
    func panoramaView(_ view: GMSPanoramaView, error: Error) {
        let panorama = view.panorama
        if(panorama != nil) {
            onStreetViewPanoramaChange(panorama: panorama!)
        }
        //debug("panoramaView1")
    }
    
    func panoramaView(_ view: GMSPanoramaView, didMoveTo panorama: GMSPanorama, nearCoordinate coordinate: CLLocationCoordinate2D) {
        if(streetViewInit) {onStreetViewPanoramaChange(panorama: panorama)}
        //debug("panoramaView")
    }
    
    func panoramaView(_ view: GMSPanoramaView, didMoveTo panorama: GMSPanorama?) {
        if(streetViewInit) {onStreetViewPanoramaChange(panorama: panorama)}
        //debug("panoramaView3")
    }
    
    func panoramaView(_ view: GMSPanoramaView, error: Error, onMoveToPanoramaID panoramaID: String) {
        let panorama = view.panorama
        onStreetViewPanoramaChange(panorama: panorama, error: error)
        //debug("panoramaView4")
    }
    
    func panoramaView(_ view: GMSPanoramaView, error: Error, onMoveNearCoordinate coordinate: CLLocationCoordinate2D) {
        let panorama = view.panorama
        onStreetViewPanoramaChange(panorama: panorama, error: error)
        //debug("panoramaView5")
    }
    
    func panoramaView(_ panoramaView: GMSPanoramaView, didMove camera: GMSPanoramaCamera) {
        //debug("didMoveCamera, \(self.toS(camera))")
        onStreetViewPanoramaCameraChange(camera)
    }
    
    func panoramaView(_ panoramaView: GMSPanoramaView, didTap point: CGPoint) {
        //debug("didTap:\(self.toS(point))")
        onStreetViewPanoramaClick(point)
    }
    
    func panoramaView(_ panoramaView: GMSPanoramaView, didTap marker: GMSMarker) -> Bool {
        //debug("didTapmMarker:\(marker)")
        let markerId = "\((marker.userData as! NSArray)[0])"
        return _markersController.onMarkerTap(markerId)
    }
    
    func onStreetViewPanoramaChange(panorama :GMSPanorama?, error: Error? = nil) {
        var errorMsg :String?
        if(error != nil) {
            if(lastMoveToPos != nil) {
                errorMsg = "Oops..., no valid panorama found with position:\(Float(lastMoveToPos!.latitude)), \(Float(lastMoveToPos!.longitude)), try to change `position`, `radius` or `source`."
            } else if(lastMoveToPanoId != nil){
                errorMsg = "Oops..., no valid panorama found with panoId:\(lastMoveToPanoId!), try to change `panoId`."
            }
        }
        let args = streetViewPanoramaLocationToJson(panorama, errorMsg)
        //        args.forEach { (key: Any, value: Any) in
        //            debug("onStreetViewPanoramaCameraChange, key:\(key), value:\(value)")
        //        }
        
        if(!streetViewInit) {
            streetViewInit = true;
            if(initResult != nil) {
                streetViewIsReady(initResult!)
                initResult = nil
            }
        }
        methodChannel.invokeMethod("pano#onChange", arguments: args)
        
        lastMoveToPos = nil
        lastMoveToPanoId = nil
    }
    
    func onStreetViewPanoramaCameraChange(_ camera: GMSPanoramaCamera) {
        //debug("onStreetViewPanoramaChange, bearing:\(camera.orientation.heading), tilt:\(camera.orientation.pitch), zoom:\(camera.zoom), fov:\(camera.fov)")
        methodChannel.invokeMethod("camera#onChange", arguments: streetViewPanoramaCameraToJson(camera))
    }
    
    func onStreetViewPanoramaClick(_  point: CGPoint) {
        //debug("onStreetViewPanoramaClick, point:\(toS(point))")
        let orientationArg = orientationToJson(streetViewPanorama.orientation(for: point))
        let pointArg = pointToJson(point)
        let args : NSMutableDictionary = [:]
        orientationArg.forEach { (key: Any, value: Any) in
            args[key] = value
        }
        pointArg.forEach { (key: Any, value: Any) in
            args[key] = value
        }
        methodChannel.invokeMethod("pano#onClick", arguments: args)
    }
    
    @objc func onStreetViewPanoramaLongClick(_  recognizer:UITapGestureRecognizer) {
        if (recognizer.state == .began) {
            let point = recognizer.location(in:streetViewPanorama)
            //debug("onStreetViewPanoramaClick, point:\(toS(point))")
            let orientationArg = orientationToJson(streetViewPanorama.orientation(for: point))
            let pointArg = pointToJson(point)
            
            let args : NSMutableDictionary = [:]
            orientationArg.forEach { (key: Any, value: Any) in
                args[key] = value
            }
            pointArg.forEach { (key: Any, value: Any) in
                args[key] = value
            }
            methodChannel.invokeMethod("pano#onLongClick", arguments: args)
        }
    }
    
    //    func panoramaViewDidStartRendering(_ panoramaView: GMSPanoramaView) {
    //        debug("panoramaViewDidStartRendering, streetViewInit:\(streetViewInit)");
    //    }
    
    func panoramaViewDidFinishRendering(_ panoramaView: GMSPanoramaView) {
        debug("panoramaViewDidFinishRendering, streetViewInit:\(streetViewInit)");
        if(!streetViewInit) {
            streetViewInit = true;
            if(initResult != nil) {
                streetViewIsReady(initResult!)
                initResult = nil
            }
        }
    }
}
