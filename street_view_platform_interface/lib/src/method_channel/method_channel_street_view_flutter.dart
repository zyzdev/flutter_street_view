import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:stream_transform/stream_transform.dart';
import 'package:street_view_platform_interface/street_view_platform_interface.dart';

class MethodChannelStreetViewFlutter extends StreetViewFlutterPlatform {
  final Map<int, MethodChannel?> _channels = {};

  int _nativeStreetViewCreatedCount = 0;

  /// Accesses the MethodChannel associated to the passed viewId.
  MethodChannel? channel(int viewId) {
    return _channels[viewId];
  }

  /// Initializes the platform interface with [id].
  ///
  /// This method is called when the plugin is first initialized.
  @override
  Future<dynamic> init(int viewId) async {
    MethodChannel? channel;
    if (!_channels.containsKey(viewId)) {
      channel = MethodChannel('flutter_google_street_view_$viewId');
      channel.setMethodCallHandler(
          (MethodCall call) => _handleMethodCall(call, viewId));
      _channels[viewId] = channel;
    } else
      channel = _channels[viewId];
    final data = await channel!.invokeMethod('streetView#waitForStreetView');
    if (data.containsKey('streetViewCount')) {
      _nativeStreetViewCreatedCount = data['streetViewCount'];
    }
    return data;
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

  /// FlutterGoogleStreetView is deactivated
  void deactivate(int viewId) {
    _channels[viewId]?.invokeMethod<void>('streetView#deactivate');
  }

  /// Dispose of the native resources.
  @override
  void dispose(int viewId) {
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
  Future<StreetViewPanoramaLocation?> getLocation(int viewId) async {
    final tmp = StreetViewPanoramaLocation.fromMap(
        await channel(viewId)!.invokeMethod("streetView#getLocation"));
    return tmp.isNull() ? null : tmp;
  }

  /// Return camera setting, bearing, tilt and zoom.
  @override
  Future<StreetViewPanoramaCamera> getPanoramaCamera(int viewId) async {
    return StreetViewPanoramaCamera.fromMap(
        await channel(viewId)!.invokeMethod("streetView#getPanoramaCamera"));
  }

  /// Returns a screen location that corresponds to an orientation[StreetViewPanoramaOrientation].
  @override
  Future<Point> orientationToPoint(int viewId,
      {required StreetViewPanoramaOrientation orientation}) async {
    final point = await channel(viewId)!
        .invokeMethod("streetView#orientationToPoint", orientation.toMap());
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
  Future<void> setPanningGesturesEnabled(int viewId, bool enable) {
    return channel(viewId)!
        .invokeMethod("streetView#setPanningGesturesEnabled", enable);
  }

  /// Sets street view to display street name or not.
  ///
  /// Return [Future] while the change has been made on the platform side.
  @override
  Future<void> setStreetNamesEnabled(int viewId, bool enable) {
    return channel(viewId)!
        .invokeMethod("streetView#setStreetNamesEnabled", enable);
  }

  /// Sets street view to allow moving to another panorama.
  ///
  /// Return [Future] while the change has been made on the platform side.
  @override
  Future<void> setUserNavigationEnabled(int viewId, bool enable) {
    return channel(viewId)!
        .invokeMethod("streetView#setUserNavigationEnabled", enable);
  }

  /// Sets street view to allow using zoom gestures or not.
  ///
  /// Return [Future] while the change has been made on the platform side.
  @override
  Future<void> setZoomGesturesEnabled(int viewId, bool enable) {
    return channel(viewId)!
        .invokeMethod("streetView#setZoomGesturesEnabled", enable);
  }

  /// Sets street view to allow using address control or not. `Web only`
  ///
  /// Return [Future] while the change has been made on the platform side.
  Future<void> setAddressControl(int viewId, bool enable) {
    return channel(viewId)!
        .invokeMethod("streetView#setAddressControl", enable);
  }

  /// Sets address control display position. `Web only`
  ///
  /// Return [Future] while the change has been made on the platform side.
  Future<void> setAddressControlOptions(int viewId, ControlPosition pos) {
    return channel(viewId)!
        .invokeMethod("streetView#setAddressControlOptions", pos.toJson());
  }

  /// Sets street view to allow using all default UI or not. `Web only`
  ///
  /// Return [Future] while the change has been made on the platform side.
  Future<void> setDisableDefaultUI(int viewId, bool enable) {
    return channel(viewId)!
        .invokeMethod("streetView#setDisableDefaultUI", enable);
  }

  /// Sets street view to allow using zoom on double click or not. `Web only`
  ///
  /// Return [Future] while the change has been made on the platform side.
  Future<void> setDisableDoubleClickZoom(int viewId, bool enable) {
    return channel(viewId)!
        .invokeMethod("streetView#setDisableDoubleClickZoom", enable);
  }

  /// Sets street view to allow using close button or not. `Web only`
  ///
  /// Return [Future] while the change has been made on the platform side.
  Future<void> setEnableCloseButton(int viewId, bool enable) {
    return channel(viewId)!
        .invokeMethod("streetView#setEnableCloseButton", enable);
  }

  /// Sets street view to allow using fullscreen control or not. `Web only`
  ///
  /// Return [Future] while the change has been made on the platform side.
  Future<void> setFullscreenControl(int viewId, bool enable) {
    return channel(viewId)!
        .invokeMethod("streetView#setFullscreenControl", enable);
  }

  /// Sets fullscreen control display position. `Web only`
  ///
  /// Return [Future] while the change has been made on the platform side.
  Future<void> setFullscreenControlOptions(int viewId, ControlPosition pos) {
    return channel(viewId)!
        .invokeMethod("streetView#setFullscreenControlOptions", pos.toJson());
  }

  /// Sets street view to allow using link control or not. `Web only`
  ///
  /// Return [Future] while the change has been made on the platform side.
  Future<void> setLinksControl(int viewId, bool enable) {
    return channel(viewId)!.invokeMethod("streetView#setLinksControl", enable);
  }

  /// Sets street view to allow using motion tracking or not. `Web only`
  ///
  /// Return [Future] while the change has been made on the platform side.
  Future<void> setMotionTracking(int viewId, bool enable) {
    return channel(viewId)!
        .invokeMethod("streetView#setMotionTracking", enable);
  }

  /// Sets street view to allow using motion tracking control or not. `Web only`
  ///
  /// Return [Future] while the change has been made on the platform side.
  Future<void> setMotionTrackingControl(int viewId, bool enable) {
    return channel(viewId)!
        .invokeMethod("streetView#setMotionTrackingControl", enable);
  }

  /// Sets motion tracking control display position. `Web only`
  ///
  /// Return [Future] while the change has been made on the platform side.
  Future<void> setMotionTrackingControlOptions(
      int viewId, ControlPosition pos) {
    return channel(viewId)!.invokeMethod(
        "streetView#setMotionTrackingControlOptions", pos.toJson());
  }

  /// Sets street view to allow using pan control or not. `Web only`
  ///
  /// Return [Future] while the change has been made on the platform side.
  Future<void> setPanControl(int viewId, bool enable) {
    return channel(viewId)!.invokeMethod("streetView#setPanControl", enable);
  }

  /// Sets pan control display position. `Web only`
  ///
  /// Return [Future] while the change has been made on the platform side.
  Future<void> setPanControlOptions(int viewId, ControlPosition pos) {
    return channel(viewId)!
        .invokeMethod("streetView#setPanControlOptions", pos.toJson());
  }

  /// Sets street view to allow using scrollwheel zooming or not. `Web only`
  ///
  /// Return [Future] while the change has been made on the platform side.
  Future<void> setScrollwheel(int viewId, bool enable) {
    return channel(viewId)!.invokeMethod("streetView#setScrollwheel", enable);
  }

  /// Sets street view to allow using zoom control or not. `Web only`
  ///
  /// Return [Future] while the change has been made on the platform side.
  Future<void> setZoomControl(int viewId, bool enable) {
    return channel(viewId)!.invokeMethod("streetView#setZoomControl", enable);
  }

  /// Sets zoom control display position. `Web only`
  ///
  /// Return [Future] while the change has been made on the platform side.
  Future<void> setZoomControlOptions(int viewId, ControlPosition pos) {
    return channel(viewId)!
        .invokeMethod("streetView#setZoomControlOptions", pos.toJson());
  }

  /// Sets street view is visible. `Web only`
  ///
  /// Return [Future] while the change has been made on the platform side.
  Future<void> setVisible(int viewId, bool enable) {
    return channel(viewId)!.invokeMethod("streetView#setVisible", enable);
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

  /// The Close was clicked. `Web only`
  Stream<CloseClickEvent> onCloseClick({required int viewId}) {
    return _events(viewId).whereType<CloseClickEvent>();
  }

  /// A [Marker] has been tapped.
  Stream<MarkerTapEvent> onMarkerTap({required int viewId}) {
    return _events(viewId).whereType<MarkerTapEvent>();
  }

  @override
  Future<void> updateMarkers(
    MarkerUpdates markerUpdates, {
    required int viewId,
  }) {
    return channel(viewId)!.invokeMethod<void>(
      'markers#update',
      markerUpdates.toJson(),
    );
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
    //print("MethodChannelStreetViewFlutter, ${call.method}, viewId:$viewId");
    switch (call.method) {
      case 'log#onSend':
        print(call.arguments);
        break;
      case 'camera#onChange':
        //print("camera#onChange:${call.arguments}");
        _streetViewEventStreamController.add(CameraChangeEvent(
            viewId, StreetViewPanoramaCamera.fromMap(call.arguments)));
        break;
      case 'pano#onChange':
        //print("pano#onChange:${call.arguments}");
        String? errorMsg =
            call.arguments['error'] is String ? call.arguments['error'] : null;
        Exception? e = errorMsg != null ? Exception(errorMsg) : null;
        final data = PanoramaChangeData(
            e == null
                ? StreetViewPanoramaLocation.fromMap(call.arguments)
                : null,
            e);
        _streetViewEventStreamController.add(PanoramaChangeEvent(viewId, data));
        break;
      case 'pano#onClick':
        final map = call.arguments;
        final orientation = StreetViewPanoramaOrientation.fromMap(map);
        final point = Point(map['x'] as int, map['y'] as int);
/*        print(
            "pano#onClick:${call.arguments}, orientation:$orientation, point:$point");*/
        _streetViewEventStreamController.add(
            PanoramaClickEvent(viewId, PanoramaClickData(orientation, point)));
        break;
      case 'pano#onLongClick':
        final map = call.arguments;
        final orientation =
            StreetViewPanoramaOrientation.fromMap(call.arguments);
        final point = Point(map['x'] as int, map['y'] as int);
        /*print(
            "pano#onLongClick:${call.arguments}, orientation:$orientation, point:$point");*/
        _streetViewEventStreamController.add(PanoramaLongClickEvent(
            viewId, PanoramaClickData(orientation, point)));
        break;
      case 'close#onClick':
        //print("close#onClick:${call.arguments}");
        _streetViewEventStreamController.add(CloseClickEvent(viewId));
        break;
      case 'marker#onTap':
        _streetViewEventStreamController.add(MarkerTapEvent(
          viewId,
          MarkerId(call.arguments['markerId']),
        ));
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
      Set<Factory<OneSequenceGestureRecognizer>>? gestureRecognizers,
      PlatformViewCreatedCallback onPlatformViewCreated,
      {int? viewId}) {
    // This is used in the platform side to register the view.
    final String viewType = 'my_street_view';
    if (defaultTargetPlatform == TargetPlatform.android) {
      return PlatformViewLink(
          viewType: viewType,
          surfaceFactory:
              (BuildContext context, PlatformViewController controller) {
            return AndroidViewSurface(
              controller: controller as AndroidViewController,
              gestureRecognizers: gestureRecognizers ??
                  const <Factory<OneSequenceGestureRecognizer>>{},
              hitTestBehavior: PlatformViewHitTestBehavior.opaque,
            );
          },
          onCreatePlatformView: (PlatformViewCreationParams params) {
            return PlatformViewsService.initExpensiveAndroidView(
              id: params.id,
              viewType: viewType,
              layoutDirection: TextDirection.ltr,
              creationParams: creationParams,
              creationParamsCodec: const StandardMessageCodec(),
              onFocus: () {
                params.onFocusChanged(true);
              },
            )
              ..addOnPlatformViewCreatedListener(params.onPlatformViewCreated)
              ..addOnPlatformViewCreatedListener(onPlatformViewCreated)
              ..create();
          });
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

  /// The created count of native street view.
  @override
  int get nativeStreetViewCreatedCount => _nativeStreetViewCreatedCount;
}
