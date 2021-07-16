import 'util/misc.dart';

class StreetViewPanoramaLink {
  StreetViewPanoramaLink({this.bearing, this.panoId});

  /// The direction of the linked panorama, in degrees clockwise from north.
  final double? bearing;

  /// The panorama ID of the linked panorama.
  final String? panoId;

  /// Create a [StreetViewPanoramaLink] and init data by a map.
  factory StreetViewPanoramaLink.fromMap(Map<String, dynamic> map) {
    return new StreetViewPanoramaLink(
      bearing: map['bearing'] as double?,
      panoId: map['panoId'] as String?,
    );
  }

  /// Put all param to a map
  Map<String, dynamic> toMap() {
    final Map<String, dynamic> map = <String, dynamic>{};
    putToMapIfNonNull(map, 'bearing', this.bearing);
    putToMapIfNonNull(map, 'panoId', this.panoId);
    return map;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StreetViewPanoramaLink &&
          runtimeType == other.runtimeType &&
          bearing == other.bearing &&
          panoId == other.panoId;

  @override
  int get hashCode => bearing.hashCode ^ panoId.hashCode;

  @override
  String toString() {
    return 'StreetViewPanoramaLink{bearing: $bearing, panoId: $panoId}';
  }
}
