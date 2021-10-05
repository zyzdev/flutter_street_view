import 'package:street_view_platform_interface/src/type/camera.dart';
import 'package:street_view_platform_interface/src/type/street_view_source.dart';

import '../../street_view_platform_interface.dart';
import 'latLng.dart';

class StreetViewPanoramaOptions {
  /// Set initialization location by panorama ID.
  /// [position] should be null if [panoId] is given.
  final String? panoId;

  /// Set initialization location by latitude and longitude.
  /// [panoId] should be null if [position] is given.
  final LatLng? position;

  /// Set radius to filter initialization panorama.
  final double? radius;

  /// Set panorama source filter to search initialization panorama.
  final StreetViewSource? source;

  /// Sets whether the user is able to use panning gestures
  final bool? panningGesturesEnabled;

  /// Sets whether the user is able to see street names on panoramas
  final bool? streetNamesEnabled;

  /// Sets whether the user is able to move to another panorama
  final bool? userNavigationEnabled;

  /// Sets whether the user is able to use zoom gestures
  final bool? zoomGesturesEnabled;

  /// Sets initialization position of camera.
  final StreetViewPanoramaCamera? panoramaCamera;

  /// Markers to be placed on the map. `iOS only`
  final Set<Marker>? markers;

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
  /// Enabled by default when the device has motion data, so that the control appears on the map.
  /// This is primarily applicable to mobile devices.
  final bool? motionTrackingControl;

  /// The display position for the motion tracking control. `Web only`
  final ControlPosition? motionTrackingControlOptions;

  /// If false, disables scrollwheel zooming in Street View. The scrollwheel is enabled by default. `Web only`
  final bool? scrollwheel;

  /// The enabled/disabled state of the pan control. `Web only`
  final bool? panControl;

  /// The display position for the pan control. `Web only`
  final ControlPosition? panControlOptions;

  /// The enabled/disabled state of the zoom control. `Web only`
  final bool? zoomControl;

  /// The display position for the zoom control. `Web only`
  final ControlPosition? zoomControlOptions;

  /// If true, the Street View panorama is visible on load. `Web only`
  final bool? visible;

  StreetViewPanoramaOptions(
      {this.panoId,
      this.position,
      this.radius,
      this.source,
      this.panningGesturesEnabled,
      this.streetNamesEnabled,
      this.userNavigationEnabled,
      this.zoomGesturesEnabled,
      this.panoramaCamera,
      this.markers,

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
      : assert(panoId == null || position == null);

  /// Create [StreetViewPanoramaOptions] and put data by [map].
  factory StreetViewPanoramaOptions.fromMap(Map<String, dynamic> map) {
    return new StreetViewPanoramaOptions(
      panoId: map['panoId'] as String?,
      position: map['position'] as LatLng?,
      radius: map['radius'] as double?,
      source: map['source'] as StreetViewSource?,
      panningGesturesEnabled: map['panningGesturesEnabled'] as bool?,
      streetNamesEnabled: map['streetNamesEnabled'] as bool?,
      userNavigationEnabled: map['userNavigationEnabled'] as bool?,
      zoomGesturesEnabled: map['zoomGesturesEnabled'] as bool?,
      panoramaCamera: map['panoramaCamera'] as StreetViewPanoramaCamera?,
    );
  }

  /// Put all param to a map
  Map<String, dynamic> toMap() {
    final Map<String, dynamic> map = <String, dynamic>{};

    putToMapIfNonNull(map, 'panoId', panoId);
    putToMapIfNonNull(map, 'position', position?.toJson());
    putToMapIfNonNull(map, 'radius', radius);
    putToMapIfNonNull(map, 'source', source?.toJson());
    putToMapIfNonNull(map, 'panningGesturesEnabled', panningGesturesEnabled);
    putToMapIfNonNull(map, 'streetNamesEnabled', streetNamesEnabled);
    putToMapIfNonNull(map, 'userNavigationEnabled', userNavigationEnabled);
    putToMapIfNonNull(map, 'zoomGesturesEnabled', zoomGesturesEnabled);
    map.addAll(panoramaCamera!.toMap());

    // Web only //
    putToMapIfNonNull(map, 'addressControl', addressControl);
    putToMapIfNonNull(
        map, 'addressControlOptions', addressControlOptions?.toJson());
    putToMapIfNonNull(map, 'disableDefaultUI', disableDefaultUI);
    putToMapIfNonNull(map, 'disableDoubleClickZoom', disableDoubleClickZoom);
    putToMapIfNonNull(map, 'enableCloseButton', enableCloseButton);
    putToMapIfNonNull(map, 'fullscreenControl', fullscreenControl);
    putToMapIfNonNull(
        map, 'fullscreenControlOptions', fullscreenControlOptions?.toJson());
    putToMapIfNonNull(map, 'linksControl', linksControl);
    putToMapIfNonNull(map, 'motionTracking', motionTracking);
    putToMapIfNonNull(map, 'motionTrackingControl', motionTrackingControl);
    putToMapIfNonNull(map, 'motionTrackingControlOptions',
        motionTrackingControlOptions?.toJson());
    putToMapIfNonNull(map, 'scrollwheel', scrollwheel);
    putToMapIfNonNull(map, 'panControl', panControl);
    putToMapIfNonNull(map, 'panControlOptions', panControlOptions?.toJson());
    putToMapIfNonNull(map, 'zoomControl', zoomControl);
    putToMapIfNonNull(map, 'zoomControlOptions', zoomControlOptions?.toJson());
    putToMapIfNonNull(map, 'visible', visible);
    // Web only //
    return map;
  }

  Map<String, dynamic> updatesMap(StreetViewPanoramaOptions newOptions) {
    final Map<String, dynamic> prevOptionsMap = toMap();

    return newOptions.toMap()
      ..removeWhere((String key, dynamic value) {
        if (key == "position") {
          List<double>? pPos = prevOptionsMap[key];
          List<double> nPos = value;
          if (pPos != null) {
            return pPos[0] == nPos[0] && pPos[1] == nPos[1];
          } else
            return (pPos == null);
        } else
          return prevOptionsMap[key] == value;
      });
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StreetViewPanoramaOptions &&
          runtimeType == other.runtimeType &&
          panoId == other.panoId &&
          position == other.position &&
          radius == other.radius &&
          source == other.source &&
          panningGesturesEnabled == other.panningGesturesEnabled &&
          streetNamesEnabled == other.streetNamesEnabled &&
          userNavigationEnabled == other.userNavigationEnabled &&
          zoomGesturesEnabled == other.zoomGesturesEnabled &&
          panoramaCamera == other.panoramaCamera;

  @override
  int get hashCode =>
      panoId.hashCode ^
      position.hashCode ^
      radius.hashCode ^
      source.hashCode ^
      panningGesturesEnabled.hashCode ^
      streetNamesEnabled.hashCode ^
      userNavigationEnabled.hashCode ^
      zoomGesturesEnabled.hashCode ^
      panoramaCamera.hashCode;

  @override
  String toString() {
    return 'StreetViewPanoramaOptions{panoId: $panoId, position: $position, radius: $radius, source: $source, panningGesturesEnabled: $panningGesturesEnabled, streetNamesEnabled: $streetNamesEnabled, userNavigationEnabled: $userNavigationEnabled, zoomGesturesEnabled: $zoomGesturesEnabled, panoramaCamera: $panoramaCamera}';
  }
}
