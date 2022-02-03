import 'package:flutter/cupertino.dart';
import 'package:flutter_google_street_view/flutter_google_street_view.dart';
import 'package:meta/meta.dart';
import 'package:street_view_platform_interface/street_view_platform_interface.dart';

class StreetViewBaseState extends State<FlutterGoogleStreetView> {
  @override
  Widget build(BuildContext context) => throw UnimplementedError();

  StreetViewPanoramaOptions get optionFromWidget => throw UnimplementedError();

  @visibleForOverriding
  void updateOptions() async {
    throw UnimplementedError();
  }

  @visibleForOverriding
  void onPlatformViewCreated(int id) async {}

  void onMarkerTap(MarkerId markerId) {
    throw UnimplementedError();
  }
}