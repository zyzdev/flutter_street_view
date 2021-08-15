//
//  Convert.swift
//  Runner
//
//  Created by 小朱的Mac Mini on 2021/8/10.
//

import GoogleMaps

func toLocation(_ pos:Any?) -> CLLocationCoordinate2D? {
    var tmp:CLLocationCoordinate2D? = nil
    if(pos is NSArray) {
        let pos_ = pos as! [Double]
        tmp = CLLocationCoordinate2D(latitude: pos_[0], longitude: pos_[1])
    }
    return tmp
}

func toSource(_ source:Any?) -> GMSPanoramaSource? {
    var tmp:GMSPanoramaSource? = nil
    if(source is String) {
        let source_ = source as! String
        if(source_ == "outdoor") {
            tmp = GMSPanoramaSource.outside
        }
    }
    return tmp
}

func toFloat(_ o: Any) -> Float? {
    return o is Float ? (o as! Float) : nil
}

func toDouble(_ o: Any) -> Double? {
    return o is Double ? (o as! Double) : nil
}

func toCLLocationDirection(_ o: Any) -> CLLocationDirection? {
    return o is CLLocationDirection ? (o as! CLLocationDirection) : nil
}

func streetViewPanoramaLocationToJson(_ panorama:GMSPanorama?,_ error:String? = nil) -> NSMutableDictionary{
    let dictionary: NSMutableDictionary = [:]
    if(panorama != nil) {
        var links :[NSArray] = []
        panorama!.links.forEach { link in
            links.append(_GMSPanoramaLinkToJson(link))
        }
        dictionary["links"] = links
        dictionary["panoId"] = panorama!.panoramaID
        dictionary["position"] = latLngToJson(panorama!.coordinate)
    }
    if(error != nil) {dictionary["error"] = error}
    //return["links" : links, "panoId" : arg.panoramaID,"position": latLngToJson(arg.coordinate)]
    return dictionary
}

func streetViewPanoramaCameraToJson(_ camera:GMSPanoramaCamera) -> NSDictionary {
    let bearing = camera.orientation.heading
    let tilt = camera.orientation.pitch
    let zoom = camera.zoom
    let fov = camera.fov
    return ["bearing": bearing, "tilt" : tilt, "zoom":zoom, "fov":fov]
}

func _GMSPanoramaLinkToJson(_ link:GMSPanoramaLink ) -> NSArray {
    return [link.panoramaID, link.heading]
}

private func latLngToJson(_ latLng: CLLocationCoordinate2D) -> NSArray {
    return [latLng.latitude, latLng.longitude]
}

func pointToJson(_ point:CGPoint) -> NSDictionary {
    return ["x" : Int(point.x), "y":Int(point.y)]
}

func orientationToJson(_ orientation: GMSOrientation) -> NSDictionary{
    return ["bearing": orientation.heading, "tilt" : orientation.pitch]
}
