import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_google_street_view/flutter_google_street_view.dart';

import 'fake_street_view_controllers.dart';

void main() {
  const MethodChannel channel = MethodChannel('flutter_google_street_view');

  TestWidgetsFlutterBinding.ensureInitialized();

  final FakePlatformViewsController fakePlatformViewsController =
      FakePlatformViewsController();

  setUpAll(() {
    SystemChannels.platform_views.setMockMethodCallHandler(
        fakePlatformViewsController.fakePlatformViewsMethodHandler);
  });

  setUp(() {
    fakePlatformViewsController.reset();
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  testWidgets("Init Street View", (WidgetTester tester) async {
    StreetViewController _controller;

    Completer c = Completer<bool>();
    await tester.pumpWidget(MaterialApp(
      home: Container(
        child: FlutterGoogleStreetView(
          initPanoId: "WddsUw1geEoAAAQIt9RnsQ",
          onStreetViewCreated: (controller) {
            _controller = controller;
            c.complete(false);
            print("123123");
          },
        ),
      ),
    ));
    await tester.pumpAndSettle(Duration(seconds: 5));
    final FakePlatformStreetView? platformGoogleMap =
        fakePlatformViewsController.lastCreatedView;
  });
}
