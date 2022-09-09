import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter_google_street_view/flutter_google_street_view.dart';
import 'package:flutter_google_street_view/src/state/street_view_base_state.dart';

class StreetViewState extends StreetViewBaseState {
  StreetViewFlutterPlatform _streetViewFlutterPlatform =
      StreetViewFlutterPlatform.instance;

  get _onStreetViewCreated => widget.onStreetViewCreated;
  final Completer<StreetViewController> _controller =
      Completer<StreetViewController>();
  late StreetViewPanoramaOptions _streetViewOptions;
  Map<MarkerId, Marker> _markers = <MarkerId, Marker>{};
  int? _viewId;

  @override
  void initState() {
    super.initState();
    if (Platform.isIOS && widget.markers != null)
      _markers = keyByMarkerId(widget.markers!);
    _streetViewOptions = optionFromWidget;
  }

  @override
  Widget build(BuildContext context) {
    Map<String, dynamic> creationParams = optionFromWidget.toMap();
    if (Platform.isIOS && widget.markers != null) {
      putToMapIfNonNull(
          creationParams, 'markersToAdd', serializeMarkerSet(widget.markers!));
    }
    return _streetViewFlutterPlatform.buildView(
        creationParams, widget.gestureRecognizers, _onPlatformViewCreated);
  }

  @override
  void didUpdateWidget(FlutterGoogleStreetView oldWidget) {
    super.didUpdateWidget(oldWidget);
    _updateOptions();
    _updateMarkers();
  }

  void deactivate() {
    _streetViewFlutterPlatform.deactivate(_viewId!);
    super.deactivate();
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
      zoomGesturesEnabled: widget.zoomGesturesEnabled,
      markers: widget.markers);

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

  void onMarkerTap(MarkerId markerId) {
    final Marker? marker = _markers[markerId];
    if (marker == null) {
      throw Exception(
          'onMarkerTap, no marker can be found with markerId:$markerId');
    }
    final VoidCallback? onTap = marker.onTap;
    if (onTap != null) {
      onTap();
    }
  }

  void _updateMarkers() async {
    if (!Platform.isIOS) return;
    if (widget.markers == null) return;
    final StreetViewController controller = await _controller.future;
    // ignore: unawaited_futures
    controller.updateMarkers(
        MarkerUpdates.from(_markers.values.toSet(), widget.markers!));
    _markers = keyByMarkerId(widget.markers!);
  }

  void _onPlatformViewCreated(int id) async {
    _viewId = id;
    final StreetViewController controller =
        await StreetViewController.init(id, this);
    _controller.complete(controller);
    if (_onStreetViewCreated != null) _onStreetViewCreated!(controller);
  }
}
