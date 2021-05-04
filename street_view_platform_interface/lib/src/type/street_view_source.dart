class StreetViewSource {
  const StreetViewSource._(this._json);

  /// Default: Uses the default sources of Street View,
  /// searches will not be limited to specific sources.
  static const StreetViewSource def = StreetViewSource._('default');

  /// Limits Street View searches to outdoor collections.
  static const StreetViewSource outdoor = StreetViewSource._('outdoor');

  final dynamic _json;
  dynamic toJson() => _json;
}
