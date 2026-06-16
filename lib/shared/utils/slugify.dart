/// Converts an arbitrary string into a lowercase, path/key-safe slug.
///
/// Pipeline: trim → lowercase → replace disallowed runs with `_` → collapse
/// repeated `_` → strip leading/trailing separators → fall back to
/// [emptyFallback] when nothing is left.
///
/// [allowHyphen] keeps `-` as a literal (used for export filenames where
/// hyphens are valid); otherwise hyphens collapse into `_` like any other
/// separator (used for batch filenames and widget keys).
///
/// Returns [emptyFallback] (which may be `null` or `''`) when the input
/// sanitizes to empty, so callers control the empty-input contract.
String? slugify(String input,
    {bool allowHyphen = false, String? emptyFallback}) {
  final disallowed = allowHyphen ? r'[^a-z0-9_\-]+' : r'[^a-z0-9]+';
  final edges = allowHyphen ? r'^[_\-.]+|[_\-.]+$' : r'^_+|_+$';
  final slug = input
      .trim()
      .toLowerCase()
      .replaceAll(RegExp(disallowed), '_')
      .replaceAll(RegExp(r'_+'), '_')
      .replaceAll(RegExp(edges), '');
  return slug.isEmpty ? emptyFallback : slug;
}
