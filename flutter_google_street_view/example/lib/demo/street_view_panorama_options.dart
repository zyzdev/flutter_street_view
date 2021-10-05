import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_google_street_view/flutter_google_street_view.dart';
import 'package:flutter_google_street_view_example/const/const.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
import 'package:kotlin_scope_function/kotlin_scope_function.dart';

class StreetViewPanoramaOptionsDemo extends StatefulWidget {
  StreetViewPanoramaOptionsDemo({Key? key}) : super(key: key);

  @override
  _StreetViewPanoramaOptionsDemoState createState() =>
      _StreetViewPanoramaOptionsDemoState();
}

class _StreetViewPanoramaOptionsDemoState
    extends State<StreetViewPanoramaOptionsDemo> {
  StreetViewController? _controller;

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
            children: <Widget>[
              FlutterGoogleStreetView(
                initPos: SYDNEY,
                addressControlOptions:
                    kIsWeb ? ControlPosition.top_center : null,
                onStreetViewCreated: (controller) {
                  setState(() {
                    _controller = controller;
                  });
                },
              ),
              if (_controller != null)
                PointerInterceptor(child: _optionsWidget()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _optionsWidget() => Row(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              color: Colors.white.withOpacity(0.8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _option("Street Names", _controller!.isStreetNamesEnabled,
                      (newValue) {
                    _controller!.setStreetNamesEnabled(newValue!).then((value) {
                      setState(() {});
                    });
                  }),
                  _option("Navigation", _controller!.isUserNavigationEnabled,
                      (newValue) {
                    _controller!
                        .setUserNavigationEnabled(newValue!)
                        .then((value) {
                      setState(() {});
                    });
                  })
                ].also((it) {
                  if (!kIsWeb) {
                    it.addAll([
                      _option(
                          "Zoom Gestures", _controller!.isZoomGesturesEnabled,
                          (newValue) {
                        _controller!
                            .setZoomGesturesEnabled(newValue!)
                            .then((value) {
                          setState(() {});
                        });
                      }),
                      _option("Panning Gestures",
                          _controller!.isPanningGesturesEnabled, (newValue) {
                        _controller!
                            .setPanningGesturesEnabled(newValue!)
                            .then((value) {
                          setState(() {});
                        });
                      })
                    ]);
                  } else {
                    it.addAll([
                      _option("Address Control", _controller!.isAddressControl,
                          (newValue) {
                        _controller!.setAddressControl(newValue!).then((value) {
                          setState(() {});
                        });
                      }),
                      _option("Close Button", _controller!.isEnableCloseButton,
                          (newValue) {
                        _controller!
                            .setEnableCloseButton(newValue!)
                            .then((value) {
                          setState(() {});
                        });
                      }),
                      _option("Full Screen Control",
                          _controller!.isFullscreenControl, (newValue) {
                        _controller!
                            .setFullscreenControl(newValue!)
                            .then((value) {
                          setState(() {});
                        });
                      }),
                      _option("Links Control", _controller!.isLinksControl,
                          (newValue) {
                        _controller!.setLinksControl(newValue!).then((value) {
                          setState(() {});
                        });
                      }),
                      _option("Scroll Wheel", _controller!.isScrollwheel,
                          (newValue) {
                        _controller!.setScrollwheel(newValue!).then((value) {
                          setState(() {});
                        });
                      }),
                      _option("Pan Control", _controller!.isPanControl,
                          (newValue) {
                        _controller!.setPanControl(newValue!).then((value) {
                          setState(() {});
                        });
                      }),
                      _option("Zoom Control", _controller!.isZoomControl,
                          (newValue) {
                        _controller!.setZoomControl(newValue!).then((value) {
                          setState(() {});
                        });
                      }),
                      _option("Visible", _controller!.isVisible, (newValue) {
                        _controller!.setVisible(newValue!).then((value) {
                          setState(() {});
                        });
                      })
                    ]);
                  }
                }),
              ),
            ),
          ]);

  Widget _option(String title, bool check, ValueChanged<bool?>? onChange) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Checkbox(
            value: check,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            onChanged: onChange),
        Text(title),
        SizedBox(
          width: 8,
        ),
      ],
    );
  }
}
