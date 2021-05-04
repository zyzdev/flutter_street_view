part of google_stree_view_flutter;

StreetViewFlutterPlatform _streetViewFlutterPlatform =
    StreetViewFlutterPlatform.instance;

class StreetViewController {
  final int viewId;
  var _isPanningGesturesEnabled = true;
  var _isStreetNamesEnabled = true;
  var _isUserNavigationEnabled = true;
  var _isZoomGesturesEnabled = true;

  final _StreetViewState _streetViewState;

  StreetViewController._(this._streetViewState,
      {@required this.viewId, dynamic initSetting})
      : assert(_streetViewFlutterPlatform != null) {
    _connectStreams(viewId);
    if (initSetting['isPanningGesturesEnabled'] != null)
      _isPanningGesturesEnabled =
          initSetting['isPanningGesturesEnabled'] as bool;
    if (initSetting['isStreetNamesEnabled'] != null)
      _isStreetNamesEnabled = initSetting['isStreetNamesEnabled'] as bool;
    if (initSetting['isUserNavigationEnabled'] != null)
      _isUserNavigationEnabled = initSetting['isUserNavigationEnabled'] as bool;
    if (initSetting['isZoomGesturesEnabled'] != null)
      _isZoomGesturesEnabled = initSetting['isZoomGesturesEnabled'] as bool;
  }

  /// Initialize control of a [FlutterGoogleStreetView] with [id].
  ///
  /// Mainly for internal use when instantiating a [StreetViewController] passed
  /// in [FlutterGoogleStreetView.onStreetViewCreated] callback.
  static Future<StreetViewController> init(
      int id, _StreetViewState _streetViewState) async {
    assert(id != null);
    final dynamic initSetting = await _streetViewFlutterPlatform.init(id);
    return StreetViewController._(_streetViewState,
        viewId: id, initSetting: initSetting);
  }

  /// Animate camera to a given position over a specified duration.
  /// [duration] unit is ms
  /// Return [Future] while the change has been started on the platform side.
  Future<void> animateTo(
      {StreetViewPanoramaCamera camera, @required int duration}) {
    assert(camera != null);
    assert(duration > 0 && duration != null);
    return _streetViewFlutterPlatform.animateTo(viewId,
        camera: camera, duration: duration);
  }

  /// Return position of current panorama and information of near panoramas
  Future<StreetViewPanoramaLocation> getLocation() {
    return _streetViewFlutterPlatform.getLocation(viewId);
  }

  /// Return camera setting, bearing, tilt and zoom.
  Future<StreetViewPanoramaCamera> getPanoramaCamera() async {
    return _streetViewFlutterPlatform.getPanoramaCamera(viewId);
  }

  /// Return street view is able to use panning gestures.
  bool get isPanningGesturesEnabled => _isPanningGesturesEnabled;

  /// Return street view is displaying street name or not.
  bool get isStreetNamesEnabled => _isStreetNamesEnabled;

  /// Return street view is able user move to another panorama.
  bool get isUserNavigationEnabled => _isUserNavigationEnabled;

  /// Return street view is able to use zoom gestures.
  bool get isZoomGesturesEnabled => _isZoomGesturesEnabled;

/*  Future<bool> isPanningGesturesEnabled() {
    return _streetViewFlutterPlatform.isPanningGesturesEnabled(viewId);
  }

  Future<bool> isStreetNamesEnabled() {
    return _streetViewFlutterPlatform.isStreetNamesEnabled(viewId);
  }

  Future<bool> isUserNavigationEnabled() {
    return _streetViewFlutterPlatform.isUserNavigationEnabled(viewId);
  }

  Future<bool> isZoomGesturesEnabled() {
    return _streetViewFlutterPlatform.isZoomGesturesEnabled(viewId);
  }*/

  /// Returns a screen location that corresponds to an orientation[StreetViewPanoramaOrientation].
  Future<Point> orientationToPoint(StreetViewPanoramaOrientation orientation) {
    return _streetViewFlutterPlatform.orientationToPoint(viewId,
        orientation: orientation);
  }

  /// Return the orientation[StreetViewPanoramaOrientation] that corresponds to a screen location.
  Future<StreetViewPanoramaOrientation> pointToOrientation(Point point) {
    return _streetViewFlutterPlatform.pointToOrientation(viewId, point: point);
  }

  /// Sets panorama by given location
  ///
  /// Return [Future] while the change has been made on the platform side.
  Future<void> setPosition(
      {LatLng position, String panoId, int radius, StreetViewSource source}) {
    assert(position != null || panoId != null);
    assert(position == null || panoId == null);
    return _streetViewFlutterPlatform.setPosition(viewId,
        position: position, panoId: panoId, radius: radius, source: source);
  }

  /// Sets street view to allow using panning gesture or not.
  ///
  /// Return [Future] while the change has been made on the platform side.
  Future<void> setPanningGesturesEnabled(bool enable) {
    if (enable == _isPanningGesturesEnabled)
      return Future.delayed(Duration.zero);
    return _streetViewFlutterPlatform
        .setPanningGesturesEnabled(viewId, enable: enable)
        .then((value) => _isPanningGesturesEnabled = enable);
  }

  /// Sets street view to display street name or not.
  ///
  /// Return [Future] while the change has been made on the platform side.
  Future<void> setStreetNamesEnabled(bool enable) {
    if (enable == _isStreetNamesEnabled) return Future.delayed(Duration.zero);
    return _streetViewFlutterPlatform
        .setStreetNamesEnabled(viewId, enable: enable)
        .then((value) => _isStreetNamesEnabled = enable);
  }

  /// Sets street view to allow moving to another panorama.
  ///
  /// Return [Future] while the change has been made on the platform side.
  Future<void> setUserNavigationEnabled(bool enable) {
    if (enable == _isUserNavigationEnabled)
      return Future.delayed(Duration.zero);
    return _streetViewFlutterPlatform
        .setUserNavigationEnabled(viewId, enable: enable)
        .then((value) => _isUserNavigationEnabled = enable);
  }

  /// Sets street view to allow using zoom gestures or not.
  ///
  /// Return [Future] while the change has been made on the platform side.
  Future<void> setZoomGesturesEnabled(bool enable) {
    if (enable == _isZoomGesturesEnabled) return Future.delayed(Duration.zero);
    return _streetViewFlutterPlatform
        .setZoomGesturesEnabled(viewId, enable: enable)
        .then((value) => _isZoomGesturesEnabled = enable);
  }

  /// Updates configuration options of the street view user interface.
  ///
  /// Change listeners are notified once the update has been made on the
  /// platform side.
  ///
  /// The returned [Future] completes after listeners have been notified.
  Future<dynamic> _updateStreetView(Map<String, dynamic> optionsUpdate) {
    assert(optionsUpdate != null);
    return _streetViewFlutterPlatform.updateStreetViewOptions(optionsUpdate,
        viewId: viewId);
  }

  void _connectStreams(int viewId) {
    if (_streetViewState.widget.onCameraChangeListener != null)
      _streetViewFlutterPlatform.onCameraChange(viewId: viewId).listen(
          (CameraChangeEvent e) =>
              _streetViewState.widget.onCameraChangeListener(e.value));

    if (_streetViewState.widget.onPanoramaChangeListener != null)
      _streetViewFlutterPlatform.onPanoramaChange(viewId: viewId).listen((e) {
        _streetViewState.widget.onPanoramaChangeListener(e.value);
      });
    if (_streetViewState.widget.onPanoramaClickListener != null)
      _streetViewFlutterPlatform.onPanoramaClick(viewId: viewId).listen((e) {
        _streetViewState.widget.onPanoramaClickListener(e.value);
      });
    if (_streetViewState.widget.onPanoramaLongClickListener != null)
      _streetViewFlutterPlatform
          .onPanoramaLongClick(viewId: viewId)
          .listen((e) {
        _streetViewState.widget.onPanoramaLongClickListener(e.value);
      });
  }
}
