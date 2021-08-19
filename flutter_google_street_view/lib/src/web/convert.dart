import 'package:google_maps/google_maps.dart' as gmaps;

/// Convert StreetViewPanoramaOptions to StreetViewPanoramaOptions of gmap
Future<gmaps.StreetViewPanoramaOptions> toStreetViewPanoramaOptions(
    Map<String, dynamic> arg,
    {gmaps.StreetViewPanorama? current}) async {
  final result = gmaps.StreetViewPanoramaOptions();
  result.pano = arg['panoId'];
  if (arg['position'] is List<double>) {
    final location = gmaps.LatLng(arg['position'][0], arg['position'][1]);
    double? raduis = arg['radius'] as double?;
    String? source = arg['source'] as String?;
    if (raduis != null || source != null) {
      final sourceTmp = source == "outdoor"
          ? gmaps.StreetViewSource.OUTDOOR
          : gmaps.StreetViewSource.DEFAULT;
      final request = gmaps.StreetViewLocationRequest()
        ..location = location
        ..radius = raduis
        ..source = sourceTmp;
      try {
        final response = await gmaps.StreetViewService().getPanorama(request);
        result.position = response.data?.location?.latLng;
      } catch (e) {
        result.position = location;
      }
    } else {
      result.position = location;
    }
  }
  result.showRoadLabels = arg['streetNamesEnabled'] as bool? ?? true;
  result.clickToGo = arg['userNavigationEnabled'] as bool? ?? true;

  result.zoomControl = arg['zoomGesturesEnabled'] as bool? ?? true;
  result.scrollwheel = result.zoomControl;

  print(arg['bearing'] as double?);

  final currentPov = current?.pov;
  result.pov = gmaps.StreetViewPov()
    ..heading = arg['bearing'] ?? currentPov?.heading ?? 0
    ..pitch = arg['tilt'] ?? currentPov?.pitch ?? 0;
  result.zoom = arg['zoom'] as double?;

  print("heading:${currentPov?.heading}");

  //force setting
  result.addressControl = false;

  return result;
}
