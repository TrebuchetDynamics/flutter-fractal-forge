/// Safe parameter readers for uniform setters.
double readDouble(Map<String, Object> params, String key, double fallback) {
  final value = params[key];
  if (value is int) return value.toDouble();
  if (value is double && value.isFinite) return value;
  return fallback;
}

int readInt(Map<String, Object> params, String key, int fallback) {
  final value = params[key];
  if (value is int) return value;
  if (value is double && value.isFinite) return value.round();
  return fallback;
}
