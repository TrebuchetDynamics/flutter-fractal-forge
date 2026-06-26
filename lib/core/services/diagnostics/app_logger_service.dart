import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

/// Severity levels for log entries.
enum LogLevel { debug, info, warn, error }

/// JSON-safe structured data attached to an in-memory log entry.
///
/// Logger callers often pass diagnostic objects that are useful in debug text
/// but are not directly JSON encodable (for example [DateTime], enum values,
/// non-finite doubles, or opaque objects). Snapshot at the record boundary so
/// debug log lines and exported JSON remain replayable even if callers mutate
/// their original metadata map later.
class _LogStructuredData {
  const _LogStructuredData._();

  static Map<String, Object?>? snapshot(Map<String, Object?>? data) {
    if (data == null) return null;
    return Map<String, Object?>.unmodifiable({
      for (final entry in data.entries) entry.key: snapshotValue(entry.value),
    });
  }

  static Object? snapshotValue(Object? value) {
    if (value == null || value is String || value is bool) return value;
    if (value is num) return value.isFinite ? value : value.toString();
    if (value is DateTime) return value.toIso8601String();
    if (value is Enum) return value.name;
    if (value is List) {
      return List<Object?>.unmodifiable(value.map(snapshotValue));
    }
    if (value is Map) {
      return Map<String, Object?>.unmodifiable({
        for (final entry in value.entries)
          entry.key.toString(): snapshotValue(entry.value),
      });
    }
    return value.toString();
  }
}

/// A single timestamped log entry.
class LogEntry {
  LogEntry({
    required this.timestamp,
    required this.level,
    required this.category,
    required this.message,
    Map<String, Object?>? data,
  }) : data = _LogStructuredData.snapshot(data);

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

  /// Serialises to a JSONL line using the on-disk schema.
  Map<String, Object?> toDiskJson() => {
        'timestamp': timestamp.toIso8601String(),
        'level': level.name,
        'tag': category,
        'message': message,
      };

  /// Deserialises from the on-disk JSONL schema.
  factory LogEntry.fromDiskJson(Map<String, dynamic> json) {
    return LogEntry(
      timestamp: DateTime.parse(json['timestamp'] as String),
      level: LogLevel.values.firstWhere(
        (l) => l.name == (json['level'] as String),
        orElse: () => LogLevel.info,
      ),
      category: json['tag'] as String? ?? '',
      message: json['message'] as String? ?? '',
    );
  }

  String toLogLine() {
    final ts =
        '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}:${timestamp.second.toString().padLeft(2, '0')}.${timestamp.millisecond.toString().padLeft(3, '0')}';
    final dataStr = data != null ? ' ${jsonEncode(data)}' : '';
    return '[$ts][${level.name}][$category] $message$dataStr';
  }
}

/// Replayable result of rotating an on-disk JSONL log file.
@immutable
class LogDiskRotationPlan {
  const LogDiskRotationPlan({
    required this.keptLines,
    required this.nonEmptyLineCount,
  });

  /// Non-empty JSONL lines kept in chronological order.
  final List<String> keptLines;

  /// Count of non-empty candidate lines before rotation.
  final int nonEmptyLineCount;

  bool get shouldRewrite => keptLines.length < nonEmptyLineCount;

  int get keptUtf8Bytes => keptLines.fold<int>(
        0,
        (total, line) => total + utf8.encode(line).length + 1,
      );

  String serializeKeptLines() => keptLines.map((line) => '$line\n').join();
}

/// Pure on-disk log rotation policy.
///
/// Keeps the most recent non-empty lines as one chronological suffix constrained
/// by entry count and byte budget. Exposing the selection makes dropped-line and
/// byte-budget assumptions testable without touching platform cache files.
class LogDiskRotationPolicy {
  const LogDiskRotationPolicy._();

  static LogDiskRotationPlan plan({
    required List<String> lines,
    required int maxEntries,
    required int maxBytes,
  }) {
    assert(maxEntries > 0, 'maxEntries must be positive');
    assert(maxBytes > 0, 'maxBytes must be positive');

    final nonEmptyLineCount =
        lines.where((line) => line.trim().isNotEmpty).length;
    final keptReversed = <String>[];
    var totalBytes = 0;

    for (final line in lines.reversed) {
      if (line.trim().isEmpty) continue;
      if (keptReversed.length >= maxEntries) break;
      final lineBytes = utf8.encode(line).length + 1; // +1 for newline
      if (totalBytes + lineBytes > maxBytes) break;
      totalBytes += lineBytes;
      keptReversed.add(line);
    }

    return LogDiskRotationPlan(
      keptLines: keptReversed.reversed.toList(growable: false),
      nonEmptyLineCount: nonEmptyLineCount,
    );
  }
}

/// Global in-memory ring-buffer logger with optional persistent JSONL storage.
///
/// Keeps the last [maxEntries] log entries in memory. Export as text or JSON
/// at any time via [exportText] / [exportJson].
///
/// Call [init] once at app startup to enable persistence:
/// ```dart
/// await AppLogger.instance.init();
/// ```
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

  /// Maximum entries persisted to disk (rotation threshold).
  static const int _maxDiskEntries = 5000;

  /// Approximate size cap for the on-disk file (~2 MB).
  static const int _maxDiskBytes = 2 * 1024 * 1024;

  final Queue<LogEntry> _entries = Queue<LogEntry>();

  File? _logFile;
  IOSink? _sink;
  bool _persistenceReady = false;

  /// Read-only view of all entries (oldest first).
  List<LogEntry> get entries => _entries.toList(growable: false);

  int get length => _entries.length;

  // ── Initialisation ──────────────────────────────────────────────────

  /// Initialise persistent storage. Safe to call multiple times; subsequent
  /// calls are no-ops. Skipped automatically on web (no filesystem).
  Future<void> init() async {
    if (_persistenceReady) return;
    if (kIsWeb) return;

    try {
      final cacheDir = await getApplicationCacheDirectory();
      _logFile = File('${cacheDir.path}/fractal_forge_logs.jsonl');
      await _loadFromDisk();
      _sink = _logFile!.openWrite(mode: FileMode.append);
      _persistenceReady = true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[AppLogger] Failed to init persistence: $e');
      }
      // Graceful degradation: continue with in-memory only.
      _logFile = null;
      _sink = null;
    }
  }

  // ── Disk I/O ────────────────────────────────────────────────────────

  Future<void> _loadFromDisk() async {
    final file = _logFile;
    if (file == null || !file.existsSync()) return;

    try {
      final lines = await file.readAsLines();

      // Rotation: keep only the last _maxDiskEntries lines that fit within
      // _maxDiskBytes when re-encoded.
      final rotation = LogDiskRotationPolicy.plan(
        lines: lines,
        maxEntries: _maxDiskEntries,
        maxBytes: _maxDiskBytes,
      );

      // If we trimmed anything, rewrite the file to reclaim space.
      if (rotation.shouldRewrite) {
        await file.writeAsString(rotation.serializeKeptLines());
      }

      // Parse and load into ring buffer (in-memory max still applies).
      for (final line in rotation.keptLines) {
        try {
          final json = jsonDecode(line) as Map<String, dynamic>;
          final entry = LogEntry.fromDiskJson(json);
          _entries.addLast(entry);
          while (_entries.length > maxEntries) {
            _entries.removeFirst();
          }
        } catch (_) {
          // Skip malformed lines.
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[AppLogger] Failed to load log from disk: $e');
      }
    }
  }

  void _appendToDisk(LogEntry entry) {
    final sink = _sink;
    if (sink == null) return;

    try {
      sink.writeln(jsonEncode(entry.toDiskJson()));
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[AppLogger] Failed to write log entry to disk: $e');
      }
    }
  }

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
    _appendToDisk(entry);
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

  // ── Clear ────────────────────────────────────────────────────────────

  /// Clear all entries from memory and truncate the on-disk file.
  Future<void> clearLog() async {
    _entries.clear();
    await _truncateDisk();
    notifyListeners();
  }

  /// Synchronous clear (in-memory only; schedules disk truncation).
  void clear() {
    _entries.clear();
    _truncateDisk(); // fire-and-forget
    notifyListeners();
  }

  Future<void> _truncateDisk() async {
    final file = _logFile;
    if (file == null || !_persistenceReady) return;

    try {
      // Close the current sink, truncate the file, reopen for append.
      await _sink?.flush();
      await _sink?.close();
      _sink = null;
      await file.writeAsString('');
      _sink = file.openWrite(mode: FileMode.append);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[AppLogger] Failed to truncate log file: $e');
      }
    }
  }

  // ── Dispose ──────────────────────────────────────────────────────────

  @override
  Future<void> dispose() async {
    try {
      await _sink?.flush();
      await _sink?.close();
    } catch (_) {}
    _sink = null;
    super.dispose();
  }
}
