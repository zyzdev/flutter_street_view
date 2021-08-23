import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_google_street_view/flutter_google_street_view.dart';
import 'package:flutter_google_street_view_example/const/const.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';

class StreetViewPanoramaNavigationDemo extends StatefulWidget {
  StreetViewPanoramaNavigationDemo({Key? key}) : super(key: key);

  @override
  _StreetViewPanoramaNavigationDemoState createState() =>
      _StreetViewPanoramaNavigationDemoState();
}

class _StreetViewPanoramaNavigationDemoState
    extends State<StreetViewPanoramaNavigationDemo> {
  StreetViewController? _controller;
  var animateFraction = 0.3;
  final int animateMaxDuration = 2000;

  int get animateDuration =>
      max((animateFraction * animateMaxDuration), 1).toInt();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Street View Navigation Demo'),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: SafeArea(
          child: Stack(
            children: [
              FlutterGoogleStreetView(
                initPos: SYDNEY,
                onStreetViewCreated: (controller) {
                  setState(() {
                    _controller = controller;
                  });
                },
              ),
              if (_controller != null)
                PointerInterceptor(child: _controlPanel())
            ],
          ),
        ),
      ),
    );
  }

  Widget _controlPanel() => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Card(
            color: Colors.white.withOpacity(0.8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height: 8,
                ),
                Row(
                  children: [
                    Expanded(
                        child: Row(
                      children: [
                        Expanded(
                          child: SizedBox(),
                        ),
                        _arrowButton(Icons.arrow_back, () {
                          _controller!.getPanoramaCamera().then((camera) {
                            final double bearing = camera.bearing! - PAN_BY_DEG;
                            final double? tilt = camera.tilt;
                            final double? zoom = camera.zoom;
                            _controller!.animateTo(
                                camera: StreetViewPanoramaCamera(
                                    bearing: bearing, tilt: tilt, zoom: zoom),
                                duration: animateDuration);
                          });
                        }),
                        SizedBox(
                          width: 8,
                        ),
                        Column(
                          children: [
                            _arrowButton(Icons.arrow_upward, () {
                              _controller!.getPanoramaCamera().then((camera) {
                                final double? bearing = camera.bearing;
                                final double tilt = camera.tilt! + PAN_BY_DEG;
                                final double? zoom = camera.zoom;
                                _controller!.animateTo(
                                    camera: StreetViewPanoramaCamera(
                                        bearing: bearing,
                                        tilt: tilt,
                                        zoom: zoom),
                                    duration: animateDuration);
                              });
                            }),
                            SizedBox(
                              height: 8,
                            ),
                            _arrowButton(Icons.arrow_downward, () {
                              _controller!.getPanoramaCamera().then((camera) {
                                final double? bearing = camera.bearing;
                                final double tilt = camera.tilt! - PAN_BY_DEG;
                                final double? zoom = camera.zoom;
                                _controller!.animateTo(
                                    camera: StreetViewPanoramaCamera(
                                        bearing: bearing,
                                        tilt: tilt,
                                        zoom: zoom),
                                    duration: animateDuration);
                              });
                            })
                          ],
                        ),
                        SizedBox(
                          width: 8,
                        ),
                        _arrowButton(Icons.arrow_forward_rounded, () {
                          _controller!.getPanoramaCamera().then((camera) {
                            final double bearing = camera.bearing! + PAN_BY_DEG;
                            final double? tilt = camera.tilt;
                            final double? zoom = camera.zoom;
                            _controller!.animateTo(
                                camera: StreetViewPanoramaCamera(
                                    bearing: bearing, tilt: tilt, zoom: zoom),
                                duration: animateDuration);
                          });
                        }),
                        Expanded(
                          child: SizedBox(),
                        ),
                      ],
                    )),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _arrowButton(Icons.add, () {
                          _controller!.getPanoramaCamera().then((camera) {
                            final double? bearing = camera.bearing;
                            final double? tilt = camera.tilt;
                            final double zoom = camera.zoom! + ZOOM_BY;
                            _controller!.animateTo(
                                camera: StreetViewPanoramaCamera(
                                    bearing: bearing, tilt: tilt, zoom: zoom),
                                duration: animateDuration);
                          });
                        }),
                        SizedBox(
                          height: 8,
                        ),
                        _arrowButton(Icons.remove, () {
                          _controller!.getPanoramaCamera().then((camera) {
                            final double? bearing = camera.bearing;
                            final double? tilt = camera.tilt;
                            final double zoom = camera.zoom! - ZOOM_BY;
                            _controller!.animateTo(
                                camera: StreetViewPanoramaCamera(
                                    bearing: bearing, tilt: tilt, zoom: zoom),
                                duration: animateDuration);
                          });
                        })
                      ],
                    ),
                    SizedBox(
                      width: 16,
                    )
                  ],
                ),
                SizedBox(
                  height: 8,
                ),
                Row(
                  children: [
                    SizedBox(
                      width: 8,
                    ),
                    Text("Anim duration"),
                    Expanded(
                        child: Slider(
                      value: animateFraction,
                      onChanged: (value) {
                        setState(() {
                          animateFraction = value;
                        });
                      },
                    ))
                  ],
                ),
              ],
            ),
          ),
          Row(
            children: [
              SizedBox(
                width: 4,
              ),
              Expanded(
                  child: _moveButton("GO TO SYDNEY", () {
                _controller!.setPosition(position: SYDNEY);
              })),
              SizedBox(
                width: 4,
              ),
              Expanded(
                child: _moveButton("GO TO SANFRAN", () {
                  _controller!.setPosition(position: SAN_FRAN);
                }),
              ),
              SizedBox(
                width: 4,
              ),
              Expanded(
                  child: _moveButton("GO TO SANTORINI", () {
                _controller!.setPosition(panoId: SANTORINI);
              })),
              SizedBox(
                width: 4,
              ),
              Expanded(
                  child: _moveButton("GO TO INVALID POINT", () {
                _controller!.setPosition(position: INVALID);
              })),
              SizedBox(
                width: 4,
              ),
            ],
          ),
        ],
      );

  Widget _arrowButton(IconData icon, GestureTapCallback onTap) {
    return Material(
      elevation: 2,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
          side: BorderSide(color: Colors.grey, width: 1)),
      child: InkWell(
        child: Padding(
          child: Icon(icon),
          padding: EdgeInsets.all(4),
        ),
        onTap: onTap,
      ),
    );
  }

  Widget _moveButton(String locationName, VoidCallback onClick) {
    return OutlinedButton(
        onPressed: onClick,
        child: Text(locationName),
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.white.withOpacity(0.8),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(4)),
              side: BorderSide(width: 1, color: Colors.grey)),
        ));
  }
}
