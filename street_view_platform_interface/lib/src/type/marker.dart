// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/foundation.dart' show VoidCallback;
import 'package:meta/meta.dart' show immutable;

import 'bitmap.dart';
import 'maps_object.dart';
import 'types.dart';

/// Uniquely identifies a [Marker] among [StreetView] markers.
///
/// This does not have to be globally unique, only unique among the list.
@immutable
class MarkerId extends MapsObjectId<Marker> {
  /// Creates an immutable identifier for a [Marker].
  const MarkerId(String value) : super(value);
}

/// Marks a geographical location on the street view.
@immutable
class Marker implements MapsObject {
  /// Creates a set of marker configuration options.
  ///
  /// Default marker options.
  ///
  /// Specifies a marker that
  /// * has a default icon; [icon] is `BitmapDescriptor.defaultMarker`
  /// * is positioned at 0, 0; [position] is `LatLng(0.0, 0.0)`
  /// * is visible; [visible] is true
  /// * reports [onTap] events
  const Marker({
    required this.markerId,
    this.icon = BitmapDescriptor.defaultMarker,
    this.position = const LatLng(0.0, 0.0),
    this.visible = true,
    this.onTap,
  });

  /// Uniquely identifies a [Marker].
  final MarkerId markerId;

  @override
  MarkerId get mapsId => markerId;

  /// A description of the bitmap used to draw the marker icon.
  final BitmapDescriptor icon;

  /// Geographical location of the marker.
  final LatLng position;

  /// True if the marker is visible.
  final bool visible;

  /// Callbacks to receive tap events for markers placed on this map.
  final VoidCallback? onTap;

  /// Creates a new [Marker] object whose values are the same as this instance,
  /// unless overwritten by the specified parameters.
  Marker copyWith({
    BitmapDescriptor? iconParam,
    LatLng? positionParam,
    bool? visibleParam,
    VoidCallback? onTapParam,
  }) {
    return Marker(
      markerId: markerId,
      icon: iconParam ?? icon,
      position: positionParam ?? position,
      visible: visibleParam ?? visible,
      onTap: onTapParam ?? onTap,
    );
  }

  /// Creates a new [Marker] object whose values are the same as this instance.
  Marker clone() => copyWith();

  /// Converts this object to something serializable in JSON.
  Object toJson() {
    final Map<String, Object> json = <String, Object>{};

    void addIfPresent(String fieldName, Object? value) {
      if (value != null) {
        json[fieldName] = value;
      }
    }

    addIfPresent('markerId', markerId.value);
    addIfPresent('icon', icon.toJson());
    addIfPresent('position', position.toJson());
    addIfPresent('visible', visible);
    return json;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other.runtimeType != runtimeType) return false;
    final Marker typedOther = other as Marker;
    return markerId == typedOther.markerId &&
        icon == typedOther.icon &&
        position == typedOther.position &&
        visible == typedOther.visible;
  }

  @override
  int get hashCode => markerId.hashCode;

  @override
  String toString() {
    return 'Marker{markerId: $markerId, icon: $icon, position: $position, visible: $visible, onTap: $onTap}';
  }
}
