// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

class FakePlatformStreetView {
  FakePlatformStreetView(int? id, Map<dynamic, dynamic>? params);

  MethodChannel? channel;

  var isPanningGesturesEnabled = true;
  var isStreetNamesEnabled = true;
  var isUserNavigationEnabled = true;
  var isZoomGesturesEnabled = true;

  Future<dynamic> onMethodCall(MethodCall call) {
    print("method:${call.method}, ${call.arguments}");
    switch (call.method) {
      case 'map#update':
        return Future<void>.sync(() {});
      default:
        return Future<void>.sync(() {});
    }
  }
}

class FakePlatformViewsController {
  FakePlatformStreetView? lastCreatedView;

  Future<dynamic> fakePlatformViewsMethodHandler(MethodCall call) {
    switch (call.method) {
      case 'create':
        final Map<dynamic, dynamic> args = call.arguments;
        final Map<dynamic, dynamic>? params = _decodeParams(args['params']);
        lastCreatedView = FakePlatformStreetView(
          args['id'],
          params,
        );
        return Future<int>.sync(() => 1);
      default:
        return Future<void>.sync(() {});
    }
  }

  void reset() {
    lastCreatedView = null;
  }
}

Map<dynamic, dynamic>? _decodeParams(Uint8List paramsMessage) {
  final ByteBuffer buffer = paramsMessage.buffer;
  final ByteData messageBytes = buffer.asByteData(
    paramsMessage.offsetInBytes,
    paramsMessage.lengthInBytes,
  );
  return const StandardMessageCodec().decodeMessage(messageBytes);
}
