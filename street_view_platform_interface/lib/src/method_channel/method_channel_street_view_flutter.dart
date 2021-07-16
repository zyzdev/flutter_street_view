import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';
import 'package:stream_transform/stream_transform.dart';
import 'package:street_view_platform_interface/src/events/street_view_event.dart';
import 'package:street_view_platform_interface/src/platform_channel/street_view_flutter_platform.dart';
import 'package:street_view_platform_interface/src/type/camera.dart';
import 'package:street_view_platform_interface/street_view_platform_interface.dart';

class MethodChannelStreetViewFlutter extends StreetViewFlutterPlatform {
  final Map<int, MethodChannel?> _channels = {};

  /// Accesses the MethodChannel associated to the passed viewId.
  MethodChannel? channel(int viewId) {
    return _channels[viewId];
  }

  /// Initializes the platform interface with [id].
  ///
  /// This method is called when the plugin is first initialized.
  @override
  Future<dynamic> init(int viewId) {
    MethodChannel? channel;
    if (!_channels.containsKey(viewId)) {
      channel = MethodChannel('flutter_google_street_view_$viewId');
      channel.setMethodCallHandler(
          (MethodCall call) => _handleMethodCall(call, viewId));
      _channels[viewId] = channel;
    }
    return channel!.invokeMethod<void>('streetView#waitForStreetView');
  }

  // The controller we need to broadcast the different events coming
  // from handleMethodCall.
  //
  // It is a `broadcast` because multiple controllers will connect to
  // different stream views of this Controller.
  final StreamController<StreetViewEvent> _streetViewEventStreamController =
      StreamController<StreetViewEvent>.broadcast();

  // Returns a filtered view of the events in the _controller, by mapId.
  Stream<StreetViewEvent> _events(int viewId) =>
      _streetViewEventStreamController.stream
          .where((event) => event.viewId == viewId);

  /// Dispose of the native resources.
  @override
  void dispose({int? viewId}) {
    // Noop!
    _streetViewEventStreamController.close();
  }

  /// Animate camera to a given position[StreetViewPanoramaCamera] over a specified duration.
  ///
  /// Return [Future] while the change has been started on the platform side.
  @override
  Future<void> animateTo(int viewId,
      {StreetViewPanoramaCamera? camera, int? duration}) {
    return channel(viewId)!.invokeMethod("streetView#animateTo",
        camera!.toMap()..putIfAbsent("duration", () => duration!.toDouble()));
  }

  /// Return position of current panorama and information of near panoramas
  @override
  Future<StreetViewPanoramaLocation> getLocation(int viewId) async {
    return StreetViewPanoramaLocation.fromMap(
        await channel(viewId)!.invokeMethod("streetView#getLocation"));
  }

  /// Return camera setting, bearing, tilt and zoom.
  @override
  Future<StreetViewPanoramaCamera> getPanoramaCamera(int viewId) async {
    return StreetViewPanoramaCamera.fromMap(
        await channel(viewId)!.invokeMethod("streetView#getPanoramaCamera"));
  }

/*  Future<bool> isPanningGesturesEnabled(int viewId) {
    return channel(viewId).invokeMethod("streetView#isPanningGesturesEnabled");
  }

  Future<bool> isStreetNamesEnabled(int viewId) {
    return channel(viewId).invokeMethod("streetView#isStreetNamesEnabled");
  }

  Future<bool> isUserNavigationEnabled(int viewId) {
    return channel(viewId).invokeMethod("streetView#isUserNavigationEnabled");
  }

  Future<bool> isZoomGesturesEnabled(int viewId) {
    return channel(viewId).invokeMethod("streetView#isZoomGesturesEnabled");
  }*/

  /// Returns a screen location that corresponds to an orientation[StreetViewPanoramaOrientation].
  @override
  Future<Point> orientationToPoint(int viewId,
      {StreetViewPanoramaOrientation? orientation}) async {
    final point = await channel(viewId)!
        .invokeMethod("streetView#orientationToPoint", orientation!.toMap());
    return Point(point["x"], point["y"]);
  }

  /// Return the orientation[StreetViewPanoramaOrientation] that corresponds to a screen location.
  @override
  Future<StreetViewPanoramaOrientation> pointToOrientation(int viewId,
      {Point? point}) async {
    return StreetViewPanoramaOrientation.fromMap(await channel(viewId)!
        .invokeMethod("streetView#pointToOrientation", [point!.x, point.y]));
  }

  /// Sets panorama by given location
  ///
  /// Return [Future] while the change has been made on the platform side.
  @override
  Future<void> setPosition(int viewId,
      {LatLng? position,
      String? panoId,
      int? radius,
      StreetViewSource? source}) {
    return channel(viewId)!.invokeMethod(
        "streetView#movePos",
        StreetViewCameraPosition(
                position: position,
                panoId: panoId,
                radius: radius,
                source: source)
            .toMap());
  }

  /// Sets street view to allow using panning gesture or not.
  ///
  /// Return [Future] while the change has been made on the platform side.
  @override
  Future<void> setPanningGesturesEnabled(int viewId, {bool? enable}) {
    assert(enable != null);
    return channel(viewId)!
        .invokeListMethod("streetView#setPanningGesturesEnabled", enable);
  }

  /// Sets street view to display street name or not.
  ///
  /// Return [Future] while the change has been made on the platform side.
  @override
  Future<void> setStreetNamesEnabled(int viewId, {bool? enable}) {
    assert(enable != null);
    return channel(viewId)!
        .invokeListMethod("streetView#setStreetNamesEnabled", enable);
  }

  /// Sets street view to allow moving to another panorama.
  ///
  /// Return [Future] while the change has been made on the platform side.
  @override
  Future<void> setUserNavigationEnabled(int viewId, {bool? enable}) {
    assert(enable != null);
    return channel(viewId)!
        .invokeListMethod("streetView#setUserNavigationEnabled", enable);
  }

  /// Sets street view to allow using zoom gestures or not.
  ///
  /// Return [Future] while the change has been made on the platform side.
  @override
  Future<void> setZoomGesturesEnabled(int viewId, {bool? enable}) {
    assert(enable != null);
    return channel(viewId)!
        .invokeListMethod("streetView#setZoomGesturesEnabled", enable);
  }

  /// The Camera was changed.
  @override
  Stream<CameraChangeEvent> onCameraChange({required int viewId}) {
    return _events(viewId).whereType<CameraChangeEvent>();
  }

  /// The Panorama was changed.
  @override
  Stream<PanoramaChangeEvent> onPanoramaChange({required int viewId}) {
    return _events(viewId).whereType<PanoramaChangeEvent>();
  }

  /// The Panorama was clicked.
  @override
  Stream<PanoramaClickEvent> onPanoramaClick({required int viewId}) {
    return _events(viewId).whereType<PanoramaClickEvent>();
  }

  /// The Panorama was long clicked.
  @override
  Stream<PanoramaLongClickEvent> onPanoramaLongClick({required int viewId}) {
    return _events(viewId).whereType<PanoramaLongClickEvent>();
  }

  /// Updates configuration options of the street view user interface.
  ///
  /// Change listeners are notified once the update has been made on the
  /// platform side.
  ///
  /// The returned [Future] completes after listeners have been notified.
  @override
  Future<dynamic> updateStreetViewOptions(
    Map<String, dynamic> optionsUpdate, {
    required int viewId,
  }) {
    return channel(viewId)!
        .invokeMethod("streetView#updateOptions", optionsUpdate);
  }

  Future<dynamic> _handleMethodCall(MethodCall call, int viewId) async {
    switch (call.method) {
      case 'camera#onChange':
        //print("camera#onChange:${call.arguments}");
        _streetViewEventStreamController.add(CameraChangeEvent(
            viewId, StreetViewPanoramaCamera.fromMap(call.arguments)));
        break;
      case 'pano#onChange':
        //print("pano#onChange:${call.arguments}");
        _streetViewEventStreamController.add(PanoramaChangeEvent(
            viewId, StreetViewPanoramaLocation.fromMap(call.arguments)));
        break;
      case 'pano#onClick':
        //print("pano#onClick:${call.arguments}");
        _streetViewEventStreamController.add(PanoramaClickEvent(
            viewId, StreetViewPanoramaOrientation.fromMap(call.arguments)));
        break;
      case 'pano#onLongClick':
        //print("pano#onLongClick:${call.arguments}");
        _streetViewEventStreamController.add(PanoramaLongClickEvent(
            viewId, StreetViewPanoramaOrientation.fromMap(call.arguments)));
        break;
      default:
        throw MissingPluginException();
    }
  }

  /// This method builds the appropriate platform view where the street view
  /// can be rendered.
  /// The `viewId` is passed as a parameter from the framework on the
  /// `onPlatformViewCreated` callback.
  @override
  Widget buildView(
      Map<String, dynamic> creationParams,
      Set<Factory<OneSequenceGestureRecognizer>> gestureRecognizers,
      PlatformViewCreatedCallback onPlatformViewCreated) {
    // This is used in the platform side to register the view.
    final String viewType = 'my_street_view';
    if (defaultTargetPlatform == TargetPlatform.android) {
      return AndroidView(
          viewType: viewType,
          onPlatformViewCreated: onPlatformViewCreated,
          creationParams: creationParams,
          gestureRecognizers: gestureRecognizers,
          creationParamsCodec: const StandardMessageCodec());
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      return UiKitView(
          viewType: viewType,
          onPlatformViewCreated: onPlatformViewCreated,
          creationParams: creationParams,
          gestureRecognizers: gestureRecognizers,
          creationParamsCodec: const StandardMessageCodec());
    }
    return Text(
        '$defaultTargetPlatform is not yet supported by the maps plugin');
  }
}
