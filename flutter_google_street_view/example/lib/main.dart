import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_google_street_view_example/demo/street_view_panorama_events.dart';
import 'package:flutter_google_street_view_example/demo/street_view_panorama_navigation.dart';

import 'demo/street_view_panorama_in_listview.dart';
import 'demo/street_view_panorama_init.dart';
import 'demo/street_view_panorama_options.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(debugShowCheckedModeBanner: false, home: HomePage());
  }
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Street View Example'),
      ),
      body: SafeArea(
        child: ListView(
          children: [
            ListTile(
              title: Text("Street View Panorama init"),
              subtitle: Text("An example of street view init."),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => StreetViewPanoramaInitDemo()),
                );
              },
            ),
            Divider(
              height: 1,
              thickness: 1,
            ),
            ListTile(
              title: Text("Street View Panorama events"),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text.rich(
                    TextSpan(children: [
                      TextSpan(
                          text: "An example of street view event handling."),
                      TextSpan(
                          text: " Include invalid panorama event.",
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ]),
                  ),
                  SizedBox(
                    height: 8,
                  ),
                  DefaultTextStyle(
                      style: TextStyle(
                          color: Colors.redAccent, fontWeight: FontWeight.bold),
                      child: Row(
                        children: [
                          Expanded(
                              child: Text(
                            "Notice! Developers should care this demo and learn how to receive event.",
                          )),
                          Text(
                            "🙏",
                          )
                        ],
                      ))
                ],
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => StreetViewPanoramaEventsDemo()),
                );
              },
            ),
            Divider(
              height: 1,
              thickness: 1,
            ),
            ListTile(
              title: Text("Street View Panorama navigation"),
              subtitle: Text(
                  "An example to show how to use navigation related function."),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => StreetViewPanoramaNavigationDemo()),
                );
              },
            ),
            Divider(
              height: 1,
              thickness: 1,
            ),
            ListTile(
              title: Text("Street View Panorama options"),
              subtitle: Text("A example to inactive/active options."),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => StreetViewPanoramaOptionsDemo()),
                );
              },
            ),
            Divider(
              height: 1,
              thickness: 1,
            ),
            ListTile(
              title: Text("Street View Panorama in ListView"),
              subtitle: Text(
                  "A example to show how to feed touch event when street view is a child of ListView."),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => StreetViewPanoramaInListViewDemo()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
