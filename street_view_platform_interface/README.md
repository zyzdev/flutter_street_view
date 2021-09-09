# street_view_platform_interface

A view platform interface for the [flutter_google_street_view][1] plugin.

# Usage

To implement a new platform-specific implementation of `flutter_google_street_view`, extend
[`StreetViewFlutterPlatform`][2] with an implementation that performs the
platform-specific behavior, and when you register your plugin, set the default
`StreetViewFlutterPlatform` by calling
`StreetViewFlutterPlatform.instance = MyPlatformStreetViewFlutter()`.

# Note on breaking changes

Strongly prefer non-breaking changes (such as adding a method to the interface)
over breaking changes for this package.

See https://flutter.dev/go/platform-interface-breaking-changes for a discussion
on why a less-clean interface is preferable to a breaking change.

[1]: ../flutter_google_street_view
[2]: lib/street_view_platform_interface.dart