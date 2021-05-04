import 'package:flutter/material.dart';
import 'package:flutter_google_street_view/flutter_google_street_view.dart';
import 'package:flutter_google_street_view_example/const/const.dart';

class StreetViewPanoramaOptionsDemo extends StatefulWidget {
  StreetViewPanoramaOptionsDemo({Key key}) : super(key: key);

  @override
  _StreetViewPanoramaOptionsDemoState createState() =>
      _StreetViewPanoramaOptionsDemoState();
}

class _StreetViewPanoramaOptionsDemoState
    extends State<StreetViewPanoramaOptionsDemo> {
  StreetViewController _controller;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Street View Options Demo'),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: SafeArea(
          child: Stack(
            children: [
              FlutterGoogleStreetView(
                initPos: SAN_FRAN,
                onStreetViewCreated: (controller) {
                  _controller = controller;
                  setState(() {});
                },
              ),
              if (_controller != null)
                Row(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Card(
                      color: Colors.white.withOpacity(0.8),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Checkbox(
                                  value: _controller.isStreetNamesEnabled,
                                  materialTapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                  onChanged: (newValue) {
                                    _controller
                                        .setStreetNamesEnabled(newValue)
                                        .then((value) {
                                      setState(() {});
                                    });
                                  }),
                              Text("Street Names"),
                              SizedBox(
                                width: 8,
                              ),
                            ],
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Checkbox(
                                  value: _controller.isUserNavigationEnabled,
                                  materialTapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                  onChanged: (newValue) {
                                    _controller
                                        .setUserNavigationEnabled(newValue)
                                        .then((value) {
                                      setState(() {});
                                    });
                                  }),
                              Text("Navigation"),
                              SizedBox(
                                width: 8,
                              ),
                            ],
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Checkbox(
                                  value: _controller.isZoomGesturesEnabled,
                                  materialTapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                  onChanged: (newValue) {
                                    _controller
                                        .setZoomGesturesEnabled(newValue)
                                        .then((value) {
                                      setState(() {});
                                    });
                                  }),
                              Text("Zoom Gestures"),
                              SizedBox(
                                width: 8,
                              ),
                            ],
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Checkbox(
                                  value: _controller.isPanningGesturesEnabled,
                                  materialTapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                  onChanged: (newValue) {
                                    print("newValue:$newValue");
                                    _controller
                                        .setPanningGesturesEnabled(newValue)
                                        .then((value) {
                                      setState(() {});
                                    });
                                  }),
                              Text("Panning Gestures"),
                              SizedBox(
                                width: 8,
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
