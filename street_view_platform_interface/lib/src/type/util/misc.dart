/// A util to put [value] to json object with [key] while [value] is not null.
void putToMapIfNonNull(Map param, dynamic key, dynamic value) {
  if (value != null) param.putIfAbsent(key, () => value);
}
