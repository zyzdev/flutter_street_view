import 'dart:async';
import 'dart:html';

import 'package:flutter_google_street_view/src/web/street_view.dart';

import 'package:flutter/services.dart';
import 'package:flutter_google_street_view/src/web/convert.dart';
import 'package:flutter_google_street_view/src/web/shims/dart_ui.dart' as ui;

import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:google_maps/google_maps.dart' as gmaps;
import 'package:kotlin_scope_function/kotlin_scope_function.dart';

class FlutterGoogleStreetViewPlugin {
  static Map<int, FlutterGoogleStreetViewPlugin> _mapPlugin = {};
  static Map<int, HtmlElement> _mapDiv = {};
  static Registrar? registrar;
  static void registerWith(Registrar registrar) {
    print("FlutterGoogleStreetViewPlugin registerWith");
    FlutterGoogleStreetViewPlugin._mapPlugin.clear();
    FlutterGoogleStreetViewPlugin._mapDiv.clear();
    StreetViewState.webViewId = -1;
    FlutterGoogleStreetViewPlugin.registrar = registrar;
    ui.platformViewRegistry.registerViewFactory(
      "my_street_view",
      (int viewId) {
        print("registerViewFactory viewId:$viewId");
        final div = _mapDiv[viewId] ??= DivElement()
          ..id = "my_street_view"
          ..style.width = '100%'
          ..style.height = '100%';
        return div;
      },
    );
  }

  FlutterGoogleStreetViewPlugin(Map<String, dynamic> arg) {
    print("FlutterGoogleStreetViewPlugin:$arg");
    final viewId = arg["viewId"];

    toStreetViewPanoramaOptions(arg).then((options) {
      streetViewPanorama = gmaps.StreetViewPanorama(_mapDiv[viewId], options);
      setupListener();
      _isStreetNamesEnabled = options.showRoadLabels ?? _isStreetNamesEnabled;
      _isUserNavigationEnabled = options.clickToGo ?? _isUserNavigationEnabled;
      _isZoomGesturesEnabled = options.zoomControl ?? _isZoomGesturesEnabled;
      streetViewInit = true;
      if (_viewReadyResult != null) {
        _viewReadyResult!.complete(_streetViewIsReady());
        _viewReadyResult = null;
      }
    });
    methodChannel = MethodChannel(
      'flutter_google_street_view_$viewId',
      const StandardMethodCodec(),
      registrar,
    );
    methodChannel.setMethodCallHandler(handleMethodCall);
  }

  factory FlutterGoogleStreetViewPlugin.create(Map<String, dynamic> arg) {
    print("FlutterGoogleStreetViewPlugin:$arg");
    final viewId = arg["viewId"];
    FlutterGoogleStreetViewPlugin plugin;
    if (_mapPlugin.containsKey(viewId)) {
      plugin = _mapPlugin[viewId]!;
    } else {
      plugin = FlutterGoogleStreetViewPlugin(arg);
      _mapPlugin[viewId] = plugin;
    }
    return plugin;
  }

  late gmaps.StreetViewPanorama streetViewPanorama;
  late MethodChannel methodChannel;
  bool streetViewInit = false;
  Completer? _viewReadyResult;
  bool _isStreetNamesEnabled = true;
  bool _isUserNavigationEnabled = true;
  bool _isZoomGesturesEnabled = true;

  void dispose() {
    final viewId =
        _mapPlugin.keys.firstWhere((viewId) => _mapPlugin[viewId] == this);
    _mapPlugin.remove(viewId);
    _mapDiv.remove(viewId);
  }

  void setupListener() {
    streetViewPanorama.onPanoChanged.listen((event) {
      //print("onPanoChanged");
    });
    streetViewPanorama.onPositionChanged.listen((event) {
      //print("onPositionChanged");
    });
    streetViewPanorama.onStatusChanged.listen((event) {
      //print("onStatusChanged");
    });
    streetViewPanorama.onPovChanged.listen((event) {
      //print("onPovChanged");
    });
    streetViewPanorama.onZoomChanged.listen((event) {
      //print("onZoomChanged");
    });
  }

  Future<dynamic> handleMethodCall(MethodCall call) async {
    print("FlutterGoogleStreetViewPlugin:" +
        call.method +
        ", streetViewInit:$streetViewInit");
    Completer result = Completer();
    final arg = call.arguments;
    switch (call.method) {
      case 'streetView#waitForStreetView':
        return streetViewInit
            ? _streetViewIsReady()
            : result.let((it) {
                _viewReadyResult = result;
                return result.future;
              });
      case "streetView#updateOptions":
        //return updateInitOptions(arg);
        return Future.value(true);
      case "streetView#animateTo":
        _animateTo(arg);
        return Future.value(true);
      case "streetView#getLocation":

      case "streetView#getPanoramaCamera":

      case "streetView#isPanningGesturesEnabled":

      case "streetView#isStreetNamesEnabled":

      case "streetView#isUserNavigationEnabled":

      case "streetView#isZoomGesturesEnabled":

      case "streetView#orientationToPoint":

      case "streetView#pointToOrientation":

      case "streetView#movePos":

      case "streetView#setPanningGesturesEnabled":

      case "streetView#setStreetNamesEnabled":

      case "streetView#setUserNavigationEnabled":

      case "streetView#setZoomGesturesEnabled":
    }
  }
}

extension FlutterGoogleStreetViewPluginE on FlutterGoogleStreetViewPlugin {
  Future<Map<String, bool>> _streetViewIsReady() => Future.value({
        "isStreetNamesEnabled": _isStreetNamesEnabled,
        "isUserNavigationEnabled": _isUserNavigationEnabled,
        "isZoomGesturesEnabled": _isZoomGesturesEnabled
      });

  Future<Map<String, dynamic>> updateInitOptions(Map arg) async {
    gmaps.StreetViewPanoramaOptions options = gmaps.StreetViewPanoramaOptions();
    await _setPosition(arg, options: options, apply: false);
    _setStreetNamesEnabled(arg, apply: false);
    _setUserNavigationEnabled(arg, apply: false);
    _setZoomGesturesEnabled(arg, apply: false);
    _animateTo(arg, apply: false);
    applay(options);
    return _streetViewIsReady();
  }

  gmaps.StreetViewPanoramaOptions _animateTo(Map arg,
      {gmaps.StreetViewPanoramaOptions? options, bool apply = true}) {
    final _options = options ?? gmaps.StreetViewPanoramaOptions();
    _options.pov = gmaps.StreetViewPov()
      ..heading = (arg['bearing'] as double?)
      ..pitch = (arg['tilt'] as double?);
    _options.zoom = arg['zoom'] as double?;

    final duration = arg["duration"] as int?;
    // TODO animation
    if (apply) {
      applay(_options);
    }
    return _options;
  }

  Future<gmaps.StreetViewPanoramaOptions> _setPosition(Map arg,
      {gmaps.StreetViewPanoramaOptions? options, bool apply = true}) async {
    final _options = options ?? gmaps.StreetViewPanoramaOptions();

    _options.pano = arg['panoId'];
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
          _options.position = response.data?.location?.latLng;
        } catch (e) {
          _options.position = location;
        }
      } else {
        _options.position = location;
      }
    }
    if (apply) applay(_options);
    return _options;
  }

  gmaps.StreetViewPanoramaOptions _setStreetNamesEnabled(Map arg,
      {gmaps.StreetViewPanoramaOptions? options, bool apply = true}) {
    final _options = options ?? gmaps.StreetViewPanoramaOptions();
    bool enable = arg['streetNamesEnabled'] ?? _isStreetNamesEnabled;
    _options.showRoadLabels = enable;
    if (apply) applay(_options);
    return _options;
  }

  gmaps.StreetViewPanoramaOptions _setUserNavigationEnabled(Map arg,
      {gmaps.StreetViewPanoramaOptions? options, bool apply = true}) {
    final _options = options ?? gmaps.StreetViewPanoramaOptions();
    bool enable = arg['userNavigationEnabled'] ?? _isUserNavigationEnabled;
    _options.clickToGo = enable;
    _options.linksControl = _options.clickToGo;
    if (apply) applay(_options);
    return _options;
  }

  gmaps.StreetViewPanoramaOptions _setZoomGesturesEnabled(Map arg,
      {gmaps.StreetViewPanoramaOptions? options, bool apply = true}) {
    final _options = options ?? gmaps.StreetViewPanoramaOptions();
    bool enable = arg['zoomGesturesEnabled'] ?? _isUserNavigationEnabled;
    _options.zoomControl = enable;
    _options.scrollwheel = enable;
    if (apply) applay(_options);
    return _options;
  }

  void applay(gmaps.StreetViewPanoramaOptions options) =>
      streetViewPanorama.options = options;
}
