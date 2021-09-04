///   ---------------
///
///   -　TL　TC　TR　-
///
///   -　LT　  　RT　-
///
///   -　LC　  　RC　-
///
///   -　LB　  　RB　-
///
///   -　BL　BC　BR　-
///
///   ---------------
class ControlPosition {
  const ControlPosition._(this._json);

  /// Elements are positioned in the center of the bottom row.
  static const ControlPosition bottom_center =
      ControlPosition._('bottom_center');

  /// Elements are positioned in the bottom left and flow towards the middle.
  /// Elements are positioned to the right of the Google logo.
  static const ControlPosition bottom_left = ControlPosition._('bottom_left');

  /// Elements are positioned in the bottom right and flow towards the middle.
  /// Elements are positioned to the left of the copyrights.
  static const ControlPosition bottom_right = ControlPosition._('bottom_right');

  /// Elements are positioned on the left, above bottom-left elements, and flow upwards.
  static const ControlPosition left_bottom = ControlPosition._('left_bottom');

  /// Elements are positioned in the center of the left side.
  static const ControlPosition left_center = ControlPosition._('left_center');

  /// Elements are positioned on the left, below top-left elements, and flow downwards.
  static const ControlPosition left_top = ControlPosition._('left_top');

  /// Elements are positioned on the right, above bottom-right elements, and flow upwards.
  static const ControlPosition right_bottom = ControlPosition._('right_bottom');

  /// Elements are positioned in the center of the right side.
  static const ControlPosition right_center = ControlPosition._('right_center');

  /// Elements are positioned on the right, below top-right elements, and flow downwards.
  static const ControlPosition right_top = ControlPosition._('right_top');

  /// Elements are positioned in the center of the top row.
  static const ControlPosition top_center = ControlPosition._('top_center');

  /// Elements are positioned in the top left and flow towards the middle.
  static const ControlPosition top_left = ControlPosition._('top_left');

  /// Elements are positioned in the top right and flow towards the middle.
  static const ControlPosition top_right = ControlPosition._('top_right');

  final dynamic _json;

  dynamic toJson() => _json;
}
