import 'package:street_view_platform_interface/street_view_platform_interface.dart';

class StreetViewEvent<T> {
  /// The ID of the Street View this event is associated to.
  final int viewId;

  /// The value wrapped by this event
  final T value;

  /// Build a Street View Event, that relates a viewId with a given value.
  ///
  /// The `viewId` is the id of the street view that triggered the event.
  /// `value` may be `null` in events that don't transport any meaningful data.
  StreetViewEvent(this.viewId, this.value);
}

/// An event fired when the Camera of a [viewId] starts changing.
class CameraChangeEvent extends StreetViewEvent<StreetViewPanoramaCamera> {
  /// Build a CameraChangeEvent Event triggered from the map represented by `viewId`.
  ///
  /// The `value` of this event is a [StreetViewPanoramaCamera] object with the current position of the Camera.
  CameraChangeEvent(int viewId, StreetViewPanoramaCamera camera)
      : super(viewId, camera);
}

/// An event fired when the Panorama of a [viewId] changed.
class PanoramaChangeEvent extends StreetViewEvent<StreetViewPanoramaLocation> {
  /// Build a CameraMoveStarted Event triggered from the map represented by `mapId`.
  ///
  /// The `value` of this event is a [StreetViewPanoramaLocation] object with the current position of the Panorama.
  PanoramaChangeEvent(int viewId, StreetViewPanoramaLocation location)
      : super(viewId, location);
}

/// An event fired when the Panorama of a [viewId] was clicked.
class PanoramaClickEvent
    extends StreetViewEvent<StreetViewPanoramaOrientation> {
  /// Build a CameraMoveStarted Event triggered from the map represented by `mapId`.
  ///
  /// The `value` of this event is a [StreetViewPanoramaOrientation] object with the position was clicked by user.
  PanoramaClickEvent(int viewId, StreetViewPanoramaOrientation orientation)
      : super(viewId, orientation);
}

/// An event fired when the Panorama of a [viewId] was clicked by long press.
class PanoramaLongClickEvent
    extends StreetViewEvent<StreetViewPanoramaOrientation> {
  /// Build a CameraMoveStarted Event triggered from the map represented by `mapId`.
  ///
  /// The `value` of this event is a [StreetViewPanoramaOrientation] object with the position was long clicked by user.
  PanoramaLongClickEvent(int viewId, StreetViewPanoramaOrientation orientation)
      : super(viewId, orientation);
}
