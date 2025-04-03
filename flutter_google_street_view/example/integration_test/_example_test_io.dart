// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility that Flutter provides. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_google_street_view/flutter_google_street_view.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  final IntegrationTestWidgetsFlutterBinding binding =
      IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  // George St, Sydney
  const LatLng SYDNEY = LatLng(-33.87365, 151.20689);

  // Cole St, San Fran
  const LatLng SAN_FRAN = LatLng(37.769263, -122.450727);

  // Santorini, Greece
  const String SANTORINI = "WddsUw1geEoAAAQIt9RnsQ";

  Completer c = Completer<StreetViewController>();

  setUp(() {
    c = Completer<StreetViewController>();
  });

  testWidgets("Test key is workable.", (WidgetTester tester) async {
    Key k = GlobalKey();
    await tester.pumpWidget(Directionality(
        textDirection: TextDirection.ltr,
        child: FlutterGoogleStreetView(
          key: k,
          initPos: SAN_FRAN,
          onStreetViewCreated: (controller) {
            c.complete(controller);
          },
        )));
    await tester.pumpAndSettle();
    await c.future;
    expect(find.byKey(k), findsOneWidget);
  });

  testWidgets("Test onStreetViewCreated is workable.",
      (WidgetTester tester) async {
    await tester.pumpWidget(Directionality(
        textDirection: TextDirection.ltr,
        child: FlutterGoogleStreetView(
          initPos: SAN_FRAN,
          onStreetViewCreated: (controller) {
            c.complete(controller);
          },
        )));
    await tester.pumpAndSettle();
    StreetViewController _controller =
        await (c.future as FutureOr<StreetViewController>);
    expect(_controller, isNotNull);
  });

  //drag event is hard to trigger....
/*  testWidgets("Test onCameraChangeListener is workable.",
      (WidgetTester tester) async {
    Key k = GlobalKey();
    Completer c1 = Completer<StreetViewPanoramaCamera>();
    await tester.pumpWidget(Directionality(
        textDirection: TextDirection.ltr,
        child: FlutterGoogleStreetView(
          key: k,
          initPos: SAN_FRAN,
          onStreetViewCreated: (controller) {
            c.complete(controller);
          },
          onCameraChangeListener: (camera) {
            if (!c1.isCompleted) c1.complete(camera);
          },
        )));
    await tester.pumpAndSettle();
    await c.future;
    await Future.delayed(Duration(seconds: 3));
    await tester.drag(find.byKey(k), Offset(100, 0));
    await tester.pumpAndSettle();
    final result = await c1.future;
    expect(result, isNotNull);
  });*/

  testWidgets("Test onPanoramaChangeListener is workable.",
      (WidgetTester tester) async {
    Completer l = Completer<StreetViewPanoramaLocation>();
    await tester.pumpWidget(Directionality(
        textDirection: TextDirection.ltr,
        child: FlutterGoogleStreetView(
          initPos: SAN_FRAN,
          onStreetViewCreated: (controller) {
            c.complete(controller);
          },
          onPanoramaChangeListener: (location, e) {
            if (!l.isCompleted) l.complete(location);
          },
        )));
    await tester.pumpAndSettle();
    StreetViewController _controller =
        await (c.future as FutureOr<StreetViewController>);
    _controller.setPosition(position: SYDNEY);
    final result = await l.future;
    expect(result, isNotNull);
  });

  //onclick event is hard to trigger....
/*  testWidgets("Test onPanoramaClickListener is workable.",
      (WidgetTester tester) async {
    Completer o = Completer<StreetViewPanoramaOrientation>();
    await tester.pumpWidget(Directionality(
        textDirection: TextDirection.ltr,
        child: FlutterGoogleStreetView(
          initPos: SAN_FRAN,
          onStreetViewCreated: (controller) async {
            await tester.tapAt(Offset(100, 100));
            await tester.pumpAndSettle();
          },
          onPanoramaClickListener: (orientation) {
            if (!o.isCompleted) o.complete(orientation);
          },
        )));
    final result = await o.future;
    expect(result, isNotNull);
  });*/

/*  testWidgets("Test onPanoramaLongClickListener is workable.",
      (WidgetTester tester) async {
    Completer o = Completer<StreetViewPanoramaOrientation>();
    await tester.pumpWidget(Directionality(
        textDirection: TextDirection.ltr,
        child: FlutterGoogleStreetView(
          initPos: SAN_FRAN,
          onStreetViewCreated: (controller) async {
            c.complete(controller);
          },
          onPanoramaLongClickListener: (orientation, point) {
            o.complete(orientation);
          },
        )));
    await c.future;
    await tester.longPressAt(Offset(100, 100));
    final result = await o.future;
    expect(result, isNotNull);
  });*/

  testWidgets('Test street view init by position.',
      (WidgetTester tester) async {
    await tester.pumpWidget(Directionality(
        textDirection: TextDirection.ltr,
        child: FlutterGoogleStreetView(
          initPos: SAN_FRAN,
          onStreetViewCreated: (controller) {
            c.complete(controller);
          },
        )));
    await tester.pumpAndSettle();
    StreetViewController _controller =
        await (c.future as FutureOr<StreetViewController>);
    expect(_controller, isNotNull);
  });

  testWidgets("Test street view init position by panoId.",
      (WidgetTester tester) async {
    await tester.pumpWidget(Directionality(
        textDirection: TextDirection.ltr,
        child: FlutterGoogleStreetView(
          initPanoId: SANTORINI,
          onStreetViewCreated: (controller) {
            c.complete(controller);
          },
        )));
    await tester.pumpAndSettle();
    StreetViewController _controller =
        await (c.future as FutureOr<StreetViewController>);
    final panoId = (await _controller.getLocation())?.panoId;
    expect(panoId, isNotNull);
  });

  testWidgets(
      "Test street view init should get assertException while both initPos and initPanoId is null.",
      (WidgetTester tester) async {
    try {
      FlutterGoogleStreetView();
    } catch (e) {
      expect(e, isAssertionError);
    }
  });

  testWidgets(
      "Test street view init should get assertException while both initPos and initPanoId is feed data.",
      (WidgetTester tester) async {
    try {
      FlutterGoogleStreetView(
        initPos: SAN_FRAN,
        initPanoId: SANTORINI,
      );
    } catch (e) {
      expect(e, isAssertionError);
    }
  });

  testWidgets(
      "Test init radius is workable. Set radius to a small value cause street view can\'t find a panorama.",
      (WidgetTester tester) async {
    await tester.pumpWidget(Directionality(
        textDirection: TextDirection.ltr,
        child: FlutterGoogleStreetView(
          initPos: LatLng(25.074382, 121.590397),
          initRadius: 1,
          onStreetViewCreated: (controller) {
            c.complete(controller);
          },
        )));
    await tester.pumpAndSettle();
    StreetViewController _controller =
        await (c.future as FutureOr<StreetViewController>);
    final location = (await _controller.getLocation());
    expect(location?.position, isNull);
    expect(location?.panoId, isNull);
    expect(location?.links, isNull);
  });

  testWidgets(
      "Test init source is workable. Set location to a indoor position, and street view will search a indoor panorama by default. Set source to [outdoor] to check panorama is outdoor or not. "
      "Using LatLng(25.0780892, 121.5753234) and we can get panoId \'WnPiArhSmefF0m0WUAAElA\' if we set source to \'outdoor\'",
      (WidgetTester tester) async {
    await tester.pumpWidget(Directionality(
        textDirection: TextDirection.ltr,
        child: FlutterGoogleStreetView(
          initPos: LatLng(25.0780892, 121.5753234),
          initSource: StreetViewSource.outdoor,
          onStreetViewCreated: (controller) {
            c.complete(controller);
          },
        )));
    await tester.pumpAndSettle();
    StreetViewController _controller =
        await (c.future as FutureOr<StreetViewController>);
    final location = (await _controller.getLocation());
    expect(location?.panoId, isNotNull);
  });

  testWidgets(
      "Test init bearing is workable. Set default bearing to 30 then check it after street view is ready.",
      (WidgetTester tester) async {
    await tester.pumpWidget(Directionality(
        textDirection: TextDirection.ltr,
        child: FlutterGoogleStreetView(
          initPos: SAN_FRAN,
          initBearing: 30,
          onStreetViewCreated: (controller) {
            c.complete(controller);
          },
        )));
    await tester.pumpAndSettle();
    StreetViewController _controller =
        await (c.future as FutureOr<StreetViewController>);
    final camera = (await _controller.getPanoramaCamera());
    expect(camera.bearing?.truncateToDouble(), 30);
  });

  testWidgets(
      "Test init tilt is workable. Set default tilt to 40 then check it after street view is ready.",
      (WidgetTester tester) async {
    await tester.pumpWidget(Directionality(
        textDirection: TextDirection.ltr,
        child: FlutterGoogleStreetView(
          initPos: SAN_FRAN,
          initTilt: 40,
          onStreetViewCreated: (controller) {
            c.complete(controller);
          },
        )));
    await tester.pumpAndSettle();
    StreetViewController _controller =
        await (c.future as FutureOr<StreetViewController>);
    final camera = (await _controller.getPanoramaCamera());
    expect(camera.tilt?.truncateToDouble(), 40);
  });

  testWidgets(
      "Test init tilt should range to -90 - 90, otherwise, get assert exception.",
      (WidgetTester tester) async {
    try {
      FlutterGoogleStreetView(
        initPos: SAN_FRAN,
        initTilt: 91,
      );
    } catch (e) {
      expect(e, isAssertionError);
    }
    try {
      FlutterGoogleStreetView(
        initPos: SAN_FRAN,
        initTilt: -91,
      );
    } catch (e) {
      expect(e, isAssertionError);
    }
  });

  testWidgets(
      "Test init zoom is workable. Set default zoom to 5 then check it after street view is ready.",
      (WidgetTester tester) async {
    await tester.pumpWidget(Directionality(
        textDirection: TextDirection.ltr,
        child: FlutterGoogleStreetView(
          initPos: SAN_FRAN,
          initZoom: 5,
          onStreetViewCreated: (controller) {
            c.complete(controller);
          },
        )));
    await tester.pumpAndSettle();
    StreetViewController _controller =
        await (c.future as FutureOr<StreetViewController>);
    final camera = (await _controller.getPanoramaCamera());
    expect(camera.zoom, 5);
  });

  testWidgets(
      "Test init panningGesturesEnabled is workable. Set default panningGesturesEnabled to false then check it after street view is ready.",
      (WidgetTester tester) async {
    await tester.pumpWidget(Directionality(
        textDirection: TextDirection.ltr,
        child: FlutterGoogleStreetView(
          initPos: SAN_FRAN,
          panningGesturesEnabled: false,
          onStreetViewCreated: (controller) {
            c.complete(controller);
          },
        )));
    await tester.pumpAndSettle();
    StreetViewController _controller =
        await (c.future as FutureOr<StreetViewController>);
    final isPanningGesturesEnabled = _controller.isPanningGesturesEnabled;
    expect(isPanningGesturesEnabled, isFalse);
  });

  testWidgets(
      "Test init streetNamesEnabled is workable. Set default panningGesturesEnabled to false then check it after street view is ready.",
      (WidgetTester tester) async {
    await tester.pumpWidget(Directionality(
        textDirection: TextDirection.ltr,
        child: FlutterGoogleStreetView(
          initPos: SAN_FRAN,
          streetNamesEnabled: false,
          onStreetViewCreated: (controller) {
            c.complete(controller);
          },
        )));
    await tester.pumpAndSettle();
    StreetViewController _controller =
        await (c.future as FutureOr<StreetViewController>);
    final isStreetNamesEnabled = _controller.isStreetNamesEnabled;
    expect(isStreetNamesEnabled, isFalse);
  });

  testWidgets(
      "Test init userNavigationEnabled is workable. Set default userNavigationEnabled to false then check it after street view is ready.",
      (WidgetTester tester) async {
    await tester.pumpWidget(Directionality(
        textDirection: TextDirection.ltr,
        child: FlutterGoogleStreetView(
          initPos: SAN_FRAN,
          userNavigationEnabled: false,
          onStreetViewCreated: (controller) {
            c.complete(controller);
          },
        )));
    await tester.pumpAndSettle();
    StreetViewController _controller =
        await (c.future as FutureOr<StreetViewController>);
    final isUserNavigationEnabled = _controller.isUserNavigationEnabled;
    expect(isUserNavigationEnabled, isFalse);
  });

  testWidgets(
      "Test init zoomGesturesEnabled is workable. Set default zoomGesturesEnabled to false then check it after street view is ready.",
      (WidgetTester tester) async {
    await tester.pumpWidget(Directionality(
        textDirection: TextDirection.ltr,
        child: FlutterGoogleStreetView(
          initPos: SAN_FRAN,
          zoomGesturesEnabled: false,
          onStreetViewCreated: (controller) {
            c.complete(controller);
          },
        )));
    await tester.pumpAndSettle();
    StreetViewController _controller =
        await (c.future as FutureOr<StreetViewController>);
    final isZoomGesturesEnabled = _controller.isZoomGesturesEnabled;
    expect(isZoomGesturesEnabled, isFalse);
  });

  testWidgets("Test getPanoramaCamera is workable.",
      (WidgetTester tester) async {
    final testSetting = StreetViewPanoramaCamera(
        bearing: 15, tilt: 10, zoom: 3, fov: Platform.isIOS ? 160 : null);
    await tester.pumpWidget(Directionality(
        textDirection: TextDirection.ltr,
        child: FlutterGoogleStreetView(
          initPos: SAN_FRAN,
          initBearing: testSetting.bearing,
          initTilt: testSetting.tilt,
          initZoom: testSetting.zoom,
          initFov: testSetting.fov,
          onStreetViewCreated: (controller) {
            c.complete(controller);
          },
        )));
    await tester.pumpAndSettle();
    StreetViewController _controller = await c.future;
    await tester.pumpAndSettle();
    final tmp = await _controller.getPanoramaCamera();
    final result = StreetViewPanoramaCamera(
        bearing: tmp.bearing?.truncateToDouble(),
        tilt: tmp.tilt?.truncateToDouble(),
        zoom: tmp.zoom?.truncateToDouble(),
        fov: tmp.fov?.truncateToDouble());
    expect(result, testSetting);
  });

  testWidgets("Test animateTo is workable.", (WidgetTester tester) async {
    Completer _camera = Completer<StreetViewPanoramaCamera>();
    final testSetting = StreetViewPanoramaCamera(
        bearing: 15, tilt: 10, zoom: 1, fov: Platform.isIOS ? 160 : null);
    await tester.pumpWidget(Directionality(
        textDirection: TextDirection.ltr,
        child: FlutterGoogleStreetView(
          initPos: SAN_FRAN,
          zoomGesturesEnabled: false,
          onStreetViewCreated: (controller) {
            c.complete(controller);
          },
        )));
    await tester.pumpAndSettle();
    StreetViewController _controller =
        await (c.future as FutureOr<StreetViewController>);

    // test param duration should not be null, otherwise, getting assert exception.
    try {
      _controller.animateTo(duration: 0, camera: testSetting);
    } catch (e) {
      expect(e, isAssertionError);
    }

    // test animateTo should be work
    _controller.animateTo(duration: 1, camera: testSetting);
    await tester.pump(Duration(milliseconds: 100));
    _camera.complete(await _controller.getPanoramaCamera());
    StreetViewPanoramaCamera tmp = await _camera.future;
    StreetViewPanoramaCamera svpc = StreetViewPanoramaCamera(
        bearing: tmp.bearing?.truncateToDouble(),
        tilt: tmp.tilt?.truncateToDouble(),
        zoom: tmp.zoom?.truncateToDouble(),
        fov: tmp.fov?.truncateToDouble());
    expect(svpc == testSetting, isTrue);
  });

/*  testWidgets("Test setPosition is workable.", (WidgetTester tester) async {
    Completer _location = Completer<StreetViewPanoramaLocation?>();
    await tester.pumpWidget(Directionality(
        textDirection: TextDirection.ltr,
        child: FlutterGoogleStreetView(
          initPos: SAN_FRAN,
          onStreetViewCreated: (controller) async {
            c.complete(controller);
          },
          onPanoramaChangeListener: (location, e) {
            _location.complete(location);
          },
        )));
    tester.pumpAndSettle();
    StreetViewController _controller =
        await (c.future as FutureOr<StreetViewController>);
    // feed LatLng data only
    _controller.setPosition(position: SYDNEY);
    StreetViewPanoramaLocation? location = await _location.future;
    expect(location?.panoId, isNotNull);
    _location = Completer<StreetViewPanoramaLocation?>();

    // feed panoId data only
    _controller.setPosition(panoId: SANTORINI);
    location = await _location.future;
    expect(location?.panoId, isNotNull);
    _location = Completer<StreetViewPanoramaLocation?>();

    // test radius param, panorama should be null in this test
    _controller.setPosition(position: LatLng(25.074382, 121.590397), radius: 1);
    location = await _location.future;
    expect(location?.position, isNull);
    expect(location?.panoId, isNull);
    expect(location?.links, isNull);
    _location = Completer<StreetViewPanoramaLocation>();

    // test source param, panoId should be 'WnPiArhSmefF0m0WUAAElA' in this test
    await _controller.setPosition(
        position: LatLng(25.0780892, 121.5753234),
        source: StreetViewSource.outdoor);
    location = await _location.future;
    expect(location?.panoId, isNotNull);
    _location = Completer<StreetViewPanoramaLocation>();
  });*/

  testWidgets("Test getLocation is workable.", (WidgetTester tester) async {
    await tester.pumpWidget(Directionality(
        textDirection: TextDirection.ltr,
        child: FlutterGoogleStreetView(
          initPanoId: SANTORINI,
          onStreetViewCreated: (controller) {
            c.complete(controller);
          },
        )));
    await tester.pumpAndSettle();
    StreetViewController _controller =
        await (c.future as FutureOr<StreetViewController>);
    final location = await _controller.getLocation();
    expect(location?.panoId, isNotNull);
  });

  testWidgets("Test setPanningGesturesEnabled is workable.",
      (WidgetTester tester) async {
    await tester.pumpWidget(Directionality(
        textDirection: TextDirection.ltr,
        child: FlutterGoogleStreetView(
          initPanoId: SANTORINI,
          panningGesturesEnabled: true,
          onStreetViewCreated: (controller) {
            c.complete(controller);
          },
        )));
    await tester.pumpAndSettle();
    StreetViewController _controller =
        await (c.future as FutureOr<StreetViewController>);
    await _controller.setPanningGesturesEnabled(false);
    final result = _controller.isPanningGesturesEnabled;
    expect(result, isFalse);
  });

  testWidgets("Test setStreetNamesEnabled is workable.",
      (WidgetTester tester) async {
    await tester.pumpWidget(Directionality(
        textDirection: TextDirection.ltr,
        child: FlutterGoogleStreetView(
          initPanoId: SANTORINI,
          panningGesturesEnabled: true,
          onStreetViewCreated: (controller) {
            c.complete(controller);
          },
        )));
    await tester.pumpAndSettle();
    StreetViewController _controller =
        await (c.future as FutureOr<StreetViewController>);
    await _controller.setStreetNamesEnabled(false);
    final result = _controller.isStreetNamesEnabled;
    expect(result, isFalse);
  });

  testWidgets("Test setUserNavigationEnabled is workable.",
      (WidgetTester tester) async {
    await tester.pumpWidget(Directionality(
        textDirection: TextDirection.ltr,
        child: FlutterGoogleStreetView(
          initPanoId: SANTORINI,
          panningGesturesEnabled: true,
          onStreetViewCreated: (controller) {
            c.complete(controller);
          },
        )));
    await tester.pumpAndSettle();
    StreetViewController _controller =
        await (c.future as FutureOr<StreetViewController>);
    await _controller.setUserNavigationEnabled(false);
    final result = _controller.isUserNavigationEnabled;
    expect(result, isFalse);
  });

  testWidgets("Test setZoomGesturesEnabled is workable.",
      (WidgetTester tester) async {
    await tester.pumpWidget(Directionality(
        textDirection: TextDirection.ltr,
        child: FlutterGoogleStreetView(
          initPanoId: SANTORINI,
          panningGesturesEnabled: true,
          onStreetViewCreated: (controller) {
            c.complete(controller);
          },
        )));
    await tester.pumpAndSettle();
    StreetViewController _controller =
        await (c.future as FutureOr<StreetViewController>);
    await _controller.setZoomGesturesEnabled(false);
    final result = _controller.isZoomGesturesEnabled;
    expect(result, isFalse);
  });

  testWidgets("Test orientationToPoint is workable.",
      (WidgetTester tester) async {
    await tester.pumpWidget(Directionality(
        textDirection: TextDirection.ltr,
        child: FlutterGoogleStreetView(
          initPanoId: SANTORINI,
          panningGesturesEnabled: true,
          onStreetViewCreated: (controller) {
            c.complete(controller);
          },
        )));
    await tester.pumpAndSettle();
    StreetViewController _controller =
        await (c.future as FutureOr<StreetViewController>);
    final point = await _controller.orientationToPoint(
        StreetViewPanoramaOrientation(bearing: 45, tilt: 10));
    expect(point.x, greaterThanOrEqualTo(0));
    expect(point.y, greaterThanOrEqualTo(0));
  });

  testWidgets("Test pointToOrientation is workable.",
      (WidgetTester tester) async {
    late StreetViewController _controller;
    Key k = GlobalKey();
    await tester.pumpWidget(Directionality(
        textDirection: TextDirection.ltr,
        child: FlutterGoogleStreetView(
          key: k,
          initPanoId: SANTORINI,
          initBearing: 45,
          panningGesturesEnabled: true,
          onStreetViewCreated: (controller) {
            c.complete(controller);
          },
        )));
    await tester.pumpAndSettle();
    _controller = await (c.future as FutureOr<StreetViewController>);
    final result = await _controller.pointToOrientation(Point(0, 0));
    expect(result, isNotNull);
  });
}
