import 'dart:collection';
import 'dart:convert';

import 'package:flutter/foundation.dart';

/// Severity levels for log entries.
enum LogLevel { debug, info, warn, error }

/// A single timestamped log entry.
class LogEntry {
  LogEntry({
    required this.timestamp,
    required this.level,
    required this.category,
    required this.message,
    this.data,
  });

  final DateTime timestamp;
  final LogLevel level;

  /// Short tag: 'action', 'render', 'gpu', 'state', 'lifecycle', 'export', etc.
  final String category;
  final String message;

  /// Optional structured data (e.g. fractal state snapshot).
  final Map<String, Object?>? data;

  Map<String, Object?> toJson() => {
        't': timestamp.toIso8601String(),
        'level': level.name,
        'cat': category,
        'msg': message,
        if (data != null) 'data': data,
      };

  String toLogLine() {
    final ts =
        '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}:${timestamp.second.toString().padLeft(2, '0')}.${timestamp.millisecond.toString().padLeft(3, '0')}';
    final dataStr = data != null ? ' ${jsonEncode(data)}' : '';
    return '[$ts][${level.name}][$category] $message$dataStr';
  }
}

/// Global in-memory ring-buffer logger.
///
/// Keeps the last [maxEntries] log entries in memory. Export as text or JSON
/// at any time via [exportText] / [exportJson].
///
/// Usage:
/// ```dart
/// AppLogger.instance.log('action', 'User tapped zoom reset');
/// AppLogger.instance.logState('render', 'Backend switched', {'backend': 'cpu', 'reason': 'gpu_health'});
/// ```
class AppLogger extends ChangeNotifier {
  AppLogger._({this.maxEntries = 2000}); // ignore: unused_element_parameter

  static final AppLogger instance = AppLogger._();

  /// Maximum entries kept in the ring buffer.
  final int maxEntries;

  final Queue<LogEntry> _entries = Queue<LogEntry>();

  /// Read-only view of all entries (oldest first).
  List<LogEntry> get entries => _entries.toList(growable: false);

  int get length => _entries.length;

  // ── Logging methods ────────────────────────────────────────────────

  void log(String category, String message,
      {LogLevel level = LogLevel.info, Map<String, Object?>? data}) {
    final entry = LogEntry(
      timestamp: DateTime.now(),
      level: level,
      category: category,
      message: message,
      data: data,
    );
    _entries.addLast(entry);
    while (_entries.length > maxEntries) {
      _entries.removeFirst();
    }
    if (kDebugMode) {
      debugPrint(entry.toLogLine());
    }
    notifyListeners();
  }

  /// Convenience: log with structured data.
  void logState(String category, String message, Map<String, Object?> data,
      {LogLevel level = LogLevel.info}) {
    log(category, message, level: level, data: data);
  }

  void debug(String category, String message, {Map<String, Object?>? data}) =>
      log(category, message, level: LogLevel.debug, data: data);

  void info(String category, String message, {Map<String, Object?>? data}) =>
      log(category, message, level: LogLevel.info, data: data);

  void warn(String category, String message, {Map<String, Object?>? data}) =>
      log(category, message, level: LogLevel.warn, data: data);

  void error(String category, String message, {Map<String, Object?>? data}) =>
      log(category, message, level: LogLevel.error, data: data);

  // ── Export ──────────────────────────────────────────────────────────

  /// Plain-text export (one line per entry).
  String exportText({LogLevel? minLevel}) {
    final filtered = minLevel == null
        ? _entries
        : _entries.where((e) => e.level.index >= minLevel.index);
    return filtered.map((e) => e.toLogLine()).join('\n');
  }

  /// JSON array export.
  String exportJson({LogLevel? minLevel, bool pretty = true}) {
    final filtered = minLevel == null
        ? _entries
        : _entries.where((e) => e.level.index >= minLevel.index);
    final list = filtered.map((e) => e.toJson()).toList();
    return pretty
        ? const JsonEncoder.withIndent('  ').convert(list)
        : jsonEncode(list);
  }

  /// Clear all entries.
  void clear() {
    _entries.clear();
    notifyListeners();
  }
}
