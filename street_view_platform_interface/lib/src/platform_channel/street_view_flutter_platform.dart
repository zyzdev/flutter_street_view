import 'dart:async';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:street_view_platform_interface/src/method_channel/method_channel_street_view_flutter.dart';
import 'package:street_view_platform_interface/src/type/latLng.dart';
import 'package:street_view_platform_interface/street_view_platform_interface.dart';

abstract class StreetViewFlutterPlatform extends PlatformInterface {
  StreetViewFlutterPlatform() : super(token: _token);

  static StreetViewFlutterPlatform _instance = MethodChannelStreetViewFlutter();

  static final Object _token = Object();

  static StreetViewFlutterPlatform get instance => _instance;

  /// The created count of native street view.
  int get nativeStreetViewCreatedCount;

  /// Platform-specific plugins should set this with their own platform-specific
  /// class that extends [UrlLauncherPlatform] when they register themselves.
  static set instance(StreetViewFlutterPlatform instance) {
    PlatformInterface.verify(instance, _token);
    _instance = instance;
  }

  /// Initializes the platform interface with [id].
  ///
  /// This method is called when the plugin is first initialized.
  Future<dynamic> init(int viewId) {
    throw UnimplementedError('init() has not been implemented.');
  }

  /// Animate camera to a given position over a specified duration.
  ///
  /// Return [Future] while the change has been started on the platform side.
  Future<void> animateTo(int viewId,
      {StreetViewPanoramaCamera? camera, int? duration}) {
    throw UnimplementedError('animateTo() has not been implemented.');
  }

  /// Return position of current panorama and information of near panoramas
  Future<StreetViewPanoramaLocation?> getLocation(int viewId) {
    throw UnimplementedError('getLocation() has not been implemented.');
  }

  /// Return camera setting, bearing, tilt and zoom.
  Future<StreetViewPanoramaCamera> getPanoramaCamera(int viewId) {
    throw UnimplementedError('getPanoramaCamera() has not been implemented.');
  }

  /// Returns a screen location that corresponds to an orientation[StreetViewPanoramaOrientation].
  Future<Point> orientationToPoint(int viewId,
      {required StreetViewPanoramaOrientation orientation}) {
    throw UnimplementedError('orientationToPoint() has not been implemented.');
  }

  /// Return the orientation[StreetViewPanoramaOrientation] that corresponds to a screen location.
  Future<StreetViewPanoramaOrientation> pointToOrientation(int viewId,
      {Point? point}) {
    throw UnimplementedError('pointToOrientation() has not been implemented.');
  }

  /// Sets panorama by given location
  ///
  /// Return [Future] while the change has been made on the platform side.
  Future<void> setPosition(int viewId,
      {LatLng? position,
      String? panoId,
      int? radius,
      StreetViewSource? source}) {
    throw UnimplementedError('setPosition() has not been implemented.');
  }

  /// Sets street view to allow using panning gesture or not.
  ///
  /// Return [Future] while the change has been made on the platform side.
  Future<void> setPanningGesturesEnabled(int viewId, bool enable) {
    throw UnimplementedError(
        'setPanningGesturesEnabled() has not been implemented.');
  }

  /// Sets street view to display street name or not.
  ///
  /// Return [Future] while the change has been made on the platform side.
  Future<void> setStreetNamesEnabled(int viewId, bool enable) {
    throw UnimplementedError(
        'setStreetNamesEnabled() has not been implemented.');
  }

  /// Sets street view to allow moving to another panorama.
  ///
  /// Return [Future] while the change has been made on the platform side.
  Future<void> setUserNavigationEnabled(int viewId, bool enable) {
    throw UnimplementedError(
        'setUserNavigationEnabled() has not been implemented.');
  }

  /// Sets street view to allow using zoom gestures or not.
  ///
  /// Return [Future] while the change has been made on the platform side.
  Future<void> setZoomGesturesEnabled(int viewId, bool enable) {
    throw UnimplementedError(
        'setZoomGesturesEnabled() has not been implemented.');
  }

  /// Sets street view to allow using address control or not. `Web only`
  ///
  /// Return [Future] while the change has been made on the platform side.
  Future<void> setAddressControl(int viewId, bool enable) {
    throw UnimplementedError('setAddressControl() has not been implemented.');
  }

  /// Sets address control display position. `Web only`
  ///
  /// Return [Future] while the change has been made on the platform side.
  Future<void> setAddressControlOptions(int viewId, ControlPosition pos) {
    throw UnimplementedError(
        'setAddressControlOptions() has not been implemented.');
  }

  /// Sets street view to allow using all default UI or not. `Web only`
  ///
  /// Return [Future] while the change has been made on the platform side.
  Future<void> setDisableDefaultUI(int viewId, bool enable) {
    throw UnimplementedError('setDisableDefaultUI() has not been implemented.');
  }

  /// Sets street view to allow using zoom on double click or not. `Web only`
  ///
  /// Return [Future] while the change has been made on the platform side.
  Future<void> setDisableDoubleClickZoom(int viewId, bool enable) {
    throw UnimplementedError(
        'setDisableDoubleClickZoom() has not been implemented.');
  }

  /// Sets street view to allow using close button or not. `Web only`
  ///
  /// Return [Future] while the change has been made on the platform side.
  Future<void> setEnableCloseButton(int viewId, bool enable) {
    throw UnimplementedError(
        'setEnableCloseButton() has not been implemented.');
  }

  /// Sets street view to allow using fullscreen control or not. `Web only`
  ///
  /// Return [Future] while the change has been made on the platform side.
  Future<void> setFullscreenControl(int viewId, bool enable) {
    throw UnimplementedError(
        'setFullscreenControl() has not been implemented.');
  }

  /// Sets fullscreen control display position. `Web only`
  ///
  /// Return [Future] while the change has been made on the platform side.
  Future<void> setFullscreenControlOptions(int viewId, ControlPosition pos) {
    throw UnimplementedError(
        'setFullControlOptions() has not been implemented.');
  }

  /// Sets street view to allow using link control or not. `Web only`
  ///
  /// Return [Future] while the change has been made on the platform side.
  Future<void> setLinksControl(int viewId, bool enable) {
    throw UnimplementedError('setLinksControl() has not been implemented.');
  }

  /// Sets street view to allow using motion tracking or not. `Web only`
  ///
  /// Return [Future] while the change has been made on the platform side.
  Future<void> setMotionTracking(int viewId, bool enable) {
    throw UnimplementedError('setMotionTracking() has not been implemented.');
  }

  /// Sets street view to allow using motion tracking control or not. `Web only`
  ///
  /// Return [Future] while the change has been made on the platform side.
  Future<void> setMotionTrackingControl(int viewId, bool enable) {
    throw UnimplementedError(
        'setMotionTrackingControl() has not been implemented.');
  }

  /// Sets motion tracking control display position. `Web only`
  ///
  /// Return [Future] while the change has been made on the platform side.
  Future<void> setMotionTrackingControlOptions(
      int viewId, ControlPosition pos) {
    throw UnimplementedError(
        'setMotionTrackingControlOptions() has not been implemented.');
  }

  /// Sets street view to allow using pan control or not. `Web only`
  ///
  /// Return [Future] while the change has been made on the platform side.
  Future<void> setPanControl(int viewId, bool enable) {
    throw UnimplementedError('setPanControl() has not been implemented.');
  }

  /// Sets pan control display position. `Web only`
  ///
  /// Return [Future] while the change has been made on the platform side.
  Future<void> setPanControlOptions(int viewId, ControlPosition pos) {
    throw UnimplementedError(
        'setPanControlOptions() has not been implemented.');
  }

  /// Sets street view to allow using scrollwheel zooming or not. `Web only`
  ///
  /// Return [Future] while the change has been made on the platform side.
  Future<void> setScrollwheel(int viewId, bool enable) {
    throw UnimplementedError('setScrollwheel() has not been implemented.');
  }

  /// Sets street view to allow using zoom control or not. `Web only`
  ///
  /// Return [Future] while the change has been made on the platform side.
  Future<void> setZoomControl(int viewId, bool enable) {
    throw UnimplementedError('setZoomControl() has not been implemented.');
  }

  /// Sets zoom control display position. `Web only`
  ///
  /// Return [Future] while the change has been made on the platform side.
  Future<void> setZoomControlOptions(int viewId, ControlPosition pos) {
    throw UnimplementedError(
        'setZoomControlOptions() has not been implemented.');
  }

  /// Sets street view is visible. `Web only`
  ///
  /// Return [Future] while the change has been made on the platform side.
  Future<void> setVisible(int viewId, bool enable) {
    throw UnimplementedError('setVisible() has not been implemented.');
  }

  /// FlutterGoogleStreetView is deactivated
  void deactivate(int viewId) {
    throw UnimplementedError('deactivate() has not been implemented.');
  }

  /// Dispose of whatever resources the `viewId` is holding on to.
  void dispose(int viewId) {
    throw UnimplementedError('dispose() has not been implemented.');
  }

  /// The Camera change.
  Stream<CameraChangeEvent> onCameraChange({required int viewId}) {
    throw UnimplementedError(
        'onCameraChangeListener() has not been implemented.');
  }

  /// The Panorama change.
  Stream<PanoramaChangeEvent> onPanoramaChange({required int viewId}) {
    throw UnimplementedError(
        'onPanoramaChangeListener() has not been implemented.');
  }

  /// The Panorama was clicked.
  Stream<PanoramaClickEvent> onPanoramaClick({required int viewId}) {
    throw UnimplementedError('onPanoramaClick() has not been implemented.');
  }

  /// The Panorama was long clicked.
  Stream<PanoramaLongClickEvent> onPanoramaLongClick({required int viewId}) {
    throw UnimplementedError('onPanoramaLongClick() has not been implemented.');
  }

  /// The Close was clicked. `Web only`
  Stream<CloseClickEvent> onCloseClick({required int viewId}) {
    throw UnimplementedError('onCloseClick() has not been implemented.');
  }

  /// A [Marker] has been tapped.
  Stream<MarkerTapEvent> onMarkerTap({required int viewId}) {
    throw UnimplementedError('onMarkerTap() has not been implemented.');
  }

  /// Updates configuration options of the street view user interface.
  ///
  /// Change listeners are notified once the update has been made on the
  /// platform side.
  ///
  /// The returned [Future] completes after listeners have been notified.
  Future<dynamic> updateStreetViewOptions(
    Map<String, dynamic> optionsUpdate, {
    required int viewId,
  }) {
    throw UnimplementedError(
        'updateStreetViewOptions() has not been implemented.');
  }

  /// Updates marker configuration.
  ///
  /// Change listeners are notified once the update has been made on the
  /// platform side.
  ///
  /// The returned [Future] completes after listeners have been notified.
  Future<void> updateMarkers(
    MarkerUpdates markerUpdates, {
    required int viewId,
  }) {
    throw UnimplementedError('updateMarkers() has not been implemented.');
  }

  /// Returns a widget displaying the street view
  Widget buildView(
      Map<String, dynamic> creationParams,
      Set<Factory<OneSequenceGestureRecognizer>>? gestureRecognizers,
      PlatformViewCreatedCallback onPlatformViewCreated,
      {int? viewId}) {
    throw UnimplementedError('buildView() has not been implemented.');
  }
}
