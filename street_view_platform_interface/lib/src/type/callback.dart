import 'dart:math';

import 'package:street_view_platform_interface/src/type/camera.dart';
import 'package:street_view_platform_interface/src/type/street_view_panorama_orientation.dart';

/// Callback that receiving last camera position.
///
/// The callback receive [StreetViewPanoramaCamera] while the camera of the platform
/// street view was changed.
///
/// This is set at [FlutterGoogleStreetView.onCameraChangeListener].
/// [camera], current panorama camera info.
typedef CameraChangeListener = void Function(StreetViewPanoramaCamera camera);

/// Callback that receiving last panorama location and information near panoramas.
///
/// The callback receive [StreetViewPanoramaLocation] while the panorama of the platform
/// street view was changed.
///
/// This is set at [FlutterGoogleStreetView.onPanoramaChangeListener].
/// [location], Current location of this panorama.
/// [e], panorama changing fail if not null.
typedef PanoramaChangeListener = void Function(
    StreetViewPanoramaLocation? location, Exception? e);

/// Callback that receiving last tap event on current panorama. `Web not support`
///
/// The callback receive [StreetViewPanoramaOrientation] & [Point]while the panorama of the platform
/// street view was tapped.
///
/// This is set at [FlutterGoogleStreetView.onPanoramaClickListener].
/// [orientation], The tilt and bearing values corresponding to the point on the screen where the user tapped.
/// These values have an absolute value within a specific panorama, and are independent of the current orientation of the camera.
/// [point], The point on the screen where the user tapped.
typedef PanoramaClickListener = void Function(
    StreetViewPanoramaOrientation orientation, Point point);

/// Callback that receiving last long tap event on current panorama. `Web not support`
///
/// The callback receive [StreetViewPanoramaOrientation] while the panorama of the platform
/// street view was long tapped.
///
/// This is set at [FlutterGoogleStreetView.onPanoramaClickListener].
/// [orientation], The tilt and bearing values corresponding to the point on the screen where the user tapped.
/// These values have an absolute value within a specific panorama, and are independent of the current orientation of the camera.
/// [point], The point on the screen where the user tapped.
typedef PanoramaLongClickListener = void Function(
    StreetViewPanoramaOrientation orientation, Point point);

/// Callback that receiving last close button on click event on current panorama. `Web only`
///
/// This is set at [FlutterGoogleStreetView.onCloseClickListener].
typedef CloseClickListener = void Function();
