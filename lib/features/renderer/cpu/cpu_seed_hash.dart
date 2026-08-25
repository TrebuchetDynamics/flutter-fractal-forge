/// Deterministic 32-bit FNV-1a hash used to seed CPU fallback formulas.
///
/// The explicit mask keeps results identical across Dart VM and web integer
/// representations.
int fnv1a32(String value) {
  var hash = 0x811c9dc5;
  for (final codeUnit in value.codeUnits) {
    hash ^= codeUnit;
    hash = (hash * 0x01000193) & 0xFFFFFFFF;
  }
  return hash;
}
