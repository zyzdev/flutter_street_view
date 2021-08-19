library google_stree_view_flutter;

export 'package:street_view_platform_interface/street_view_platform_interface.dart';
export 'package:flutter_google_street_view/src/street_view.dart'
    if (dart.library.html) 'src/web/street_view.dart'
    if (dart.library.io) 'src/mobile/street_view.dart';
export 'package:flutter_google_street_view/src/controller.dart';
