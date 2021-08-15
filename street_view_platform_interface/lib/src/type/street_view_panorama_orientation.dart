import '../../street_view_platform_interface.dart';

class StreetViewPanoramaOrientation {
  StreetViewPanoramaOrientation({this.bearing, this.tilt});

  /// Direction of the orientation, in degrees clockwise from north.
  final double? bearing;

  /// The angle, in degrees, of the orientation.
  final double? tilt;

  /// Create [StreetViewPanoramaOrientation] and put data by [map].
  factory StreetViewPanoramaOrientation.fromMap(dynamic map) {
    return StreetViewPanoramaOrientation(
      bearing: map['bearing'] as double?,
      tilt: map['tilt'] as double?,
    );
  }

  /// Put all param to a map
  Map<String, dynamic> toMap() {
    final Map<String, dynamic> map = <String, dynamic>{};
    putToMapIfNonNull(map, 'bearing', this.bearing);
    putToMapIfNonNull(map, 'tilt', this.tilt);
    return map;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StreetViewPanoramaOrientation &&
          runtimeType == other.runtimeType &&
          bearing == other.bearing &&
          tilt == other.tilt;

  @override
  int get hashCode => bearing.hashCode ^ tilt.hashCode;

  @override
  String toString() {
    return 'StreetViewPanoramaOrientation{bearing: $bearing, tilt: $tilt}';
  }
}
