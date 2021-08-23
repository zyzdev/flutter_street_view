import 'package:flutter/material.dart';
import 'package:flutter_google_street_view/flutter_google_street_view.dart';

class StreetViewPanoramaInitDemo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Street View Init Demo'),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: SafeArea(
          child: Stack(
            children: [
              FlutterGoogleStreetView(
                /**
                 * It not necessary but you can set init position
                 * choice one of initPos or initPanoId
                 * do not feed param to both of them, or you should get assert error
                 */
                //initPos: SAN_FRAN,
                initPos: LatLng(25.0780892, 121.5753234),
                //initPanoId: SANTORINI,

                /**
                 *  It is worked while you set initPos or initPanoId.
                 *  initSource is a filter setting to filter panorama
                 */
                initSource: StreetViewSource.outdoor,

                /**
                 *  It is worked while you set initPos or initPanoId.
                 *  initBearing can set default bearing of camera.
                 */
                initBearing: 30,

                /**
                 *  It is worked while you set initPos or initPanoId.
                 *  initTilt can set default tilt of camera.
                 */
                //initTilt: 30,

                /**
                 *  It is worked while you set initPos or initPanoId.
                 *  initZoom can set default zoom of camera.
                 */
                //initZoom: 1.5,

                /**
                 *  iOS Only
                 *  It is worked while you set initPos or initPanoId.
                 *  initFov can set default fov of camera.
                 */
                //initFov: 120,

                /**
                 *  Web not support
                 *  Set street view can panning gestures or not.
                 *  default setting is true
                 */
                //panningGesturesEnabled: false,

                /**
                 *  Set street view shows street name or not.
                 *  default setting is true
                 */
                //streetNamesEnabled: true,

                /**
                 *  Set street view can allow user move to other panorama or not.
                 *  default setting is true
                 */
                //userNavigationEnabled: true,

                /**
                 *  Web not support
                 *  Set street view can zoom gestures or not.
                 *  default setting is true
                 */
                zoomGesturesEnabled: false,

                // Web only
                //addressControl: false,
                //addressControlOptions: ControlPosition.bottom_center,
                //enableCloseButton: false,
                //fullscreenControl: false,
                //fullscreenControlOptions: ControlPosition.bottom_center,
                //linksControl: false,
                //scrollwheel: false,
                //panControl: false,
                //panControlOptions: ControlPosition.bottom_center,
                //zoomControl: false,
                //zoomControlOptions: ControlPosition.bottom_center,
                //visible: false,
                //onCloseClickListener: () {},
                // Web only

                /**
                 *  To control street view after street view was initialized.
                 *  You should set [StreetViewCreatedCallback] to onStreetViewCreated.
                 *  And you can using [controller] to control street view.
                 */
                onStreetViewCreated: (StreetViewController controller) async {
                  /*controller.animateTo(
                      duration: 750,
                      camera: StreetViewPanoramaCamera(
                          bearing: 90, tilt: 30, zoom: 3));*/
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
