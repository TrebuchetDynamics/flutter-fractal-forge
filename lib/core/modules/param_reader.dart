/// Safe parameter readers for uniform setters.
const double _maxSafeIntegerDouble = 9007199254740991.0;

bool _isSafeIntegerDouble(double value) {
  return value.isFinite && value.abs() <= _maxSafeIntegerDouble;
}

double readDouble(Map<String, Object> params, String key, double fallback) {
  final value = params[key];
  if (value is int) return value.toDouble();
  if (value is double && value.isFinite) return value;
  return fallback;
}

int readInt(Map<String, Object> params, String key, int fallback) {
  final value = params[key];
  if (value is int) return value;
  if (value is double && _isSafeIntegerDouble(value)) return value.round();
  return fallback;
}
