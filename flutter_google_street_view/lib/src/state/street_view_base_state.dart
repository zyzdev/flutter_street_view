import 'package:flutter/cupertino.dart';
import 'package:flutter_google_street_view/flutter_google_street_view.dart';
import 'package:meta/meta.dart';

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
