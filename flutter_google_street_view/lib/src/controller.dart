import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter_google_street_view/src/state/street_view_base_state.dart';
import 'package:street_view_platform_interface/street_view_platform_interface.dart';

/// Callback method for when the streetView is ready to be used.
///
/// Pass to [FlutterGoogleStreetView.onStreetViewCreated] to receive a [StreetViewController] when the
/// street view is created.
typedef void StreetViewCreatedCallback(StreetViewController controller);

StreetViewFlutterPlatform _streetViewFlutterPlatform =
    StreetViewFlutterPlatform.instance;

class StreetViewController {
  final int viewId;
  bool _isPanningGesturesEnabled = true;
  bool _isStreetNamesEnabled = true;
  bool _isUserNavigationEnabled = true;
  bool _isZoomGesturesEnabled = true;

  bool _isAddressControl = true;
  bool _isDisableDefaultUI = false;
  bool _isDisableDoubleClickZoom = false;
  bool _isEnableCloseButton = true;
  bool _isFullscreenControl = true;
  bool _isLinksControl = true;
  bool _isMotionTracking = true;
  bool _isMotionTrackingControl = true;
  bool _isScrollwheel = true;
  bool _isPanControl = true;
  bool _isZoomControl = true;
  bool _isVisible = true;

  final StreetViewBaseState _streetViewState;

  StreamSubscription? _onCameraChange;
  StreamSubscription? _onPanoramaChange;
  StreamSubscription? _onPanoramaClick;
  StreamSubscription? _onPanoramaLongClick;
  StreamSubscription? _onCloseClickListener;

  StreetViewController._(this._streetViewState,
      {required this.viewId, required dynamic initSetting}) {
    _connectStreams(viewId);
    if (initSetting['isPanningGesturesEnabled'] != null)
      _isPanningGesturesEnabled = initSetting['isPanningGesturesEnabled']!;
    if (initSetting['isStreetNamesEnabled'] != null)
      _isStreetNamesEnabled = initSetting['isStreetNamesEnabled']!;
    if (initSetting['isUserNavigationEnabled'] != null)
      _isUserNavigationEnabled = initSetting['isUserNavigationEnabled']!;
    if (initSetting['isZoomGesturesEnabled'] != null)
      _isZoomGesturesEnabled = initSetting['isZoomGesturesEnabled']!;

    if (initSetting['isAddressControl'] != null)
      _isAddressControl = initSetting['isAddressControl']!;
    if (initSetting['isDisableDefaultUI'] != null)
      _isDisableDefaultUI = initSetting['isDisableDefaultUI']!;
    if (initSetting['isDisableDoubleClickZoom'] != null)
      _isDisableDoubleClickZoom = initSetting['isDisableDoubleClickZoom']!;
    if (initSetting['isEnableCloseButton'] != null)
      _isEnableCloseButton = initSetting['isEnableCloseButton']!;
    if (initSetting['isFullscreenControl'] != null)
      _isFullscreenControl = initSetting['isFullscreenControl']!;
    if (initSetting['isLinksControl'] != null)
      _isLinksControl = initSetting['isLinksControl']!;
    if (initSetting['isMotionTracking'] != null)
      _isMotionTracking = initSetting['isMotionTracking']!;
    if (initSetting['isMotionTrackingControl'] != null)
      _isMotionTrackingControl = initSetting['isMotionTrackingControl']!;
    if (initSetting['isScrollwheel'] != null)
      _isScrollwheel = initSetting['isScrollwheel']!;
    if (initSetting['isPanControl'] != null)
      _isPanControl = initSetting['isPanControl']!;
    if (initSetting['isZoomControl'] != null)
      _isZoomControl = initSetting['isZoomControl']!;
    if (initSetting['isVisible'] != null)
      _isVisible = initSetting['isVisible']!;

    StreetViewFlutterPlatform.instance = _streetViewFlutterPlatform;
  }

  /// Initialize control of a [FlutterGoogleStreetView] with [id].
  ///
  /// Mainly for internal use when instantiating a [StreetViewController] passed
  /// in [FlutterGoogleStreetView.onStreetViewCreated] callback.
  static Future<StreetViewController> init(
      int id, StreetViewBaseState streetViewState) async {
    final dynamic initSetting = await _streetViewFlutterPlatform.init(id);
    return StreetViewController._(streetViewState,
        viewId: id, initSetting: initSetting);
  }

  /// Animate camera to a given position over a specified duration.
  ///
  /// [duration] unit is ms.
  ///
  /// Return [Future] while the change has been started on the platform side.
  Future<void> animateTo(
      {required StreetViewPanoramaCamera camera, required int duration}) {
    assert(duration > 0);
    return _streetViewFlutterPlatform.animateTo(viewId,
        camera: camera, duration: duration);
  }

  /// Return position of current panorama and information of near panoramas
  Future<StreetViewPanoramaLocation?> getLocation() {
    return _streetViewFlutterPlatform.getLocation(viewId);
  }

  /// Return camera setting, bearing, tilt and zoom.
  Future<StreetViewPanoramaCamera> getPanoramaCamera() async {
    return _streetViewFlutterPlatform.getPanoramaCamera(viewId);
  }

  /// Return street view is able to use panning gestures. `Web not support`, [setPanningGesturesEnabled] and [isPanningGesturesEnabled] always be true
  bool get isPanningGesturesEnabled => _isPanningGesturesEnabled;

  /// Return street view is displaying street name or not.
  bool get isStreetNamesEnabled => _isStreetNamesEnabled;

  /// Return street view is able user move to another panorama.
  bool get isUserNavigationEnabled => _isUserNavigationEnabled;

  /// Return street view is able to use zoom gestures.
  bool get isZoomGesturesEnabled => _isZoomGesturesEnabled;

  /// Return street view is able to use address control. `Web only`
  bool get isAddressControl => _isAddressControl;

  /// Return street view is able to use all default UI. `Web only`
  bool get isDisableDefaultUI => _isDisableDefaultUI;

  /// Return street view is able to zoom on double click. `Web only`
  bool get isDisableDoubleClickZoom => _isDisableDoubleClickZoom;

  /// Return street view is able to use close button. `Web only`
  bool get isEnableCloseButton => _isEnableCloseButton;

  /// Return street view is able to use fullscreen control. `Web only`
  bool get isFullscreenControl => _isFullscreenControl;

  /// Return street view is able to use links control. `Web only`
  bool get isLinksControl => _isLinksControl;

  /// Return street view is able to use motion tracking. `Web only`
  bool get isMotionTracking => _isMotionTracking;

  /// Return street view is able to use motion tracking control. `Web only`
  bool get isMotionTrackingControl => _isMotionTrackingControl;

  /// Return street view is able to use scrollwheel zooming. `Web only`
  bool get isScrollwheel => _isScrollwheel;

  /// Return street view is able to use pan control. `Web only`
  bool get isPanControl => _isPanControl;

  /// Return street view is able to use zoom control. `Web only`
  bool get isZoomControl => _isZoomControl;

  /// Return street view is visible on load. `Web only`
  bool get isVisible => _isVisible;

  /// Returns a screen location that corresponds to an orientation[StreetViewPanoramaOrientation]. `Web not support`
  Future<Point> orientationToPoint(StreetViewPanoramaOrientation orientation) {
    if (kIsWeb)
      throw UnsupportedError(
          "[orientationToPoint] is not yet supported for Web.");
    return _streetViewFlutterPlatform.orientationToPoint(viewId,
        orientation: orientation);
  }

  /// Return the orientation[StreetViewPanoramaOrientation] that corresponds to a screen location. `Web not support`
  Future<StreetViewPanoramaOrientation> pointToOrientation(Point point) {
    if (kIsWeb)
      throw UnsupportedError(
          "[pointToOrientation] is not yet supported for Web.");
    return _streetViewFlutterPlatform.pointToOrientation(viewId, point: point);
  }

  /// Sets panorama by given location
  ///
  /// Return [Future] while the change has been made on the platform side.
  Future<void> setPosition(
      {LatLng? position,
      String? panoId,
      int? radius,
      StreetViewSource? source}) {
    assert(position != null || panoId != null);
    assert(position == null || panoId == null);
    return _streetViewFlutterPlatform.setPosition(viewId,
        position: position, panoId: panoId, radius: radius, source: source);
  }

  /// Sets street view to allow using panning gesture or not. `Web not support` and [isPanningGesturesEnabled] always be true
  ///
  /// Return [Future] while the change has been made on the platform side.
  Future<void> setPanningGesturesEnabled(bool enable) {
    if (kIsWeb)
      throw UnsupportedError(
          "[setPanningGesturesEnabled] is not yet supported for Web.");
    if (enable == _isPanningGesturesEnabled)
      return Future.delayed(Duration.zero);
    return _streetViewFlutterPlatform
        .setPanningGesturesEnabled(viewId, enable)
        .then((value) => _isPanningGesturesEnabled = enable);
  }

  /// Sets street view to display street name or not.
  ///
  /// Return [Future] while the change has been made on the platform side.
  Future<void> setStreetNamesEnabled(bool enable) {
    if (enable == _isStreetNamesEnabled) return Future.delayed(Duration.zero);
    return _streetViewFlutterPlatform
        .setStreetNamesEnabled(viewId, enable)
        .then((value) => _isStreetNamesEnabled = enable);
  }

  /// Sets street view to allow moving to another panorama.
  ///
  /// Return [Future] while the change has been made on the platform side.
  Future<void> setUserNavigationEnabled(bool enable) {
    if (enable == _isUserNavigationEnabled)
      return Future.delayed(Duration.zero);
    return _streetViewFlutterPlatform
        .setUserNavigationEnabled(viewId, enable)
        .then((value) => _isUserNavigationEnabled = enable);
  }

  /// Sets street view to allow using zoom gestures or not. `Web not support` and [isZoomGesturesEnabled] always be true
  ///
  /// Return [Future] while the change has been made on the platform side.
  Future<void> setZoomGesturesEnabled(bool enable) {
    if (kIsWeb)
      throw UnsupportedError(
          "[setPanningGesturesEnabled] is not yet supported for Web.");
    if (enable == _isZoomGesturesEnabled) return Future.delayed(Duration.zero);
    return _streetViewFlutterPlatform
        .setZoomGesturesEnabled(viewId, enable)
        .then((value) => _isZoomGesturesEnabled = enable);
  }

  /// Sets street view to allow using address control or not. `Web only`
  ///
  /// Return [Future] while the change has been made on the platform side.
  Future<void> setAddressControl(bool enable) {
    if (!kIsWeb)
      throw UnsupportedError(
          "[setAddressControl] is not yet supported for Web.");
    if (enable == _isAddressControl) return Future.delayed(Duration.zero);
    return _streetViewFlutterPlatform
        .setAddressControl(viewId, enable)
        .then((value) {
      _isAddressControl = enable;
    });
  }

  /// Sets address control display position. `Web only`
  ///
  /// Return [Future] while the change has been made on the platform side.
  Future<void> setAddressControlOptions(ControlPosition pos) {
    if (!kIsWeb)
      throw UnsupportedError(
          "[setAddressControlOptions] is not yet supported for Web.");
    return _streetViewFlutterPlatform.setAddressControlOptions(viewId, pos);
  }

  /// Sets street view to allow using all default UI or not. `Web only`
  ///
  /// Return [Future] while the change has been made on the platform side.
  Future<void> setDisableDefaultUI(bool enable) {
    if (!kIsWeb)
      throw UnsupportedError(
          "[setDisableDefaultUI] is not yet supported for Web.");
    if (enable == _isDisableDefaultUI) return Future.delayed(Duration.zero);
    return _streetViewFlutterPlatform
        .setDisableDefaultUI(viewId, enable)
        .then((value) => _isDisableDefaultUI = enable);
  }

  /// Sets street view to allow using zoom on double click or not. `Web only`
  ///
  /// Return [Future] while the change has been made on the platform side.
  Future<void> setDisableDoubleClickZoom(bool enable) {
    if (!kIsWeb)
      throw UnsupportedError(
          "[setDisableDoubleClickZoom] is not yet supported for Web.");
    if (enable == _isDisableDoubleClickZoom)
      return Future.delayed(Duration.zero);
    return _streetViewFlutterPlatform
        .setDisableDoubleClickZoom(viewId, enable)
        .then((value) => _isDisableDoubleClickZoom = enable);
  }

  /// Sets street view to allow using close button or not. `Web only`
  ///
  /// Return [Future] while the change has been made on the platform side.
  Future<void> setEnableCloseButton(bool enable) {
    if (!kIsWeb)
      throw UnsupportedError(
          "[setEnableCloseButton] is not yet supported for Web.");
    if (enable == _isEnableCloseButton) return Future.delayed(Duration.zero);
    return _streetViewFlutterPlatform
        .setEnableCloseButton(viewId, enable)
        .then((value) => _isEnableCloseButton = enable);
  }

  /// Sets street view to allow using fullscreen control or not. `Web only`
  ///
  /// Return [Future] while the change has been made on the platform side.
  Future<void> setFullscreenControl(bool enable) {
    if (!kIsWeb)
      throw UnsupportedError(
          "[setFullscreenControl] is not yet supported for Web.");
    if (enable == _isFullscreenControl) return Future.delayed(Duration.zero);
    return _streetViewFlutterPlatform
        .setFullscreenControl(viewId, enable)
        .then((value) => _isFullscreenControl = enable);
  }

  /// Sets fullscreen control display position. `Web only`
  ///
  /// Return [Future] while the change has been made on the platform side.
  Future<void> setFullscreenControlOptions(ControlPosition pos) {
    if (!kIsWeb)
      throw UnsupportedError(
          "[setFullscreenControlOptions] is not yet supported for Web.");
    return _streetViewFlutterPlatform.setFullscreenControlOptions(viewId, pos);
  }

  /// Sets street view to allow using link control or not. `Web only`
  ///
  /// Return [Future] while the change has been made on the platform side.
  Future<void> setLinksControl(bool enable) {
    if (!kIsWeb)
      throw UnsupportedError("[setLinksControl] is not yet supported for Web.");
    if (enable == _isLinksControl) return Future.delayed(Duration.zero);
    return _streetViewFlutterPlatform
        .setLinksControl(viewId, enable)
        .then((value) => _isLinksControl = enable);
  }

  /// Sets street view to allow using motion tracking or not. `Web only`
  ///
  /// Return [Future] while the change has been made on the platform side.
  Future<void> setMotionTracking(bool enable) {
    if (!kIsWeb)
      throw UnsupportedError(
          "[setMotionTracking] is not yet supported for Web.");
    if (enable == _isMotionTracking) return Future.delayed(Duration.zero);
    return _streetViewFlutterPlatform
        .setMotionTracking(viewId, enable)
        .then((value) => _isMotionTracking = enable);
  }

  /// Sets street view to allow using motion tracking control or not. `Web only`
  ///
  /// Return [Future] while the change has been made on the platform side.
  Future<void> setMotionTrackingControl(bool enable) {
    if (!kIsWeb)
      throw UnsupportedError(
          "[setMotionTrackingControl] is not yet supported for Web.");
    if (enable == _isMotionTrackingControl)
      return Future.delayed(Duration.zero);
    return _streetViewFlutterPlatform
        .setMotionTrackingControl(viewId, enable)
        .then((value) => _isMotionTrackingControl = enable);
  }

  /// Sets motion tracking control display position. `Web only`
  ///
  /// Return [Future] while the change has been made on the platform side.
  Future<void> setMotionTrackingControlOptions(ControlPosition pos) {
    if (!kIsWeb)
      throw UnsupportedError(
          "[setMotionTrackingControlOptions] is not yet supported for Web.");
    return _streetViewFlutterPlatform.setMotionTrackingControlOptions(
        viewId, pos);
  }

  /// Sets street view to allow using pan control or not. `Web only`
  ///
  /// Return [Future] while the change has been made on the platform side.
  Future<void> setPanControl(bool enable) {
    if (!kIsWeb)
      throw UnsupportedError("[setPanControl] is not yet supported for Web.");
    if (enable == _isPanControl) return Future.delayed(Duration.zero);
    return _streetViewFlutterPlatform
        .setPanControl(viewId, enable)
        .then((value) => _isPanControl = enable);
  }

  /// Sets pan control display position. `Web only`
  ///
  /// Return [Future] while the change has been made on the platform side.
  Future<void> setPanControlOptions(ControlPosition pos) {
    if (!kIsWeb)
      throw UnsupportedError(
          "[setPanControlOptions] is not yet supported for Web.");
    return _streetViewFlutterPlatform.setPanControlOptions(viewId, pos);
  }

  /// Sets street view to allow using scrollwheel zooming or not. `Web only`
  ///
  /// Return [Future] while the change has been made on the platform side.
  Future<void> setScrollwheel(bool enable) {
    if (!kIsWeb)
      throw UnsupportedError("[setScrollwheel] is not yet supported for Web.");
    if (enable == _isScrollwheel) return Future.delayed(Duration.zero);
    return _streetViewFlutterPlatform
        .setScrollwheel(viewId, enable)
        .then((value) => _isScrollwheel = enable);
  }

  /// Sets street view to allow using zoom control or not. `Web only`
  ///
  /// Return [Future] while the change has been made on the platform side.
  Future<void> setZoomControl(bool enable) {
    if (!kIsWeb)
      throw UnsupportedError("[setZoomControl] is not yet supported for Web.");
    if (enable == _isZoomControl) return Future.delayed(Duration.zero);
    return _streetViewFlutterPlatform
        .setZoomControl(viewId, enable)
        .then((value) => _isZoomControl = enable);
  }

  /// Sets zoom control display position. `Web only`
  ///
  /// Return [Future] while the change has been made on the platform side.
  Future<void> setZoomControlOptions(ControlPosition pos) {
    if (!kIsWeb)
      throw UnsupportedError(
          "[setZoomControlOptions] is not yet supported for Web.");
    return _streetViewFlutterPlatform.setZoomControlOptions(viewId, pos);
  }

  /// Sets street view is visible. `Web only`
  ///
  /// Return [Future] while the change has been made on the platform side.
  Future<void> setVisible(bool enable) {
    if (!kIsWeb)
      throw UnsupportedError("[setVisible] is not yet supported for Web.");
    if (enable == _isVisible) return Future.delayed(Duration.zero);
    return _streetViewFlutterPlatform
        .setVisible(viewId, enable)
        .then((value) => _isVisible = enable);
  }

  /// Updates configuration options of the street view user interface.
  ///
  /// Change listeners are notified once the update has been made on the
  /// platform side.
  ///
  /// The returned [Future] completes after listeners have been notified.
  Future<dynamic> updateStreetView(Map<String, dynamic> optionsUpdate) {
    return _streetViewFlutterPlatform.updateStreetViewOptions(optionsUpdate,
        viewId: viewId);
  }

  void _connectStreams(int viewId) {
    if (_streetViewState.widget.onCameraChangeListener != null)
      _onCameraChange = _streetViewFlutterPlatform
          .onCameraChange(viewId: viewId)
          .listen((CameraChangeEvent e) =>
              _streetViewState.widget.onCameraChangeListener!(e.value));

    if (_streetViewState.widget.onPanoramaChangeListener != null)
      _onPanoramaChange = _streetViewFlutterPlatform
          .onPanoramaChange(viewId: viewId)
          .listen((e) => _streetViewState.widget.onPanoramaChangeListener!(
              e.value.location, e.value.exception));
    if (_streetViewState.widget.onPanoramaClickListener != null)
      _onPanoramaClick = _streetViewFlutterPlatform
          .onPanoramaClick(viewId: viewId)
          .listen((e) => _streetViewState.widget.onPanoramaClickListener!(
              e.value.orientation, e.value.point));
    if (_streetViewState.widget.onPanoramaLongClickListener != null)
      _onPanoramaLongClick = _streetViewFlutterPlatform
          .onPanoramaLongClick(viewId: viewId)
          .listen((e) => _streetViewState.widget.onPanoramaLongClickListener!(
              e.value.orientation, e.value.point));
    if (kIsWeb && _streetViewState.widget.onCloseClickListener != null)
      _onCloseClickListener = _streetViewFlutterPlatform
          .onCloseClick(viewId: viewId)
          .listen((e) => _streetViewState.widget.onCloseClickListener!());
    _streetViewFlutterPlatform
        .onMarkerTap(viewId: viewId)
        .listen((MarkerTapEvent e) => _streetViewState.onMarkerTap(e.value));
  }

  void dispose() {
    _disconnectStreams();
  }

  void _disconnectStreams() {
    _onCameraChange?.cancel();
    _onPanoramaChange?.cancel();
    _onPanoramaClick?.cancel();
    _onPanoramaLongClick?.cancel();
    _onCloseClickListener?.cancel();
  }

  /// Updates marker configuration.
  ///
  /// Change listeners are notified once the update has been made on the
  /// platform side.
  ///
  /// The returned [Future] completes after listeners have been notified.
  Future<void> updateMarkers(MarkerUpdates markerUpdates) {
    return _streetViewFlutterPlatform.updateMarkers(markerUpdates,
        viewId: viewId);
  }
}
