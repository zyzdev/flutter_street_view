import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_google_street_view/flutter_google_street_view.dart';
import 'package:flutter_google_street_view_example/const/const.dart';

class StreetViewPanoramaInListViewDemo extends StatelessWidget {
  const StreetViewPanoramaInListViewDemo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Street View In ListView Demo'),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: ListView.builder(
          itemBuilder: (context, index) {
            return index != 2
                ? _emptyTile()
                : SizedBox(
                    height: 300,
                    child: FlutterGoogleStreetView(
                      initPos: SYDNEY,

                      // Web didn't need feed gestureRecognizers
                      // more detail of OneSequenceGestureRecognizer
                      // see [https://api.flutter.dev/flutter/gestures/OneSequenceGestureRecognizer-class.html]
                      gestureRecognizers: <
                          Factory<OneSequenceGestureRecognizer>>{
                        Factory<OneSequenceGestureRecognizer>(
                            () => EagerGestureRecognizer())
                      },
                    ),
                  );
          },
          itemCount: 10,
        ),
      ),
    );
  }

  Widget _emptyTile() {
    Random r = Random();
    return Container(
      height: 150,
      color:
          Color.fromARGB(0xff, r.nextInt(255), r.nextInt(255), r.nextInt(255)),
    );
  }
}
