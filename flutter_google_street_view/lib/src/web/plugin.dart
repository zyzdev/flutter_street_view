import 'dart:async';
import 'dart:html';
import 'dart:math';

import 'package:flutter_google_street_view/src/web/street_view.dart';
import 'package:flutter/services.dart';
import 'package:flutter_google_street_view/src/web/convert.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:google_maps/google_maps.dart' as gmaps;
import 'package:kotlin_scope_function/kotlin_scope_function.dart';

class FlutterGoogleStreetViewPlugin {
  static bool _debug = false;

  static Registrar? registrar;

  static void registerWith(Registrar registrar) {
    StreetViewState.resetStreetVIewId();
    FlutterGoogleStreetViewPlugin.registrar = registrar;
  }

  FlutterGoogleStreetViewPlugin(Map<String, dynamic> arg, HtmlElement div) {
    //print("FlutterGoogleStreetViewPlugin:$arg");
    final viewId = arg["viewId"];
    toStreetViewPanoramaOptions(arg).then((options) {
      Completer<bool> initDone = Completer();
      streetViewPanorama = gmaps.StreetViewPanorama(div, options);
      if (options.visible != null && !options.visible!) {
        //visible set to false can't trigger onStatusChanged
        //just set initDone to true
        initDone.complete(true);
      } else {
        late StreamSubscription initWatchDog;
        initWatchDog = streetViewPanorama.onStatusChanged.listen((event) {
          initWatchDog.cancel();
          initDone.complete(true);
        });
      }
      initDone.future.then((done) {
        _updateStatus(options);
        streetViewInit = true;
        setupListener();
        if (_viewReadyResult != null) {
          _viewReadyResult!.complete(_streetViewIsReady());
          _viewReadyResult = null;
        }
      });
    });
    methodChannel = MethodChannel(
      'flutter_google_street_view_$viewId',
      const StandardMethodCodec(),
      registrar,
    );
    methodChannel.setMethodCallHandler(handleMethodCall);
  }

  Type get _dTag => runtimeType;
  late gmaps.StreetViewPanorama streetViewPanorama;
  late MethodChannel methodChannel;
  Timer? _animator;
  DateTime? _animatorRunTimestame;

  bool streetViewInit = false;
  Completer? _viewReadyResult;
  bool _isStreetNamesEnabled = true;
  bool _isUserNavigationEnabled = true;
  bool _isAddressControl = true;
  bool _isDisableDefaultUI = false;
  bool _isDisableDoubleClickZoom = false;
  bool _isEnableCloseButton = true;
  bool _isFullscreenControl = true;
  bool _isLinksControl = true;
  bool _isMotionTracking = true;
  bool _isMotionTrackingControl = true;
  bool _isScrollwheel = true;
  bool _isPanControl = true;
  bool _isZoomControl = true;
  bool _isVisible = true;

  void dispose() {
    _animator?.cancel();
  }

  void setupListener() {
    streetViewPanorama.onStatusChanged.listen((event) {
      methodChannel.invokeMethod("pano#onChange", _getLocation());
    });
    streetViewPanorama.onPovChanged.listen((event) {
      methodChannel.invokeMethod("camera#onChange", _getPanoramaCamera());
    });
    streetViewPanorama.onZoomChanged.listen((event) {
      methodChannel.invokeMethod("camera#onChange", _getPanoramaCamera());
    });
    //callback fun not match doc(https://developers.google.com/maps/documentation/javascript/reference/3.44/street-view#StreetViewPanorama-Events)
    //no param is no error.
    streetViewPanorama.addListener("closeclick", () {
      methodChannel.invokeMethod("close#onClick", true);
    });
  }

  Future<dynamic> handleMethodCall(MethodCall call) async {
    final arg = call.arguments;
    debug("FlutterGoogleStreetViewPlugin:${call.method}, arg:$arg");
    Completer result = Completer();

    switch (call.method) {
      case 'streetView#waitForStreetView':
        return streetViewInit
            ? _streetViewIsReady()
            : result.let((it) {
                _viewReadyResult = result;
                return result.future;
              });
      case "streetView#updateOptions":
        return updateInitOptions(arg);
      case "streetView#animateTo":
        _animateTo(arg);
        return Future.value(true);
      case "streetView#getLocation":
        return Future.value(_getLocation());
      case "streetView#getPanoramaCamera":
        return Future.value(_getPanoramaCamera());
      case "streetView#isPanningGesturesEnabled":
        return Future.value(true);
      case "streetView#isStreetNamesEnabled":
        return Future.value(_isStreetNamesEnabled);
      case "streetView#isUserNavigationEnabled":
        return Future.value(_isUserNavigationEnabled);
      case "streetView#isZoomControl":
        return Future.value(_isZoomControl);
      case "streetView#movePos":
        _setPosition(arg);
        return Future.value();
      case "streetView#setStreetNamesEnabled":
        _setStreetNamesEnabled(arg);
        return Future.value();
      case "streetView#setUserNavigationEnabled":
        _setUserNavigationEnabled(arg);
        return Future.value();
      case "streetView#setAddressControl":
        _setAddressControl(arg);
        return Future.value();
      case "streetView#setAddressControlOptions":
        _setAddressControlOptions(arg);
        return Future.value();
      case "streetView#setDisableDefaultUI":
        _setDisableDefaultUI(arg);
        return Future.value();
      case "streetView#setDisableDoubleClickZoom":
        _setDisableDoubleClickZoom(arg);
        return Future.value();
      case "streetView#setEnableCloseButton":
        _setEnableCloseButton(arg);
        return Future.value();
      case "streetView#setFullscreenControl":
        _setFullscreenControl(arg);
        return Future.value();
      case "streetView#setFullscreenControlOptions":
        _setFullscreenControlOptions(arg);
        return Future.value();
      case "streetView#setLinksControl":
        _setLinksControl(arg);
        return Future.value();
      case "streetView#setMotionTracking":
        _setMotionTracking(arg);
        return Future.value();
      case "streetView#setMotionTrackingControl":
        _setMotionTrackingControl(arg);
        return Future.value();
      case "streetView#setMotionTrackingControlOptions":
        _setMotionTrackingControlOptions(arg);
        return Future.value();
      case "streetView#setPanControl":
        _setPanControl(arg);
        return Future.value();
      case "streetView#setPanControlOptions":
        _setPanControlOptions(arg);
        return Future.value();
      case "streetView#setScrollwheel":
        _setScrollwheel(arg);
        return Future.value();
      case "streetView#setZoomControl":
        _setZoomControl(arg);
        return Future.value();
      case "streetView#setZoomControlOptions":
        _setZoomControlOptions(arg);
        return Future.value();
      case "streetView#setVisible":
        _setVisible(arg);
        return Future.value();
    }
  }
}

extension FlutterGoogleStreetViewPluginE on FlutterGoogleStreetViewPlugin {
  void debug(String log) {
    if (FlutterGoogleStreetViewPlugin._debug) print("$_dTag: $log");
  }

  Future<Map<String, bool>> _streetViewIsReady() => Future.value({
        "isStreetNamesEnabled": _isStreetNamesEnabled,
        "isUserNavigationEnabled": _isUserNavigationEnabled,
        "isAddressControl": _isAddressControl,
        "isDisableDefaultUI": _isDisableDefaultUI,
        "isDisableDoubleClickZoom": _isDisableDoubleClickZoom,
        "isEnableCloseButton": _isEnableCloseButton,
        "isFullscreenControl": _isFullscreenControl,
        "isLinksControl": _isLinksControl,
        "isMotionTracking": _isMotionTracking,
        "isMotionTrackingControl": _isMotionTrackingControl,
        "isScrollwheel": _isScrollwheel,
        "isPanControl": _isPanControl,
        "isZoomControl": _isZoomControl,
        "isVisible": _isVisible,
      });

  Future<Map<String, dynamic>> updateInitOptions(Map arg) async {
    gmaps.StreetViewPanoramaOptions options = gmaps.StreetViewPanoramaOptions();
    options = await _setPosition(arg, options: options, toApply: false);
    options = _setStreetNamesEnabled(arg, options: options, toApply: false);
    options = _setUserNavigationEnabled(arg, options: options, toApply: false);
    options = _animateTo(arg, options: options, toApply: false);
    options = _setAddressControl(arg, options: options, toApply: false);
    options = _setAddressControlOptions(arg, options: options, toApply: false);
    options = _setDisableDefaultUI(arg, options: options, toApply: false);
    options = _setDisableDoubleClickZoom(arg, options: options, toApply: false);
    options = _setEnableCloseButton(arg, options: options, toApply: false);
    options = _setFullscreenControl(arg, options: options, toApply: false);
    options =
        _setFullscreenControlOptions(arg, options: options, toApply: false);
    options = _setLinksControl(arg, options: options, toApply: false);
    options = _setMotionTracking(arg, options: options, toApply: false);
    options = _setMotionTrackingControl(arg, options: options, toApply: false);
    options =
        _setMotionTrackingControlOptions(arg, options: options, toApply: false);
    options = _setScrollwheel(arg, options: options, toApply: false);
    options = _setPanControl(arg, options: options, toApply: false);
    options = _setPanControlOptions(arg, options: options, toApply: false);
    options = _setZoomControl(arg, options: options, toApply: false);
    options = _setZoomControlOptions(arg, options: options, toApply: false);
    options = _setVisible(arg, options: options, toApply: false);
    _apply(options);
    return _streetViewIsReady();
  }

  gmaps.StreetViewPanoramaOptions _animateTo(Map arg,
      {gmaps.StreetViewPanoramaOptions? options, bool toApply = true}) {
    final _options = options ?? gmaps.StreetViewPanoramaOptions();
    final currentPov = streetViewPanorama.pov!;
    final bearingDef = currentPov.heading ?? 0;
    final tiltDef = currentPov.pitch ?? 0;
    final zoomDef = streetViewPanorama.zoom ?? 0;
    final bearingTarget = arg['bearing'] as double? ?? bearingDef;
    final tiltTarget = arg['tilt'] as double? ?? tiltDef;
    final zoomTarget = arg['zoom'] as double? ?? zoomDef;
    _options.pov = gmaps.StreetViewPov()
      ..heading = bearingTarget
      ..pitch = tiltTarget;
    _options.zoom = (arg['zoom'] as double? ?? 0) + zoomTarget;

    if (toApply) {
      final duration = arg["duration"] as int?;
      if (duration != null) {
        if (_animator != null) {
          if (_animator!.isActive) _animator!.cancel();
          _animator = null;
        }
        _animatorRunTimestame = DateTime.now();
        final bearingDiff = bearingTarget - bearingDef;
        final tiltDiff = tiltTarget - tiltDef;
        final zoomDiff = zoomTarget - zoomDef;

        Timer.periodic(Duration(milliseconds: 15), (timer) {
          if (_animator == null) _animator = timer;
          final timeDis = DateTime.now().difference(_animatorRunTimestame!);
          final percent = min((timeDis.inMilliseconds / duration), 1);

          final bearingTarget = bearingDef + bearingDiff * percent;
          final tiltTarget = tiltDef + tiltDiff * percent;
          final zoomTarget = zoomDef + zoomDiff * percent;
          final povTarget = gmaps.StreetViewPov()
            ..heading = bearingTarget
            ..pitch = tiltTarget;
          streetViewPanorama.pov = povTarget;
          streetViewPanorama.zoom = zoomTarget;

          if (percent == 1) {
            timer.cancel();
            _animator = null;
          }
        });
      }
    }
    return _options;
  }

  Map<String, dynamic> _getLocation() =>
      streetViewPanoramaLocationToJson(streetViewPanorama);

  Map<String, dynamic> _getPanoramaCamera() =>
      streetViewPanoramaCameraToJson(streetViewPanorama);

  Future<gmaps.StreetViewPanoramaOptions> _setPosition(Map arg,
      {gmaps.StreetViewPanoramaOptions? options, bool toApply = true}) async {
    final _options = options ?? gmaps.StreetViewPanoramaOptions();

    double? raduis = arg['radius'] as double?;
    String? source = arg['source'] as String?;
    var request;
    gmaps.LatLng? location;
    String? pano;
    if (arg['position'] != null) {
      location = gmaps.LatLng(arg['position'][0], arg['position'][1]);
      final sourceTmp = source == "outdoor"
          ? gmaps.StreetViewSource.OUTDOOR
          : gmaps.StreetViewSource.DEFAULT;
      request = gmaps.StreetViewLocationRequest()
        ..location = location
        ..radius = raduis
        ..source = sourceTmp;
    } else if (arg['panoId'] != null) {
      pano = arg['panoId'];
      request = gmaps.StreetViewPanoRequest()..pano = pano;
    }
    Completer<bool> check = Completer();

    void error(gmaps.StreetViewPanoramaData? data, status) {
      final find = status == "OK";
      if (find) {
        if (location != null) {
          _options.position = data!.location!.latLng;
        } else {
          _options.pano = data!.location!.pano;
        }
      } else {
        final errorMsg = location != null
            ? "Oops..., no valid panorama found with position:${location.lat}, ${location.lng}, try to change `position`, `radius` or `source`."
            : pano != null
                ? "Oops..., no valid panorama found with panoId:$pano, try to change `panoId`."
                : "setPosition, catch unknown error.";
        methodChannel.invokeMethod("pano#onChange", {"error": errorMsg});
      }
      check.complete(find);
    }

    if (location != null && (raduis != null || source != null)) {
      gmaps.StreetViewService().getPanorama(request, error);
    } else {
      gmaps.StreetViewService().getPanorama(request, error);
    }
    await check.future;
    if (toApply) _apply(_options);
    return _options;
  }

  gmaps.StreetViewPanoramaOptions _setStreetNamesEnabled(dynamic arg,
      {gmaps.StreetViewPanoramaOptions? options, bool toApply = true}) {
    final _options = options ?? gmaps.StreetViewPanoramaOptions();
    bool enable = (arg is Map ? arg['streetNamesEnabled'] : arg) as bool? ??
        _isStreetNamesEnabled;
    _options.showRoadLabels = enable;
    if (toApply) {
      _apply(_options);
    }
    return _options;
  }

  gmaps.StreetViewPanoramaOptions _setUserNavigationEnabled(dynamic arg,
      {gmaps.StreetViewPanoramaOptions? options, bool toApply = true}) {
    final _options = options ?? gmaps.StreetViewPanoramaOptions();
    bool enable = (arg is Map ? arg['userNavigationEnabled'] : arg) as bool? ??
        _isUserNavigationEnabled;
    _options.clickToGo = enable;
    if (toApply) {
      _apply(_options);
    }
    return _options;
  }

  gmaps.StreetViewPanoramaOptions _setAddressControl(dynamic arg,
      {gmaps.StreetViewPanoramaOptions? options, bool toApply = true}) {
    final _options = options ?? gmaps.StreetViewPanoramaOptions();
    bool enable = (arg is Map ? arg['zoomGesturesEnabled'] : arg) as bool? ??
        _isAddressControl;
    _options.addressControl = enable;
    if (toApply) {
      _apply(_options);
    }
    return _options;
  }

  gmaps.StreetViewPanoramaOptions _setAddressControlOptions(dynamic arg,
      {gmaps.StreetViewPanoramaOptions? options, bool toApply = true}) {
    final _options = options ?? gmaps.StreetViewPanoramaOptions();
    _options.addressControlOptions = gmaps.StreetViewAddressControlOptions()
      ..position = toControlPosition(arg);
    if (toApply) {
      _apply(_options);
    }
    return _options;
  }

  gmaps.StreetViewPanoramaOptions _setDisableDefaultUI(dynamic arg,
      {gmaps.StreetViewPanoramaOptions? options, bool toApply = true}) {
    final _options = options ?? gmaps.StreetViewPanoramaOptions();
    bool enable = (arg is Map ? arg['disableDefaultUI'] : arg) as bool? ??
        _isDisableDefaultUI;
    _options.disableDefaultUI = enable;
    if (toApply) {
      _apply(_options);
    }
    return _options;
  }

  gmaps.StreetViewPanoramaOptions _setDisableDoubleClickZoom(dynamic arg,
      {gmaps.StreetViewPanoramaOptions? options, bool toApply = true}) {
    final _options = options ?? gmaps.StreetViewPanoramaOptions();
    bool enable = (arg is Map ? arg['disableDoubleClickZoom'] : arg) as bool? ??
        _isDisableDoubleClickZoom;
    _options.disableDoubleClickZoom = enable;
    if (toApply) {
      _apply(_options);
    }
    return _options;
  }

  gmaps.StreetViewPanoramaOptions _setEnableCloseButton(dynamic arg,
      {gmaps.StreetViewPanoramaOptions? options, bool toApply = true}) {
    final _options = options ?? gmaps.StreetViewPanoramaOptions();
    bool enable = (arg is Map ? arg['enableCloseButton'] : arg) as bool? ??
        _isEnableCloseButton;
    _options.enableCloseButton = enable;
    if (toApply) {
      _apply(_options);
    }
    return _options;
  }

  gmaps.StreetViewPanoramaOptions _setFullscreenControl(dynamic arg,
      {gmaps.StreetViewPanoramaOptions? options, bool toApply = true}) {
    final _options = options ?? gmaps.StreetViewPanoramaOptions();
    bool enable = (arg is Map ? arg['fullscreenControl'] : arg) as bool? ??
        _isFullscreenControl;
    _options.fullscreenControl = enable;
    if (toApply) {
      _apply(_options);
    }
    return _options;
  }

  gmaps.StreetViewPanoramaOptions _setFullscreenControlOptions(dynamic arg,
      {gmaps.StreetViewPanoramaOptions? options, bool toApply = true}) {
    final _options = options ?? gmaps.StreetViewPanoramaOptions();
    _options.fullscreenControlOptions = gmaps.FullscreenControlOptions()
      ..position = toControlPosition(arg);
    if (toApply) {
      _apply(_options);
    }
    return _options;
  }

  gmaps.StreetViewPanoramaOptions _setLinksControl(dynamic arg,
      {gmaps.StreetViewPanoramaOptions? options, bool toApply = true}) {
    final _options = options ?? gmaps.StreetViewPanoramaOptions();
    bool enable =
        (arg is Map ? arg['linksControl'] : arg) as bool? ?? _isLinksControl;
    _options.linksControl = enable;
    if (toApply) {
      _apply(_options);
    }
    return _options;
  }

  gmaps.StreetViewPanoramaOptions _setMotionTracking(dynamic arg,
      {gmaps.StreetViewPanoramaOptions? options, bool toApply = true}) {
    final _options = options ?? gmaps.StreetViewPanoramaOptions();
    bool enable = (arg is Map ? arg['motionTracking'] : arg) as bool? ??
        _isMotionTracking;
    _options.motionTracking = enable;
    if (toApply) {
      _apply(_options);
    }
    return _options;
  }

  gmaps.StreetViewPanoramaOptions _setMotionTrackingControl(dynamic arg,
      {gmaps.StreetViewPanoramaOptions? options, bool toApply = true}) {
    final _options = options ?? gmaps.StreetViewPanoramaOptions();
    bool enable = (arg is Map ? arg['motionTrackingControl'] : arg) as bool? ??
        _isMotionTrackingControl;
    _options.motionTrackingControl = enable;
    if (toApply) {
      _apply(_options);
    }
    return _options;
  }

  gmaps.StreetViewPanoramaOptions _setMotionTrackingControlOptions(dynamic arg,
      {gmaps.StreetViewPanoramaOptions? options, bool toApply = true}) {
    final _options = options ?? gmaps.StreetViewPanoramaOptions();
    _options.motionTrackingControlOptions = gmaps.MotionTrackingControlOptions()
      ..position = toControlPosition(arg);
    if (toApply) {
      _apply(_options);
    }
    return _options;
  }

  gmaps.StreetViewPanoramaOptions _setPanControl(dynamic arg,
      {gmaps.StreetViewPanoramaOptions? options, bool toApply = true}) {
    final _options = options ?? gmaps.StreetViewPanoramaOptions();
    bool enable =
        (arg is Map ? arg['panControl'] : arg) as bool? ?? _isPanControl;
    _options.panControl = enable;
    if (toApply) {
      _apply(_options);
    }
    return _options;
  }

  gmaps.StreetViewPanoramaOptions _setPanControlOptions(dynamic arg,
      {gmaps.StreetViewPanoramaOptions? options, bool toApply = true}) {
    final _options = options ?? gmaps.StreetViewPanoramaOptions();
    _options.panControlOptions = gmaps.PanControlOptions()
      ..position = toControlPosition(arg);
    if (toApply) {
      _apply(_options);
    }
    return _options;
  }

  gmaps.StreetViewPanoramaOptions _setScrollwheel(dynamic arg,
      {gmaps.StreetViewPanoramaOptions? options, bool toApply = true}) {
    final _options = options ?? gmaps.StreetViewPanoramaOptions();
    bool enable =
        (arg is Map ? arg['scrollwheel'] : arg) as bool? ?? _isScrollwheel;
    _options.scrollwheel = enable;
    if (toApply) {
      _apply(_options);
    }
    return _options;
  }

  gmaps.StreetViewPanoramaOptions _setZoomControl(dynamic arg,
      {gmaps.StreetViewPanoramaOptions? options, bool toApply = true}) {
    final _options = options ?? gmaps.StreetViewPanoramaOptions();
    bool enable =
        (arg is Map ? arg['zoomControl'] : arg) as bool? ?? _isZoomControl;
    _options.zoomControl = enable;
    if (toApply) {
      _apply(_options);
    }
    return _options;
  }

  gmaps.StreetViewPanoramaOptions _setZoomControlOptions(dynamic arg,
      {gmaps.StreetViewPanoramaOptions? options, bool toApply = true}) {
    final _options = options ?? gmaps.StreetViewPanoramaOptions();
    _options.zoomControlOptions = gmaps.ZoomControlOptions()
      ..position = toControlPosition(arg);
    if (toApply) {
      _apply(_options);
    }
    return _options;
  }

  gmaps.StreetViewPanoramaOptions _setVisible(dynamic arg,
      {gmaps.StreetViewPanoramaOptions? options, bool toApply = true}) {
    final _options = options ?? gmaps.StreetViewPanoramaOptions();
    bool enable =
        (arg is Map ? arg['scrollwheel'] : arg) as bool? ?? _isVisible;
    _options.visible = enable;
    if (toApply) {
      _apply(_options);
    }
    return _options;
  }

  void _apply(gmaps.StreetViewPanoramaOptions options) {
    streetViewPanorama.options = options;
    _updateStatus(options);
  }

  void _updateStatus(gmaps.StreetViewPanoramaOptions options) {
    if (options.showRoadLabels != null)
      _isStreetNamesEnabled = options.showRoadLabels!;
    if (options.clickToGo != null)
      _isUserNavigationEnabled = options.clickToGo!;
    if (options.addressControl != null)
      _isAddressControl = options.addressControl!;
    if (options.disableDefaultUI != null)
      _isDisableDefaultUI = options.disableDefaultUI!;
    if (options.disableDoubleClickZoom != null)
      _isDisableDoubleClickZoom = options.disableDoubleClickZoom!;
    if (options.enableCloseButton != null)
      _isEnableCloseButton = options.enableCloseButton!;
    if (options.fullscreenControl != null)
      _isFullscreenControl = options.fullscreenControl!;
    if (options.linksControl != null) _isLinksControl = options.linksControl!;
    if (options.motionTracking != null)
      _isMotionTracking = options.motionTracking!;
    if (options.motionTrackingControl != null)
      _isMotionTrackingControl = options.motionTrackingControl!;
    if (options.scrollwheel != null) _isScrollwheel = options.scrollwheel!;
    if (options.panControl != null) _isPanControl = options.panControl!;
    if (options.zoomControl != null) _isZoomControl = options.zoomControl!;
    if (options.visible != null) _isVisible = options.visible!;
  }
}
