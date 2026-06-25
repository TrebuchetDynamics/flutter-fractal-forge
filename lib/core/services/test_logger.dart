import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

/// Represents a single log event with timestamp, type, category, and optional metadata.
class LogEvent {
  final DateTime timestamp;
  final String type;
  final String category;
  final String message;
  final Map<String, dynamic>? metadata;

  LogEvent({
    required this.timestamp,
    required this.type,
    required this.category,
    required this.message,
    this.metadata,
  });

  @override
  String toString() {
    final timestampStr = timestamp.toIso8601String();
    final metadataStr =
        metadata != null && metadata!.isNotEmpty ? ' $metadata' : '';
    return '[$timestampStr] [$type/$category] $message$metadataStr';
  }
}

/// Singleton event logger for the Flutter Fractal Forge app.
///
/// Logs events to both debug console and a file in the application documents directory.
/// Supports event types: userAction, stateChange, navigation, screenshot.
class TestLogger {
  static TestLogger? _instance;

  static const int maxBufferEntries = 2000;

  IOSink? _sink;
  final List<LogEvent> _buffer = [];
  bool _initialized = false;

  TestLogger._();

  factory TestLogger() {
    _instance ??= TestLogger._();
    return _instance!;
  }

  /// Initialize the logger with optional custom path.
  ///
  /// If [customPath] is provided, uses it directly.
  /// Otherwise creates `debug_logs/session_{timestamp}.log` in app documents directory.
  Future<void> init({String? customPath}) async {
    if (_initialized) {
      return;
    }

    final String logFilePath;

    if (customPath != null) {
      logFilePath = customPath;
    } else {
      final docDir = await getApplicationDocumentsDirectory();
      final debugLogsDir = Directory('${docDir.path}/debug_logs');

      if (!await debugLogsDir.exists()) {
        await debugLogsDir.create(recursive: true);
      }

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      logFilePath = '${debugLogsDir.path}/session_$timestamp.log';
    }

    final file = File(logFilePath);
    _sink = file.openWrite(mode: FileMode.append);
    _initialized = true;

    if (kDebugMode) debugPrint('TestLogger initialized: $logFilePath');
  }

  /// Log an event to buffer, console, and file (if initialized).
  void log(LogEvent event) {
    _buffer.add(event);
    if (_buffer.length > maxBufferEntries) {
      _buffer.removeRange(0, _buffer.length - maxBufferEntries);
    }
    if (kDebugMode) debugPrint(event.toString());

    if (_initialized && _sink != null) {
      _sink!.writeln(event.toString());
    }
  }

  /// Log a user action event.
  void logAction(String category, String message,
      {Map<String, dynamic>? metadata}) {
    log(LogEvent(
      timestamp: DateTime.now(),
      type: 'userAction',
      category: category,
      message: message,
      metadata: metadata,
    ));
  }

  /// Log a state change event.
  void logStateChange(String category, String message,
      {Map<String, dynamic>? metadata}) {
    log(LogEvent(
      timestamp: DateTime.now(),
      type: 'stateChange',
      category: category,
      message: message,
      metadata: metadata,
    ));
  }

  /// Log a navigation event.
  void logNavigation(String message, {Map<String, dynamic>? metadata}) {
    log(LogEvent(
      timestamp: DateTime.now(),
      type: 'navigation',
      category: 'navigation',
      message: message,
      metadata: metadata,
    ));
  }

  /// Log a screenshot event.
  void logScreenshot(String name, {Map<String, dynamic>? metadata}) {
    log(LogEvent(
      timestamp: DateTime.now(),
      type: 'screenshot',
      category: 'screenshot',
      message: name,
      metadata: metadata,
    ));
  }

  /// Get an unmodifiable view of the event buffer.
  List<LogEvent> get buffer => List.unmodifiable(_buffer);

  /// Clear the in-memory event buffer.
  void clearBuffer() => _buffer.clear();

  /// Dispose the logger, flushing and closing the file sink.
  Future<void> dispose() async {
    if (_sink != null) {
      await _sink!.flush();
      await _sink!.close();
      _sink = null;
    }
    _initialized = false;
    _instance = null;
  }
}
