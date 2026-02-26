import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

/// Lightweight, local-only crash/error reporting with persistence.
///
/// Goals:
/// - Surface unexpected errors with consistent console tags.
/// - Keep an in-memory ring buffer that can be shared/exported.
/// - Optionally persist crash logs to disk for post-mortem analysis.
/// - Avoid collecting PII by not logging widget trees, user content, or
///   arbitrary metadata.
///
/// Features:
/// - Thread-safe event recording
/// - Automatic disk persistence (optional)
/// - Structured error categorization
/// - Export to JSON for bug reports
/// - Session tracking
///
/// This is intentionally *not* a remote crash analytics SDK.
class CrashReporter {
  CrashReporter._({
    int maxEvents = 100,
    bool persistToDisk = false,
  })  : _maxEvents = maxEvents,
        _persistToDisk = persistToDisk {
    _sessionId = _generateSessionId();
    _sessionStart = DateTime.now().toUtc();
    if (_persistToDisk) {
      _initDiskPersistence();
    }
  }

  static CrashReporter? _instance;

  /// Returns the singleton instance.
  ///
  /// Throws if [install] has not been called.
  static CrashReporter get instance {
    if (_instance == null) {
      throw StateError(
        'CrashReporter not initialized. Call CrashReporter.install() first.',
      );
    }
    return _instance!;
  }

  /// Returns the singleton instance, or null if not initialized.
  static CrashReporter? get instanceOrNull => _instance;

  final int _maxEvents;
  final bool _persistToDisk;
  final List<CrashEvent> _events = <CrashEvent>[];
  final Map<String, int> _errorCounts = {};
  late final String _sessionId;
  late final DateTime _sessionStart;
  File? _logFile;
  bool _diskInitialized = false;
  final StreamController<CrashEvent> _eventController =
      StreamController<CrashEvent>.broadcast();

  /// Stream of crash events for real-time monitoring.
  Stream<CrashEvent> get eventStream => _eventController.stream;

  /// Current session ID.
  String get sessionId => _sessionId;

  /// When this session started.
  DateTime get sessionStart => _sessionStart;

  /// Number of errors recorded this session.
  int get errorCount => _events.length;

  /// Number of fatal errors this session.
  int get fatalCount => _events.where((e) => e.fatal).length;

  /// Error counts by source category.
  Map<String, int> get errorCountsBySource => Map.unmodifiable(_errorCounts);

  /// Installs handlers for:
  /// - Flutter framework errors: [FlutterError.onError]
  /// - Platform dispatcher errors: [PlatformDispatcher.instance.onError]
  ///
  /// For uncaught async/zone errors use [runZonedGuarded] in `main()`.
  ///
  /// Options:
  /// - [maxEvents]: Maximum events to keep in memory (default: 100)
  /// - [persistToDisk]: Whether to save logs to disk (default: false)
  static void install({
    int maxEvents = 100,
    bool persistToDisk = false,
  }) {
    // Make install idempotent.
    _instance ??= CrashReporter._(
      maxEvents: maxEvents,
      persistToDisk: persistToDisk,
    );

    FlutterError.onError = (FlutterErrorDetails details) {
      // Keep Flutter's default formatting/behavior in debug.
      FlutterError.presentError(details);

      final Object exception = details.exception;
      final StackTrace? stack = details.stack;

      // Determine error source from context
      String source = 'flutter';
      if (details.library != null) {
        source = _categorizeFlutterError(details);
      }

      CrashReporter.instance.record(
        exception,
        stack,
        source: source,
        fatal: false,
        context: details.context?.toString(),
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

  /// Categorizes Flutter errors by their library/context.
  static String _categorizeFlutterError(FlutterErrorDetails details) {
    final library = details.library ?? '';
    final context = details.context?.toString() ?? '';

    if (library.contains('rendering')) {
      return 'flutter_rendering';
    }
    if (library.contains('widgets')) {
      return 'flutter_widgets';
    }
    if (library.contains('gesture')) {
      return 'flutter_gesture';
    }
    if (library.contains('image') || context.contains('image')) {
      return 'flutter_image';
    }
    if (library.contains('shader') || context.contains('shader')) {
      return 'shader';
    }
    return 'flutter';
  }

  /// Records an error locally.
  ///
  /// Do not pass user-provided strings or large objects here.
  void record(
    Object error,
    StackTrace? stack, {
    required String source,
    required bool fatal,
    String? context,
    Map<String, String>? tags,
  }) {
    final event = CrashEvent(
      timestamp: DateTime.now().toUtc(),
      sessionId: _sessionId,
      source: source,
      fatal: fatal,
      error: _sanitizeError(error),
      errorType: error.runtimeType.toString(),
      stack: _sanitizeStack(stack),
      context: context,
      tags: tags ?? const {},
    );

    _events.add(event);
    if (_events.length > _maxEvents) {
      _events.removeRange(0, _events.length - _maxEvents);
    }

    // Track counts by source
    _errorCounts[source] = (_errorCounts[source] ?? 0) + 1;

    // Broadcast to listeners
    _eventController.add(event);

    // Log to console
    _printEvent(event);

    // Persist to disk if enabled
    if (_persistToDisk && _diskInitialized) {
      _persistEvent(event);
    }
  }

  /// Records an informational breadcrumb (not an error).
  ///
  /// Breadcrumbs provide context for debugging but aren't errors themselves.
  void addBreadcrumb(String message, {String category = 'navigation'}) {
    record(
      BreadcrumbMarker(message),
      null,
      source: 'breadcrumb_$category',
      fatal: false,
    );
  }

  /// Returns recent crash/error events (oldest -> newest).
  List<CrashEvent> get recentEvents => List.unmodifiable(_events);

  /// Returns events matching the given filter.
  List<CrashEvent> getEventsBySource(String source) {
    return _events.where((e) => e.source == source).toList();
  }

  /// Returns only fatal events.
  List<CrashEvent> get fatalEvents => _events.where((e) => e.fatal).toList();

  /// Builds an exportable text blob for bug reports.
  ///
  /// Keep it local. Let users explicitly choose where to share it.
  String exportRecentLogs({int? maxLines}) {
    final buffer = StringBuffer();
    buffer.writeln('=== Fractal Forge Crash Report ===');
    buffer.writeln('Session: $_sessionId');
    buffer.writeln('Started: ${_sessionStart.toIso8601String()}');
    buffer.writeln('Errors: ${_events.length} ($fatalCount fatal)');
    buffer.writeln('');

    final events = maxLines != null && _events.length > maxLines
        ? _events.sublist(_events.length - maxLines)
        : _events;

    for (final event in events) {
      buffer.writeln(event.toMultilineString());
    }

    return buffer.toString();
  }

  /// Exports all events as a JSON string.
  String exportAsJson() {
    final data = {
      'session_id': _sessionId,
      'session_start': _sessionStart.toIso8601String(),
      'export_time': DateTime.now().toUtc().toIso8601String(),
      'error_counts': _errorCounts,
      'events': _events.map((e) => e.toJson()).toList(),
    };
    return const JsonEncoder.withIndent('  ').convert(data);
  }

  /// Clears all recorded events.
  void clear() {
    _events.clear();
    _errorCounts.clear();
  }

  /// Disposes resources.
  void dispose() {
    _eventController.close();
  }

  Future<void> _initDiskPersistence() async {
    if (kIsWeb) return;
    try {
      final dir = await getApplicationDocumentsDirectory();
      final logsDir = Directory('${dir.path}/crash_logs');
      if (!await logsDir.exists()) {
        await logsDir.create(recursive: true);
      }

      // Clean up old log files (keep last 5)
      final files = await logsDir.list().toList();
      final logFiles = files
          .whereType<File>()
          .where((f) => f.path.endsWith('.log'))
          .toList()
        ..sort((a, b) => b.path.compareTo(a.path));

      for (var i = 5; i < logFiles.length; i++) {
        await logFiles[i].delete();
      }

      final timestamp = DateTime.now()
          .toIso8601String()
          .replaceAll(':', '-')
          .substring(0, 19);
      _logFile = File('${logsDir.path}/crash_$timestamp.log');
      await _logFile!.writeAsString(
        '=== Session: $_sessionId ===\n',
        mode: FileMode.write,
      );
      _diskInitialized = true;
    } catch (e) {
      if (kDebugMode) debugPrint('[FF_CRASH][WARN] Failed to init disk persistence: $e');
    }
  }

  Future<void> _persistEvent(CrashEvent event) async {
    try {
      await _logFile?.writeAsString(
        '${event.toMultilineString()}\n',
        mode: FileMode.append,
      );
    } catch (e) {
      // Silently fail disk writes - we don't want to crash on crash handling
    }
  }

  void _printEvent(CrashEvent e) {
    // Skip breadcrumbs in release mode
    if (!kDebugMode && e.source.startsWith('breadcrumb_')) {
      return;
    }

    final level = e.fatal ? 'FATAL' : 'ERROR';
    if (kDebugMode) debugPrint('[FF_CRASH][$level][${e.source}] ${e.error}');
    if (kDebugMode) {
      if (e.context != null) {
        debugPrint('[FF_CRASH][CTX] ${e.context}');
      }
      if (e.stack != null && e.stack!.isNotEmpty) {
        debugPrint('[FF_CRASH][STACK] ${e.stack}');
      }
    }
  }

  String _sanitizeError(Object error) {
    // Handle special marker types
    if (error is BreadcrumbMarker) {
      return '[BREADCRUMB] ${error.message}';
    }

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

    // Android internal app data paths
    s = s.replaceAll(
      RegExp(r'/data/(data|user/\d+)/[^/\s]+'),
      '/data/.../',
    );

    return s;
  }

  String _generateSessionId() {
    final now = DateTime.now();
    final hash = now.millisecondsSinceEpoch.toRadixString(36);
    return 'FF${hash.toUpperCase()}';
  }
}

/// Marker class for breadcrumb events (not actual errors).
class BreadcrumbMarker {
  final String message;
  const BreadcrumbMarker(this.message);

  @override
  String toString() => message;
}

/// A single crash/error event with metadata.
class CrashEvent {
  final DateTime timestamp;
  final String sessionId;
  final String source;
  final bool fatal;
  final String error;
  final String errorType;
  final String? stack;
  final String? context;
  final Map<String, String> tags;

  CrashEvent({
    required this.timestamp,
    required this.sessionId,
    required this.source,
    required this.fatal,
    required this.error,
    required this.errorType,
    this.stack,
    this.context,
    this.tags = const {},
  });

  /// Creates a CrashEvent from JSON data.
  factory CrashEvent.fromJson(Map<String, dynamic> json) {
    return CrashEvent(
      timestamp: DateTime.parse(json['timestamp'] as String),
      sessionId: json['session_id'] as String,
      source: json['source'] as String,
      fatal: json['fatal'] as bool,
      error: json['error'] as String,
      errorType: json['error_type'] as String,
      stack: json['stack'] as String?,
      context: json['context'] as String?,
      tags: Map<String, String>.from(json['tags'] as Map? ?? {}),
    );
  }

  /// Converts this event to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'timestamp': timestamp.toIso8601String(),
      'session_id': sessionId,
      'source': source,
      'fatal': fatal,
      'error': error,
      'error_type': errorType,
      if (stack != null) 'stack': stack,
      if (context != null) 'context': context,
      if (tags.isNotEmpty) 'tags': tags,
    };
  }

  String toSingleLineString() {
    final t = timestamp.toIso8601String();
    final level = fatal ? 'FATAL' : 'ERROR';
    return '[$t][$level][$source] $error';
  }

  String toMultilineString() {
    final buffer = StringBuffer();
    buffer.writeln(toSingleLineString());
    if (context != null) {
      buffer.writeln('  Context: $context');
    }
    if (tags.isNotEmpty) {
      buffer.writeln('  Tags: ${tags.entries.map((e) => '${e.key}=${e.value}').join(', ')}');
    }
    if (stack != null && stack!.isNotEmpty) {
      buffer.writeln('  Stack:\n${_indentStack(stack!)}');
    }
    return buffer.toString();
  }

  String _indentStack(String stack) {
    return stack.split('\n').map((line) => '    $line').join('\n');
  }

  @override
  String toString() => toSingleLineString();
}

/// Extension for adding error recording to async operations.
extension CrashReporterExtension on Future {
  /// Wraps this future with crash reporting on error.
  Future<T> withCrashReporting<T>(String source) {
    return then<T>((value) => value as T).catchError((Object error, StackTrace stack) {
      CrashReporter.instance.record(
        error,
        stack,
        source: source,
        fatal: false,
      );
      throw error;
    });
  }
}

/// Mixin for widgets that need crash reporting context.
mixin CrashReporterMixin {
  /// Records an error from this widget.
  void recordError(
    Object error,
    StackTrace? stack, {
    required String source,
    bool fatal = false,
    String? context,
  }) {
    CrashReporter.instance.record(
      error,
      stack,
      source: source,
      fatal: fatal,
      context: context,
    );
  }

  /// Adds a navigation breadcrumb.
  void addNavigationBreadcrumb(String routeName) {
    CrashReporter.instance.addBreadcrumb(
      'Navigated to $routeName',
      category: 'navigation',
    );
  }
}
