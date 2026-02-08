// (removed unused import)

import 'package:flutter/foundation.dart';

/// Lightweight, local-only crash/error reporting.
///
/// Goals:
/// - Surface unexpected errors with consistent console tags.
/// - Keep a small in-memory ring buffer that can be shared/exported.
/// - Avoid collecting PII by not logging widget trees, user content, or
///   arbitrary metadata.
///
/// This is intentionally *not* a remote crash analytics SDK.
class CrashReporter {
  CrashReporter._({int maxEvents = 50}) : _maxEvents = maxEvents;

  static CrashReporter? _instance;
  static CrashReporter get instance => _instance ??= CrashReporter._();

  final int _maxEvents;
  final List<_CrashEvent> _events = <_CrashEvent>[];

  /// Installs handlers for:
  /// - Flutter framework errors: [FlutterError.onError]
  /// - Platform dispatcher errors: [PlatformDispatcher.instance.onError]
  ///
  /// For uncaught async/zone errors use [runZonedGuarded] in `main()`.
  static void install({int maxEvents = 50}) {
    // Make install idempotent.
    _instance ??= CrashReporter._(maxEvents: maxEvents);

    FlutterError.onError = (FlutterErrorDetails details) {
      // Keep Flutter's default formatting/behavior in debug.
      FlutterError.presentError(details);

      final Object exception = details.exception;
      final StackTrace? stack = details.stack;

      CrashReporter.instance.record(
        exception,
        stack,
        source: 'flutter',
        fatal: false,
      );
    };

    // Catches errors that would otherwise be considered unhandled by the engine.
    PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
      CrashReporter.instance.record(
        error,
        stack,
        source: 'platform_dispatcher',
        fatal: true,
      );
      // Returning true tells the dispatcher we've handled it.
      return true;
    };
  }

  /// Records an error locally.
  ///
  /// Do not pass user-provided strings or large objects here.
  void record(
    Object error,
    StackTrace? stack, {
    required String source,
    required bool fatal,
  }) {
    final event = _CrashEvent(
      timestamp: DateTime.now().toUtc(),
      source: source,
      fatal: fatal,
      error: _sanitizeError(error),
      stack: _sanitizeStack(stack),
    );

    _events.add(event);
    if (_events.length > _maxEvents) {
      _events.removeRange(0, _events.length - _maxEvents);
    }

    _printEvent(event);
  }

  /// Returns recent crash/error events (oldest -> newest).
  List<String> get recentEvents =>
      List.unmodifiable(_events.map((e) => e.toSingleLineString()));

  /// Builds an exportable text blob for bug reports.
  ///
  /// Keep it local. Let users explicitly choose where to share it.
  String exportRecentLogs({int? maxLines}) {
    final lines = _events.map((e) => e.toMultilineString()).toList();
    if (maxLines == null || lines.length <= maxLines) return lines.join('\n');
    return lines.sublist(lines.length - maxLines).join('\n');
  }

  void clear() => _events.clear();

  void _printEvent(_CrashEvent e) {
    // Use debugPrint so long lines get chunked safely.
    final level = e.fatal ? 'FATAL' : 'ERROR';
    debugPrint('[FF_CRASH][$level][${e.source}] ${e.error}');
    if (e.stack != null && e.stack!.isNotEmpty) {
      debugPrint('[FF_CRASH][STACK] ${e.stack}');
    }
  }

  String _sanitizeError(Object error) {
    // Use toString(), but cap length to avoid dumping large structures.
    var s = error.toString();
    s = _stripPotentialPaths(s);
    const maxLen = 800;
    if (s.length > maxLen) {
      s = '${s.substring(0, maxLen)}…(truncated)';
    }
    return s;
  }

  String? _sanitizeStack(StackTrace? stack) {
    if (stack == null) return null;
    var s = stack.toString();
    s = _stripPotentialPaths(s);

    // Keep stack traces short: enough to diagnose, not enough to be noisy.
    final lines = s.split('\n');
    final kept = lines.take(40).toList();
    s = kept.join('\n').trim();
    return s.isEmpty ? null : s;
  }

  String _stripPotentialPaths(String input) {
    // Best-effort redaction: remove local file paths/usernames that might appear
    // in development stacks. Release stacks typically won't contain these.
    var s = input;

    // file:///Users/<name>/... or file:///home/<name>/...
    s = s.replaceAll(
      RegExp(r'file:///((Users|home)/)[^/\s]+'),
      'file:///\$1…',
    );

    // /Users/<name>/... or /home/<name>/...
    s = s.replaceAll(
      RegExp(r'/(Users|home)/[^/\s]+'),
      '/\$1/…',
    );

    return s;
  }
}

class _CrashEvent {
  final DateTime timestamp;
  final String source;
  final bool fatal;
  final String error;
  final String? stack;

  _CrashEvent({
    required this.timestamp,
    required this.source,
    required this.fatal,
    required this.error,
    required this.stack,
  });

  String toSingleLineString() {
    final t = timestamp.toIso8601String();
    final level = fatal ? 'FATAL' : 'ERROR';
    return '[$t][$level][$source] $error';
  }

  String toMultilineString() {
    final header = toSingleLineString();
    if (stack == null || stack!.isEmpty) return header;
    return '$header\n$stack\n';
  }
}
