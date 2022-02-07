import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_google_street_view/flutter_google_street_view.dart';
import 'package:flutter_google_street_view_example/const/const.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';

class StreetViewPanoramaEventsDemo extends StatefulWidget {
  StreetViewPanoramaEventsDemo({Key? key}) : super(key: key);

  @override
  _StreetViewPanoramaEventsDemoState createState() =>
      _StreetViewPanoramaEventsDemoState();
}

class _StreetViewPanoramaEventsDemoState
    extends State<StreetViewPanoramaEventsDemo> {
  StreetViewController? _controller;

  var _onPanoramaClickListenerCnt = 0;
  var _onPanoramaLongClickListenerCnt = 0;

  var _onCameraChangeListenerInfo =
      "Camera Change, bearing: N/A, tilt: N/A, zoom: N/A";
  var _onPanoramaChangeListenerInfo = "Pano Change: position: N/A, PanoId:N/A";
  var _onPanoramaClickListenerInfo = "onClick cnt:0";
  var _onPanoramaLongClickListenerInfo = "onLongClick cnt:0";

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Street View Events Demo'),
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
                onCameraChangeListener: (camera) {
                  setState(() {
                    _onCameraChangeListenerInfo =
                        "Camera Change:\nbearing: ${camera.bearing?.toStringAsFixed(2)}, tilt: ${camera.tilt?.toStringAsFixed(2)}, zoom: ${camera.zoom?.toStringAsFixed(2)} fov: ${camera.fov?.toStringAsFixed(2)}}";
                  });
                },
                onPanoramaChangeListener: (location, e) {
                  setState(() {
                    _onPanoramaChangeListenerInfo = e == null
                        ? "Pano Change:\npos:${location!.position!.latitude.toStringAsFixed(7)}, ${location.position!.longitude.toStringAsFixed(7)}\npanoId: ${location.panoId}"
                        : "Pano Change:$e";
                  });
                },
                onPanoramaClickListener: kIsWeb
                    ? null
                    : (orientation, point) {
                        _onPanoramaClickListenerCnt++;
                        setState(() {
                          _onPanoramaClickListenerInfo =
                              "onClick:\ncnt:$_onPanoramaClickListenerCnt\norientation:[tilt:${orientation.tilt}, bearing:${orientation.bearing}]\npoint:[x:${point.x}, y:${point.y}]";
                        });
                      },
                onPanoramaLongClickListener: kIsWeb
                    ? null
                    : (orientation, point) {
                        _onPanoramaLongClickListenerCnt++;
                        setState(() {
                          _onPanoramaLongClickListenerInfo =
                              "onLongClick:\ncnt:$_onPanoramaLongClickListenerCnt\norientation:[tilt:${orientation.tilt}, bearing:${orientation.bearing}]\npoint:[x:${point.x}, y:${point.y}]";
                        });
                      },
                onCloseClickListener: !kIsWeb
                    ? null
                    : () {
                        print("Receive onCloseClickListener event!");
                        Navigator.pop(context);
                      },
              ),
              if (_controller != null)
                Container(
                  alignment: Alignment.topCenter,
                  child: PointerInterceptor(
                      child: Card(
                    color: Colors.white.withOpacity(0.8),
                    child: Padding(
                      padding: EdgeInsets.all(8),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(_onCameraChangeListenerInfo),
                          SizedBox(
                            height: 8,
                          ),
                          Text(_onPanoramaChangeListenerInfo),
                          SizedBox(
                            height: 8,
                          ),
                          if (!kIsWeb) Text(_onPanoramaClickListenerInfo),
                          if (!kIsWeb)
                            SizedBox(
                              height: 8,
                            ),
                          if (!kIsWeb) Text(_onPanoramaLongClickListenerInfo),
                          _moveButton(
                            "GO TO INVALID POINT",
                            () {
                              _controller!.setPosition(position: INVALID);
                            },
                          )
                        ],
                      ),
                    ),
                  )),
                ),
            ],
          ),
        ),
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
