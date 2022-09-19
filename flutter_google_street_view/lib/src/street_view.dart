import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_google_street_view/flutter_google_street_view.dart';
import 'package:flutter_google_street_view/src/state/street_view_state.dart'
    if (dart.library.html) 'web/street_view_state.dart'
    if (dart.library.io) 'mobile/street_view_state.dart';

class FlutterGoogleStreetView extends StatefulWidget {
  const FlutterGoogleStreetView({
    Key? key,
    this.onStreetViewCreated,
    this.onCameraChangeListener,
    this.onPanoramaChangeListener,
    this.onPanoramaClickListener,
    this.onPanoramaLongClickListener,
    this.onCloseClickListener,
    this.initPanoId,
    this.initPos,
    this.initRadius,
    this.initSource,
    this.initFov, //iOS only
    this.initBearing,
    this.initTilt,
    this.initZoom,
    this.panningGesturesEnabled, //Web not supported.
    this.streetNamesEnabled = true,
    this.userNavigationEnabled = true,
    this.zoomGesturesEnabled, //Web not supported.
    this.gestureRecognizers, //Web not supported.
    this.markers, //iOS only

    // Web only //
    this.addressControl,
    this.addressControlOptions,
    this.disableDefaultUI,
    this.disableDoubleClickZoom = kIsWeb ? false : null,
    this.enableCloseButton = kIsWeb ? false : null,
    this.fullscreenControl,
    this.fullscreenControlOptions,
    this.linksControl,
    this.motionTracking,
    this.motionTrackingControl,
    this.motionTrackingControlOptions,
    this.scrollwheel = kIsWeb ? true : null,
    this.panControl,
    this.panControlOptions,
    this.zoomControl,
    this.zoomControlOptions,
    this.visible,
    // Web only //
  })  : assert((initPanoId != null) ^ (initPos != null)),
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

  /// The field of view (FOV) encompassed by the larger dimension (width or height) of the view in degrees at zoom 1. `iOS only`
  /// This is clamped to the range [1, 160] degrees, and has a default value of 90.
  /// Lower FOV values produce a zooming in effect; larger FOV values produce an fisheye effect.
  final double? initFov;

  /// Sets whether the user is able to use panning gestures. `Web not supported`
  final bool? panningGesturesEnabled;

  /// Sets whether the user is able to see street names on panoramas
  final bool streetNamesEnabled;

  /// Sets whether the user is able to move to another panorama
  final bool userNavigationEnabled;

  /// Sets whether the user is able to use zoom gestures. `Web not supported`
  final bool? zoomGesturesEnabled;

  /// Callback method for when the street view is ready to be used.
  ///
  /// Used to receive a [StreetViewController] for this [FlutterGoogleStreetView].
  final StreetViewCreatedCallback? onStreetViewCreated;
  final CameraChangeListener? onCameraChangeListener;
  final PanoramaChangeListener? onPanoramaChangeListener;
  final PanoramaClickListener? onPanoramaClickListener; //Web not supported
  final PanoramaLongClickListener?
      onPanoramaLongClickListener; //Web not supported

  /// Markers to be placed on the street view. `iOS only`
  final Set<Marker>? markers;

  final CloseClickListener? onCloseClickListener; //Web only

  /// The enabled/disabled state of the address control. `Web only`
  final bool? addressControl;

  /// The display position for the address control. `Web only`
  final ControlPosition? addressControlOptions;

  /// Enables/disables all default UI. `Web only`
  final bool? disableDefaultUI;

  /// Enables/disables zoom on double click. Disabled by default. `Web only`
  final bool? disableDoubleClickZoom;

  /// If true, the close button is displayed. Disabled by default. `Web only`
  final bool? enableCloseButton;

  /// The enabled/disabled state of the fullscreen control. `Web only`
  final bool? fullscreenControl;

  /// The display position for the fullscreen control. `Web only`
  final ControlPosition? fullscreenControlOptions;

  /// The enabled/disabled state of the links control. `Web only`
  final bool? linksControl;

  /// Whether motion tracking is on or off. `Web only`
  /// Enabled by default when the motion tracking control is present,so that the POV (point of view) follows the orientation of the device.
  /// This is primarily applicable to mobile devices.
  /// If motionTracking is set to false while motionTrackingControl is enabled,
  /// the motion tracking control appears but tracking is off. The user can tap the motion tracking control to toggle this option.
  final bool? motionTracking;

  /// The enabled/disabled state of the motion tracking control. `Web only`
  /// Enabled by default when the device has motion data, so that the control appears on the street view.
  /// This is primarily applicable to mobile devices.
  final bool? motionTrackingControl;

  /// The display position for the motion tracking control. `Web only`
  final ControlPosition? motionTrackingControlOptions;

  /// The enabled/disabled state of the pan control. `Web only`
  final bool? panControl;

  /// If false, disables scrollwheel zooming in Street View. The scrollwheel is enabled by default. `Web only`
  final bool? scrollwheel;

  /// The display position for the pan control. `Web only`
  final ControlPosition? panControlOptions;

  /// The enabled/disabled state of the zoom control. `Web only`
  final bool? zoomControl;

  /// The display position for the zoom control. `Web only`
  final ControlPosition? zoomControlOptions;

  /// If true, the Street View panorama is visible on load. `Web only`
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

  /// The created count of native street view.
  static int get createdCount =>
      StreetViewFlutterPlatform.instance.nativeStreetViewCreatedCount;

  @override
  State<StatefulWidget> createState() {
    _checkParam();
    return StreetViewState();
  }

  /// Notice input parameter may not support.
  void _checkParam() {
    String message(String param) =>
        "$_dTag: <<< Notice >>> $param is not support for ${kIsWeb ? "Web" : Platform.isAndroid ? "Android" : Platform.isIOS ? "iOS" : "Other Platform"}! <<< Notice >>>";
    if (kIsWeb) {
      if (initFov != null) debugPrint(message("initFov"));
      if (markers != null) debugPrint(message("markers"));
      if (panningGesturesEnabled != null)
        debugPrint(message("panningGesturesEnabled"));
      if (zoomGesturesEnabled != null)
        debugPrint(message("zoomGesturesEnabled"));
      if (gestureRecognizers != null) debugPrint(message("gestureRecognizers"));
    } else if (Platform.isAndroid || Platform.isIOS) {
      if (Platform.isAndroid) {
        if (initFov != null) debugPrint(message("initFov"));
        if (markers != null) debugPrint(message("markers"));
      }
      if (addressControl != null) debugPrint(message("addressControl"));
      if (addressControlOptions != null)
        debugPrint(message("addressControlOptions"));
      if (disableDefaultUI != null) debugPrint(message("disableDefaultUI"));
      if (disableDoubleClickZoom != null)
        debugPrint(message("disableDoubleClickZoom"));
      if (enableCloseButton != null) debugPrint(message("enableCloseButton"));
      if (fullscreenControl != null) debugPrint(message("fullscreenControl"));
      if (fullscreenControlOptions != null)
        debugPrint(message("fullscreenControlOptions"));
      if (linksControl != null) debugPrint(message("linksControl"));
      if (motionTracking != null) debugPrint(message("motionTracking"));
      if (motionTrackingControl != null)
        debugPrint(message("motionTrackingControl"));
      if (motionTrackingControlOptions != null)
        debugPrint(message("motionTrackingControlOptions"));
      if (scrollwheel != null) debugPrint(message("scrollwheel"));
      if (panControl != null) debugPrint(message("panControl"));
      if (panControlOptions != null) debugPrint(message("panControlOptions"));
      if (zoomControl != null) debugPrint(message("zoomControl"));
      if (zoomControlOptions != null) debugPrint(message("zoomControlOptions"));
      if (visible != null) debugPrint(message("visible"));
    }
  }
}
