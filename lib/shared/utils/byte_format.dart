/// Formats a byte count as a human-readable size string.
///
/// Uses binary units (1 KB = 1024 B) with one decimal place for KB/MB, e.g.
/// `512 B`, `1.5 KB`, `2.0 MB`. Shared by the image and video export result
/// types so their `formattedSize` output stays consistent.
String formatByteSize(int bytes) {
  if (bytes < 1024) return '$bytes B';
  if (bytes < 1024 * 1024) {
    return '${(bytes / 1024).toStringAsFixed(1)} KB';
  }
  return '${(bytes / 1024 / 1024).toStringAsFixed(1)} MB';
}
