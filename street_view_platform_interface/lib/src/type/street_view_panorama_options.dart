import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';
import 'package:street_view_platform_interface/src/type/camera.dart';
import 'package:street_view_platform_interface/src/type/street_view_source.dart';

import '../../street_view_platform_interface.dart';

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

  StreetViewPanoramaOptions(
      {this.panoId,
      this.position,
      this.radius,
      this.source,
      this.panningGesturesEnabled,
      this.streetNamesEnabled,
      this.userNavigationEnabled,
      this.zoomGesturesEnabled,
      this.panoramaCamera})
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
