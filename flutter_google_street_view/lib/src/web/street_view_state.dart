import 'dart:async';
import 'dart:html';

import 'package:flutter/cupertino.dart';
import 'package:flutter_google_street_view/flutter_google_street_view.dart';
import 'package:street_view_platform_interface/street_view_platform_interface.dart';

import '../../flutter_google_street_view_web.dart';
import 'shims/dart_ui.dart' as ui;

class StreetViewState extends State<FlutterGoogleStreetView> {
  get _onStreetViewCreated => widget.onStreetViewCreated;
  final Completer<StreetViewController> _controller =
      Completer<StreetViewController>();
  late StreetViewPanoramaOptions _streetViewOptions;
  static int _streetViewId = -1;

  static void resetStreetVIewId() => _streetViewId = -1;

  static int get webViewId => _streetViewId;
  static Map<int, FlutterGoogleStreetViewPlugin> _plugins = {};
  static Map<int, HtmlElement> _divs = {};

  late FlutterGoogleStreetViewPlugin _webPlugin;
  late HtmlElement _div;
  late int _viewId;

  String _getViewType(int viewId) => "my_street_view_$viewId";

  // The Flutter widget that contains the rendered StreetView.
  HtmlElementView? _widget;

  /// The Flutter widget that will contain the rendered Map. Used for caching.
  Widget get htmlWidget {
    if (_widget == null) {
      _widget = HtmlElementView(
        viewType: _getViewType(_viewId),
      );
    }
    return _widget!;
  }

  @override
  void initState() {
    super.initState();
    _streetViewOptions = optionFromWidget;
    _streetViewId++;
    _viewId = _streetViewId;
    _divs[_viewId] ??= DivElement()
      ..id = _getViewType(_viewId)
      ..style.width = '100%'
      ..style.height = '100%';
    _div = _divs[_viewId]!;
    ui.platformViewRegistry.registerViewFactory(
      _getViewType(_viewId),
      (int viewId) => _div,
    );
    final arg = optionFromWidget.toMap()..["viewId"] = _viewId;
    _plugins[_viewId] ??= FlutterGoogleStreetViewPlugin(arg, _div);
    _webPlugin = _plugins[_viewId]!;
    _onPlatformViewCreated(_viewId);
  }

  @override
  Widget build(BuildContext context) => htmlWidget;

  @override
  void didUpdateWidget(FlutterGoogleStreetView oldWidget) {
    super.didUpdateWidget(oldWidget);
    _updateOptions();
  }

  void dispose() {
    _plugins.remove(_viewId);
    _divs.remove(_viewId);
    _webPlugin.dispose();
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
