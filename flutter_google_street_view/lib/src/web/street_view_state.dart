import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter_google_street_view/flutter_google_street_view.dart';
import 'package:flutter_google_street_view/flutter_google_street_view_web.dart';
import 'package:flutter_google_street_view/src/state/street_view_base_state.dart';

class StreetViewState extends StreetViewBaseState {
  get _onStreetViewCreated => widget.onStreetViewCreated;
  final Completer<StreetViewController> _controllerCompleter =
      Completer<StreetViewController>();
  late StreetViewController _controller;
  late StreetViewPanoramaOptions _streetViewOptions;

  late FlutterGoogleStreetViewPlugin _plugin;
  late int _viewId;

  @override
  void initState() {
    super.initState();
    _streetViewOptions = optionFromWidget;
    _plugin = FlutterGoogleStreetViewPlugin.init(_streetViewOptions.toMap());
    _viewId = _plugin.viewId;
    _onPlatformViewCreated(_viewId);
  }

  @override
  Widget build(BuildContext context) => _plugin.htmlWidget;

  @override
  void didUpdateWidget(FlutterGoogleStreetView oldWidget) {
    super.didUpdateWidget(oldWidget);
    _updateOptions();
  }

  void dispose() {
    _plugin.dispose();
    _controller.dispose();
    super.dispose();
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
      streetNamesEnabled: widget.streetNamesEnabled,
      userNavigationEnabled: widget.userNavigationEnabled,

      // Web only //
      addressControl: widget.addressControl,
      addressControlOptions: widget.addressControlOptions,
      disableDefaultUI: widget.disableDefaultUI,
      disableDoubleClickZoom: widget.disableDoubleClickZoom,
      enableCloseButton: widget.enableCloseButton,
      fullscreenControl: widget.fullscreenControl,
      fullscreenControlOptions: widget.fullscreenControlOptions,
      linksControl: widget.linksControl,
      motionTracking: widget.motionTracking,
      motionTrackingControl: widget.motionTrackingControl,
      motionTrackingControlOptions: widget.motionTrackingControlOptions,
      panControl: widget.panControl,
      scrollwheel: widget.scrollwheel,
      panControlOptions: widget.panControlOptions,
      zoomControl: widget.zoomControl,
      zoomControlOptions: widget.zoomControlOptions,
      visible: widget.visible
      // Web only
      );

  void _updateOptions() async {
    final StreetViewPanoramaOptions newOptions = optionFromWidget;
    final Map<String, dynamic> updates =
        _streetViewOptions.updatesMap(newOptions);
    if (updates.isEmpty) {
      return;
    }
    final controller = await _controllerCompleter.future;
    controller.updateStreetView(updates).then((value) => print(value));
    _streetViewOptions = newOptions;
  }

  void onMarkerTap(MarkerId markerId) {
    throw UnimplementedError();
  }

  void _onPlatformViewCreated(int id) async {
    final StreetViewController controller =
        await StreetViewController.init(id, this);
    _controller = controller;
    _controllerCompleter.complete(controller);
    if (_onStreetViewCreated != null) _onStreetViewCreated!(controller);
  }
}
