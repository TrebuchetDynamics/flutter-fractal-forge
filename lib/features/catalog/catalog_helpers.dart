/// Key segment normalization helper for catalog IDs.
///
/// Converts a string to a URL-safe key segment format.
String catalogKeySegment(String value) {
  return value
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
      .replaceAll(RegExp(r'^_+|_+$'), '');
}
