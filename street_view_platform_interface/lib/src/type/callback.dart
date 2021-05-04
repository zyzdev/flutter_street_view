import 'package:street_view_platform_interface/src/type/camera.dart';
import 'package:street_view_platform_interface/src/type/street_view_panorama_orientation.dart';

/// Callback that receiving last camera position.
///
/// The callback receive [StreetViewPanoramaCamera] while the camera of the platform
/// street view was changed.
///
/// This is set at [FlutterGoogleStreetView.onCameraChangeListener].
typedef void CameraChangeListener(StreetViewPanoramaCamera camera);

/// Callback that receiving last panorama location and information near panoramas.
///
/// The callback receive [StreetViewPanoramaLocation] while the panorama of the platform
/// street view was changed.
///
/// This is set at [FlutterGoogleStreetView.onPanoramaChangeListener].
typedef void PanoramaChangeListener(StreetViewPanoramaLocation location);

/// Callback that receiving last tap event on current panorama.
///
/// The callback receive [StreetViewPanoramaOrientation] while the panorama of the platform
/// street view was tapped.
///
/// This is set at [FlutterGoogleStreetView.onPanoramaClickListener].
typedef void PanoramaClickListener(StreetViewPanoramaOrientation orientation);

/// Callback that receiving last long tap event on current panorama.
///
/// The callback receive [StreetViewPanoramaOrientation] while the panorama of the platform
/// street view was long tapped.
///
/// This is set at [FlutterGoogleStreetView.onPanoramaClickListener].
typedef void PanoramaLongClickListener(
    StreetViewPanoramaOrientation orientation);
