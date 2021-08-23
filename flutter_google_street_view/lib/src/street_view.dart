import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:street_view_platform_interface/street_view_platform_interface.dart';

class FlutterGoogleStreetView extends StatefulWidget {
  const FlutterGoogleStreetView(
      {Key? key,
      this.onStreetViewCreated,
      this.onCameraChangeListener,
      this.onPanoramaChangeListener,
      this.onPanoramaClickListener, //Web not supported
      this.onPanoramaLongClickListener, //Web not supported
      this.onCloseClickListener, //Web only
      this.initPanoId,
      this.initPos,
      this.initRadius,
      this.initSource,
      this.initFov = 90, //iOS only
      this.initBearing,
      this.initTilt,
      this.initZoom,
      this.panningGesturesEnabled = true, //Web not supported
      this.streetNamesEnabled = true,
      this.userNavigationEnabled = true,
      this.zoomGesturesEnabled = true,
      this.gestureRecognizers,

      // Web only //
      this.addressControl,
      this.addressControlOptions,
      this.disableDefaultUI,
      this.disableDoubleClickZoom,
      this.enableCloseButton,
      this.fullscreenControl,
      this.fullscreenControlOptions,
      this.linksControl,
      this.motionTracking,
      this.motionTrackingControl,
      this.motionTrackingControlOptions,
      this.scrollwheel,
      this.panControl,
      this.panControlOptions,
      this.zoomControl,
      this.zoomControlOptions,
      this.visible
      // Web only //
      })
      : assert((initPanoId != null) ^ (initPos != null)),
        assert((initTilt != null && initTilt >= -90 && initTilt <= 90) ||
            initTilt == null),
        super(key: key);

  Type get _dTag => runtimeType;

  /// Specifies initialization position by panoramaID.
  /// [initPos] should be null while [initPanoId] was set.
  final String? initPanoId;

  /// Specifies initialization position by latitude and longitude.
  /// [initPanoId] should be null while [initPos] was set.
  final LatLng? initPos;

  /// Specifies radius used to search for a Street View panorama
  final double? initRadius;

  /// Specifies the source filter used to search for a Street View panorama,
  /// or DEFAULT if unspecified.
  final StreetViewSource? initSource;

  /// Specifies bearing for initialization position,
  /// it worked while [initPos] or [initPanoId] was specified.
  /// Sets the direction that the camera is pointing in, in degrees clockwise from north.
  final double? initBearing;

  /// Specifies tilt for initialization position,
  /// it worked while [initPos] or [initPanoId] was specified.
  /// This value is restricted to being between -90 (directly down) and 90 (directly up).
  final double? initTilt;

  /// Specifies zoom for initialization position,
  /// it worked while [initPos] or [initPanoId] was specified.
  /// Sets the zoom level of the camera. The original zoom level is set at 0.
  /// A zoom of 1 would double the magnification. The zoom is clamped between 0 and the maximum zoom level.
  /// The maximum zoom level can vary based upon the panorama.
  /// Clamped means that any value falling outside this range will be set to the closest extreme that falls within the range.
  /// For example, a value of -1 will be set to 0.
  /// Another example: If the maximum zoom for the panorama is 19,
  /// and the value is given as 20, it will be set to 19.
  /// Note that the camera zoom need not be an integer value.
  final double? initZoom;

  /// ** iOS only **
  /// The field of view (FOV) encompassed by the larger dimension (width or height) of the view in degrees at zoom 1.
  /// This is clamped to the range [1, 160] degrees, and has a default value of 90.
  /// Lower FOV values produce a zooming in effect; larger FOV values produce an fisheye effect.
  final double? initFov;

  /// ** Web not supported **
  /// Sets whether the user is able to use panning gestures
  final bool panningGesturesEnabled;

  /// Sets whether the user is able to see street names on panoramas
  final bool streetNamesEnabled;

  /// Sets whether the user is able to move to another panorama
  final bool userNavigationEnabled;

  /// ** Web not supported **
  /// Sets whether the user is able to use zoom gestures
  final bool zoomGesturesEnabled;

  /// Callback method for when the street view is ready to be used.
  ///
  /// Used to receive a [StreetViewController] for this [FlutterGoogleStreetView].
  final StreetViewCreatedCallback? onStreetViewCreated;
  final CameraChangeListener? onCameraChangeListener;
  final PanoramaChangeListener? onPanoramaChangeListener;
  final PanoramaClickListener? onPanoramaClickListener; //Web not supported
  final PanoramaLongClickListener?
      onPanoramaLongClickListener; //Web not supported
  final VoidCallback? onCloseClickListener; //Web only

  /// ** Web only **
  /// The enabled/disabled state of the address control.
  final bool? addressControl;

  /// ** Web only **
  /// The display position for the address control.
  final ControlPosition? addressControlOptions;

  /// ** Web only **
  /// Enables/disables all default UI. May be overridden individually.
  final bool? disableDefaultUI;

  /// ** Web only **
  /// Enables/disables zoom on double click. Disabled by default.
  final bool? disableDoubleClickZoom;

  /// ** Web only **
  /// If true, the close button is displayed. Disabled by default.
  final bool? enableCloseButton;

  /// ** Web only **
  /// The enabled/disabled state of the fullscreen control.
  final bool? fullscreenControl;

  /// ** Web only **
  /// The display position for the fullscreen control.
  final ControlPosition? fullscreenControlOptions;

  /// ** Web only **
  /// The enabled/disabled state of the links control.
  final bool? linksControl;

  /// ** Web only **
  /// Whether motion tracking is on or off.
  /// Enabled by default when the motion tracking control is present,so that the POV (point of view) follows the orientation of the device.
  /// This is primarily applicable to mobile devices.
  /// If motionTracking is set to false while motionTrackingControl is enabled,
  /// the motion tracking control appears but tracking is off. The user can tap the motion tracking control to toggle this option.
  final bool? motionTracking;

  /// ** Web only **
  /// The enabled/disabled state of the motion tracking control.
  /// Enabled by default when the device has motion data, so that the control appears on the map.
  /// This is primarily applicable to mobile devices.
  final bool? motionTrackingControl;

  /// ** Web only **
  /// The display position for the motion tracking control.
  final ControlPosition? motionTrackingControlOptions;

  /// ** Web only **
  /// If false, disables scrollwheel zooming in Street View. The scrollwheel is enabled by default.
  final bool? scrollwheel;

  /// ** Web only **
  /// The enabled/disabled state of the pan control.
  final bool? panControl;

  /// ** Web only **
  /// The display position for the pan control.
  final ControlPosition? panControlOptions;

  /// ** Web only **
  /// The enabled/disabled state of the zoom control.
  final bool? zoomControl;

  /// ** Web only **
  /// The display position for the zoom control.
  final ControlPosition? zoomControlOptions;

  /// ** Web only **
  /// If true, the Street View panorama is visible on load.
  final bool? visible;

  /// Which gestures should be consumed by the streetView.
  ///
  /// It is possible for other gesture recognizers to be competing with the streetView on pointer
  /// events, e.g if the streetView is inside a [ListView] the [ListView] will want to handle
  /// vertical drags. The street view will claim gestures that are recognized by any of the
  /// recognizers on this list.
  ///
  /// When this set is empty or null, the street view will only handle pointer events for gestures that
  /// were not claimed by any other gesture recognizer.
  final Set<Factory<OneSequenceGestureRecognizer>>? gestureRecognizers;

  @override
  State<StatefulWidget> createState() {
    throw UnimplementedError();
  }

  /// Notice input parameter may not support.
  void _checkParam() {
    throw UnimplementedError();
  }
}

class StreetViewState extends State<FlutterGoogleStreetView> {
  get _onStreetViewCreated => widget.onStreetViewCreated;
  final Completer<StreetViewController> _controller =
      Completer<StreetViewController>();
  static int webViewId = -1;

  StreetViewPanoramaOptions get optionFromWidget => throw UnimplementedError();

  void _updateOptions() async {
    throw UnimplementedError();
  }

  void _onPlatformViewCreated(int id) async {
    throw UnimplementedError();
  }

  @override
  Widget build(BuildContext context) {
    throw UnimplementedError();
  }

  @override
  void didUpdateWidget(FlutterGoogleStreetView oldWidget) {
    throw UnimplementedError();
  }
}
