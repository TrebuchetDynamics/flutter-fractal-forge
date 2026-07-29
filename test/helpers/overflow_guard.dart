import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

/// Runs [body] and asserts nothing overflowed while it ran.
///
/// Prefer this over `expect(tester.takeException(), isNull)` for layout checks,
/// for three reasons:
///
///   * A widget that overflows and is then removed — a loading row replaced
///     when its future resolves — reports itself as `DISPOSED OVERFLOWING`.
///     `takeException` does surface it, but nothing is left in the tree to
///     inspect, so the failure gives no clue where to look. The captured
///     [FlutterErrorDetails] still carries the creator chain, so the reason
///     names the offending widget and file.
///   * Several overflows collapse into a single "Multiple exceptions (N)"
///     object, which hides all but the count. These are collected separately.
///   * An unrelated exception no longer masks a layout failure, or gets
///     misreported as one; anything that is not an overflow is forwarded to the
///     normal handler.
///
/// Returns the collected overflow messages so a caller can assert something
/// more specific if needed.
Future<List<String>> expectNoOverflow(
  Future<void> Function() body, {
  String? reason,
}) async {
  final overflows = <String>[];
  final previous = FlutterError.onError;

  FlutterError.onError = (details) {
    if (details.exceptionAsString().contains('overflowed')) {
      overflows.add(_describe(details));
    } else {
      previous?.call(details);
    }
  };

  try {
    await body();
  } finally {
    FlutterError.onError = previous;
  }

  expect(overflows, isEmpty, reason: reason);
  return overflows;
}

/// The overflow message plus the widget and source location that caused it,
/// which is the part that survives the widget being disposed.
String _describe(FlutterErrorDetails details) {
  final message = details.exceptionAsString().trim();
  final dump = details.toString().split('\n');
  final creator = dump
      .skipWhile((l) => !l.contains('error-causing widget'))
      .skip(1)
      .take(2)
      .map((l) => l.trim())
      .where((l) => l.isNotEmpty)
      .join(' ');
  return creator.isEmpty ? message : '$message  <- $creator';
}
