import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter_google_street_view/flutter_google_street_view.dart';
import 'package:street_view_platform_interface/street_view_platform_interface.dart';

class StreetViewState extends State<FlutterGoogleStreetView> {
  StreetViewFlutterPlatform _streetViewFlutterPlatform =
      StreetViewFlutterPlatform.instance;

  get _onStreetViewCreated => widget.onStreetViewCreated;
  final Completer<StreetViewController> _controller =
      Completer<StreetViewController>();
  late StreetViewPanoramaOptions _streetViewOptions;
  static int webViewId = -1;

  @override
  void initState() {
    super.initState();
    webViewId++;
    _streetViewOptions = optionFromWidget;
  }

  @override
  Widget build(BuildContext context) {
    return _streetViewFlutterPlatform.buildView(optionFromWidget.toMap(),
        widget.gestureRecognizers, _onPlatformViewCreated);
  }

  @override
  void didUpdateWidget(FlutterGoogleStreetView oldWidget) {
    super.didUpdateWidget(oldWidget);
    _updateOptions();
  }

  StreetViewPanoramaOptions get optionFromWidget => StreetViewPanoramaOptions(
      panoId: widget.initPanoId,
      position: widget.initPos,
      radius: widget.initRadius,
      source: widget.initSource,
      panoramaCamera: StreetViewPanoramaCamera(
          bearing: widget.initBearing,
          tilt: widget.initTilt,
          zoom: widget.initZoom,
          fov: widget.initFov),
      panningGesturesEnabled: widget.panningGesturesEnabled,
      streetNamesEnabled: widget.streetNamesEnabled,
      userNavigationEnabled: widget.userNavigationEnabled,
      zoomGesturesEnabled: widget.zoomGesturesEnabled);

  void _updateOptions() async {
    final StreetViewPanoramaOptions newOptions = optionFromWidget;
    final Map<String, dynamic> updates =
        _streetViewOptions.updatesMap(newOptions);
    if (updates.isEmpty) {
      return;
    }
    final controller = await _controller.future;
    controller.updateStreetView(updates).then((value) => print(value));
    _streetViewOptions = newOptions;
  }

  void _onPlatformViewCreated(int id) async {
    final StreetViewController controller =
        await StreetViewController.init(id, this);
    _controller.complete(controller);
    if (_onStreetViewCreated != null) _onStreetViewCreated!(controller);
  }
}
