part of google_stree_view_flutter;

/// Callback method for when the streetView is ready to be used.
///
/// Pass to [FlutterGoogleStreetView.onStreetViewCreated] to receive a [StreetViewController] when the
/// street view is created.
typedef void StreetViewCreatedCallback(StreetViewController controller);

class FlutterGoogleStreetView extends StatefulWidget {
  const FlutterGoogleStreetView(
      {Key? key,
      this.onStreetViewCreated,
      this.onCameraChangeListener,
      this.onPanoramaChangeListener,
      this.onPanoramaClickListener,
      this.onPanoramaLongClickListener,
      this.initPanoId,
      this.initPos,
      this.initRadius,
      this.initSource,
      this.initFov = 90, //iOS only
      this.initBearing,
      this.initTilt,
      this.initZoom,
      this.panningGesturesEnabled = true,
      this.streetNamesEnabled = true,
      this.userNavigationEnabled = true,
      this.zoomGesturesEnabled = true,
      this.gestureRecognizers})
      : assert((initPanoId != null) ^ (initPos != null)),
        assert((initTilt != null && initTilt >= -90 && initTilt <= 90) ||
            initTilt == null),
        super(key: key);

  /// Specifies initialization position by panoramaID.
  /// [initPos] should be null while [initPanoId] was set.
  final String? initPanoId;

  /// Specifies initialization position by latitude and longitude.
  /// [initPanoId] should be null while [initPos] was set.
  final LatLng? initPos;

  /// Specifies radius used to search for a Street View panorama
  final double? initRadius;

  /// Specifies the source filter used to search for a Street View panorama,
  /// or DEFAULT if unspecified.
  final StreetViewSource? initSource;

  /// Specifies bearing for initialization position,
  /// it worked while [initPos] or [initPanoId] was specified.
  /// Sets the direction that the camera is pointing in, in degrees clockwise from north.
  final double? initBearing;

  /// Specifies tilt for initialization position,
  /// it worked while [initPos] or [initPanoId] was specified.
  /// This value is restricted to being between -90 (directly down) and 90 (directly up).
  final double? initTilt;

  /// Specifies zoom for initialization position,
  /// it worked while [initPos] or [initPanoId] was specified.
  /// Sets the zoom level of the camera. The original zoom level is set at 0.
  /// A zoom of 1 would double the magnification. The zoom is clamped between 0 and the maximum zoom level.
  /// The maximum zoom level can vary based upon the panorama.
  /// Clamped means that any value falling outside this range will be set to the closest extreme that falls within the range.
  /// For example, a value of -1 will be set to 0.
  /// Another example: If the maximum zoom for the panorama is 19,
  /// and the value is given as 20, it will be set to 19.
  /// Note that the camera zoom need not be an integer value.
  final double? initZoom;

  /// **iOS only**
  /// The field of view (FOV) encompassed by the larger dimension (width or height) of the view in degrees at zoom 1.
  /// This is clamped to the range [1, 160] degrees, and has a default value of 90.
  /// Lower FOV values produce a zooming in effect; larger FOV values produce an fisheye effect.
  final double? initFov;

  /// Sets whether the user is able to use panning gestures
  final bool panningGesturesEnabled;

  /// Sets whether the user is able to see street names on panoramas
  final bool streetNamesEnabled;

  /// Sets whether the user is able to move to another panorama
  final bool userNavigationEnabled;

  /// Sets whether the user is able to use zoom gestures
  final bool zoomGesturesEnabled;

  /// Callback method for when the street view is ready to be used.
  ///
  /// Used to receive a [StreetViewController] for this [FlutterGoogleStreetView].
  final StreetViewCreatedCallback? onStreetViewCreated;
  final CameraChangeListener? onCameraChangeListener;
  final PanoramaChangeListener? onPanoramaChangeListener;
  final PanoramaClickListener? onPanoramaClickListener;
  final PanoramaLongClickListener? onPanoramaLongClickListener;

  /// Which gestures should be consumed by the streetView.
  ///
  /// It is possible for other gesture recognizers to be competing with the streetView on pointer
  /// events, e.g if the streetView is inside a [ListView] the [ListView] will want to handle
  /// vertical drags. The street view will claim gestures that are recognized by any of the
  /// recognizers on this list.
  ///
  /// When this set is empty or null, the street view will only handle pointer events for gestures that
  /// were not claimed by any other gesture recognizer.
  final Set<Factory<OneSequenceGestureRecognizer>>? gestureRecognizers;

  @override
  State<StatefulWidget> createState() {
    return _StreetViewState();
  }
}

class _StreetViewState extends State<FlutterGoogleStreetView> {
  get _onStreetViewCreated => widget.onStreetViewCreated;
  final Completer<StreetViewController> _controller =
      Completer<StreetViewController>();
  late StreetViewPanoramaOptions _streetViewOptions;

  @override
  void initState() {
    super.initState();
    _streetViewOptions = optionFromWidget;
  }

  @override
  Widget build(BuildContext context) {
    return _streetViewFlutterPlatform.buildView(optionFromWidget.toMap(),
        widget.gestureRecognizers, onPlatformViewCreated);
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
    controller._updateStreetView(updates).then((value) => print(value));
    _streetViewOptions = newOptions;
  }

  void onPlatformViewCreated(int id) async {
    final StreetViewController controller =
        await StreetViewController.init(id, this);
    _controller.complete(controller);
    if (widget.onStreetViewCreated != null)
      widget.onStreetViewCreated!(controller);
  }
}
