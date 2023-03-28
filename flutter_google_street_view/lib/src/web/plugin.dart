part of 'package:flutter_google_street_view/flutter_google_street_view_web.dart';

class FlutterGoogleStreetViewPlugin {
  static bool _debug = false;

  static Registrar? registrar;

  static void registerWith(Registrar registrar) {
    clear();
    FlutterGoogleStreetViewPlugin.registrar = registrar;
  }

  static clear() {
    resetStreetVIewId();
    _lockMap.clear();
    _plugins.clear();
    _divs.clear();
  }

  static int _streetViewId = -1;

  static void resetStreetVIewId() => _streetViewId = -1;

  static Map<int, bool> _lockMap = {};
  static Map<int, FlutterGoogleStreetViewPlugin> _plugins = {};
  static Map<int, HtmlElement> _divs = {};

  String _getViewType(int viewId) => "my_street_view_$viewId";

  // The Flutter widget that contains the rendered StreetView.
  HtmlElementView? _widget;
  late HtmlElement _div;
  late int _viewId;

  /// The view id of street view.
  int get viewId => _viewId;

  /// The Flutter widget that will contain the rendered Map. Used for caching.
  Widget get htmlWidget {
    if (_widget == null) {
      _widget = HtmlElementView(
        viewType: _getViewType(_viewId),
      );
    }
    return _widget!;
  }

  static void lock() {}

  MapsEventListener? _statusChangedListener;
  MapsEventListener? _povChangedListener;
  MapsEventListener? _zoomChangedListener;
  MapsEventListener? _closeclickListener;

  Future<void> _setup(Map<String, dynamic> arg, [bool isReuse = false]) async {
    StreetViewPanoramaOptions options;
    String? errorMsg;
    try {
      options = await toStreetViewPanoramaOptions(arg);
    } catch (exception) {
      NoStreetViewException noStreetViewException = (exception as NoStreetViewException);
      options = noStreetViewException.options..visible = false;
      errorMsg = noStreetViewException.errorMsg;
    }

    Completer<bool> initDone = Completer();
    if (!isReuse)
      _streetViewPanorama = gmaps.StreetViewPanorama(_div, options);
    else {
      //reuse _streetViewPanorama
      //set to invisible before init, then set visible after init done.
      StreetViewPanoramaOptions fakeOptions;
      try {
        fakeOptions = await toStreetViewPanoramaOptions(arg)
          ..visible = false;
      } catch (exception) {
        NoStreetViewException noStreetViewException = (exception as NoStreetViewException);
        fakeOptions = noStreetViewException.options..visible = false;
        errorMsg = noStreetViewException.errorMsg;
      }
      _streetViewPanorama.options = fakeOptions;
    }
    if (options.visible != null && !options.visible!) {
      //visible set to false can't trigger onStatusChanged
      //just set initDone to true
      initDone.complete(true);
    } else {
      late StreamSubscription initWatchDog;
      initWatchDog = _streetViewPanorama.onStatusChanged.listen((event) {
        initWatchDog.cancel();
        initDone.complete(true);
        //delay visible to avoid show pre-pano
        if (isReuse && options.visible!)
          _streetViewPanorama.options = gmaps.StreetViewPanoramaOptions()
            ..visible = options.visible;
      });
    }
    initDone.future.then((done) {
      _updateStatus(options);
      _streetViewInit = true;
      _setupListener();
      if (_viewReadyResult != null) {
        _viewReadyResult!.complete(_streetViewIsReady());
        _viewReadyResult = null;
      }
    });
    // init position or pano is invalid
    if (errorMsg != null) {
      _methodChannel.invokeMethod("pano#onChange", {"error": errorMsg});
    }
  }

  factory FlutterGoogleStreetViewPlugin.init(Map<String, dynamic> arg) =>
      _lockMap.let((it) {
        FlutterGoogleStreetViewPlugin? plugin;
        it.forEach((viewId, inUse) {
          if (!inUse && plugin == null) {
            plugin = _plugins[viewId]!.also((it) {
              it._setup(arg, true);
              it.debug("reuse plugin viewId:${it.viewId}");
            });
          }
        });
        plugin ??= FlutterGoogleStreetViewPlugin(arg);
        _lockMap[plugin!.viewId] = true;
        return plugin;
      });

  FlutterGoogleStreetViewPlugin(Map<String, dynamic> arg) {
    debug("FlutterGoogleStreetViewPlugin:$arg");
    _viewId = _streetViewId += 1;
    debug("create new plugin, viewId:$viewId");
    _div = DivElement()
      ..id = _getViewType(_viewId)
      ..style.width = '100%'
      ..style.height = '100%';
    _divs[_viewId] = _div;
    _plugins[_viewId] ??= this;
    ui.platformViewRegistry.registerViewFactory(
      _getViewType(_viewId),
      (int viewId) => _div,
    );
    _setup(arg);
    _methodChannel = MethodChannel(
      'flutter_google_street_view_$viewId',
      const StandardMethodCodec(),
      registrar,
    );
    _methodChannel.setMethodCallHandler(_handleMethodCall);
  }

  Type get _dTag => runtimeType;
  late gmaps.StreetViewPanorama _streetViewPanorama;
  late MethodChannel _methodChannel;
  Timer? _animator;
  DateTime? _animatorRunTimestame;

  bool _streetViewInit = false;
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
    _releaseListener();
    _lockMap[viewId] = false;
    _streetViewPanorama.options = gmaps.StreetViewPanoramaOptions()
      //set to invisible
      ..visible = false
      // reset control setting
      ..position = null
      ..pano = null
      ..showRoadLabels = true
      ..clickToGo = true
      ..addressControl = true
      ..disableDefaultUI = true
      ..disableDoubleClickZoom = false
      ..enableCloseButton = false
      ..fullscreenControl = true
      ..linksControl = true
      ..motionTracking = true
      ..motionTrackingControl = true
      ..scrollwheel = true
      ..panControl = true
      ..zoomControl = true
      ..pov = (gmaps.StreetViewPov()
        ..heading = 0
        ..pitch = 0)
      ..zoom = 1;
  }

  //callback fun doc(https://developers.google.com/maps/documentation/javascript/reference/3.44/street-view#StreetViewPanorama-Events)
  void _setupListener() {
    _releaseListener();
    _statusChangedListener =
        _streetViewPanorama.addListener("status_changed", () {
      _methodChannel.invokeMethod("pano#onChange", _getLocation());
    });
    _povChangedListener = _streetViewPanorama.addListener("pov_changed", () {
      _methodChannel.invokeMethod("camera#onChange", _getPanoramaCamera());
    });
    _zoomChangedListener = _streetViewPanorama.addListener("zoom_changed", () {
      _methodChannel.invokeMethod("camera#onChange", _getPanoramaCamera());
    });
    _closeclickListener = _streetViewPanorama.addListener("closeclick", () {
      _methodChannel.invokeMethod("close#onClick", true);
    });
  }

  void _releaseListener() {
    if (_statusChangedListener != null) {
      _statusChangedListener?.remove();
      _statusChangedListener = null;
    }
    if (_povChangedListener != null) {
      _povChangedListener?.remove();
      _povChangedListener = null;
    }
    if (_zoomChangedListener != null) {
      _zoomChangedListener?.remove();
      _zoomChangedListener = null;
    }
    if (_closeclickListener != null) {
      _closeclickListener?.remove();
      _closeclickListener = null;
    }
  }

  Future<dynamic> _handleMethodCall(MethodCall call) async {
    final arg = call.arguments;
    debug("FlutterGoogleStreetViewPlugin:${call.method}, arg:$arg");
    Completer result = Completer();

    switch (call.method) {
      case 'streetView#waitForStreetView':
        return _streetViewInit
            ? _streetViewIsReady()
            : result.let((it) {
                _viewReadyResult = result;
                return result.future;
              });
      case "streetView#updateOptions":
        return _updateInitOptions(arg);
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

extension FlutterGoogleStreetViewPluginExtension
    on FlutterGoogleStreetViewPlugin {
  void debug(String log) {
    if (FlutterGoogleStreetViewPlugin._debug) print("$_dTag: $log");
  }

  Future<Map<String, dynamic>> _streetViewIsReady() => Future.value({
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
        "streetViewCount": FlutterGoogleStreetViewPlugin._plugins.length,
      });

  Future<Map<String, dynamic>> _updateInitOptions(Map arg) async {
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
    final currentPov = _streetViewPanorama.pov!;
    final bearingDef = currentPov.heading ?? 0;
    final tiltDef = currentPov.pitch ?? 0;
    final zoomDef = _streetViewPanorama.zoom ?? 0;
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
          _streetViewPanorama.pov = povTarget;
          _streetViewPanorama.zoom = zoomTarget;

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
      streetViewPanoramaLocationToJson(_streetViewPanorama);

  Map<String, dynamic> _getPanoramaCamera() =>
      streetViewPanoramaCameraToJson(_streetViewPanorama);

  Future<gmaps.StreetViewPanoramaOptions> _setPosition(Map arg,
      {gmaps.StreetViewPanoramaOptions? options, bool toApply = true}) async {
    final _options = options ?? gmaps.StreetViewPanoramaOptions();

    double? raduis = arg['radius'] as double?;
    String? source = arg['source'] as String?;
    var request;
    gmaps.LatLng? location;
    String? pano;
    if (arg['panoId'] != null) {
      pano = arg['panoId'];
      request = gmaps.StreetViewPanoRequest()..pano = pano;
    } else {
      location = arg['position'] != null
          ? gmaps.LatLng(arg['position'][0], arg['position'][1])
          : _streetViewPanorama.position;
      final sourceTmp = source == "outdoor"
          ? gmaps.StreetViewSource.OUTDOOR
          : gmaps.StreetViewSource.DEFAULT;
      request = gmaps.StreetViewLocationRequest()
        ..location = location
        ..radius = raduis
        ..source = sourceTmp;
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
        _methodChannel.invokeMethod("pano#onChange", {"error": errorMsg});
      }
      check.complete(find);
    }

    gmaps.StreetViewService().getPanorama(request, error);

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
    bool enable = (arg is Map ? arg['addressControl'] : arg) as bool? ??
        _isAddressControl;
    _options.addressControl = enable;
    if (toApply) {
      _apply(_options);
    }
    return _options;
  }

  gmaps.StreetViewPanoramaOptions _setAddressControlOptions(dynamic arg,
      {gmaps.StreetViewPanoramaOptions? options, bool toApply = true}) {
    String? position =
        arg is Map ? arg['addressControlOptions'] : arg as String?;
    final _options = options ?? gmaps.StreetViewPanoramaOptions();
    _options.addressControlOptions = gmaps.StreetViewAddressControlOptions()
      ..position = toControlPosition(position);
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
    String? position =
        arg is Map ? arg['fullscreenControlOptions'] : arg as String?;
    final _options = options ?? gmaps.StreetViewPanoramaOptions();
    _options.fullscreenControlOptions = gmaps.FullscreenControlOptions()
      ..position = toControlPosition(position);
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
    String? position =
        arg is Map ? arg['motionTrackingControlOptions'] : arg as String?;
    final _options = options ?? gmaps.StreetViewPanoramaOptions();
    _options.motionTrackingControlOptions = gmaps.MotionTrackingControlOptions()
      ..position = toControlPosition(position);
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
    String? position = arg is Map ? arg['panControlOptions'] : arg as String?;
    final _options = options ?? gmaps.StreetViewPanoramaOptions();
    _options.panControlOptions = gmaps.PanControlOptions()
      ..position = toControlPosition(position);
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
    String? position = arg is Map ? arg['zoomControlOptions'] : arg as String?;
    final _options = options ?? gmaps.StreetViewPanoramaOptions();
    _options.zoomControlOptions = gmaps.ZoomControlOptions()
      ..position = toControlPosition(position);
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
    _streetViewPanorama.options = options;
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
