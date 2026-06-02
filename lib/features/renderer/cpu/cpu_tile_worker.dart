import 'dart:async';
import 'dart:isolate';

import 'cpu_render_isolate.dart';

/// A long-lived isolate for CPU tile rendering.
///
/// Spawning an isolate per tile (Isolate.run) is far too slow on mobile.
/// This worker keeps one isolate alive and processes tile jobs sequentially.
class CpuTileWorker {
  CpuTileWorker._(this._isolate, this._sendPort, this._sub);

  final Isolate _isolate;
  final SendPort _sendPort;
  final StreamSubscription _sub;

  static Future<CpuTileWorker> spawn() async {
    final receive = ReceivePort();
    final handshake = Completer<SendPort>();

    final sub = receive.listen((msg) {
      if (msg is SendPort && !handshake.isCompleted) {
        handshake.complete(msg);
      }
    });

    final isolate = await Isolate.spawn(_entry, receive.sendPort);
    final sendPort = await handshake.future;

    return CpuTileWorker._(isolate, sendPort, sub);
  }

  Future<CpuTileRenderResponse> renderTile(CpuTileRenderRequest req) async {
    final rp = ReceivePort();
    _sendPort.send((req, rp.sendPort));
    try {
      final msg = await rp.first;
      if (msg is CpuTileRenderResponse) return msg;
      if (msg is _CpuTileRenderFailure) throw msg.toException();
      throw StateError('Unexpected CPU tile worker reply: ${msg.runtimeType}');
    } finally {
      rp.close();
    }
  }

  void dispose() {
    _sub.cancel();
    _isolate.kill(priority: Isolate.immediate);
  }
}

/// Exception surfaced when the worker isolate could not render a requested tile.
class CpuTileWorkerException implements Exception {
  const CpuTileWorkerException({
    required this.errorType,
    required this.message,
    required this.stackTraceText,
  });

  final String errorType;
  final String message;
  final String stackTraceText;

  @override
  String toString() => 'CpuTileWorkerException($errorType): $message';
}

final class _CpuTileRenderFailure {
  const _CpuTileRenderFailure({
    required this.errorType,
    required this.message,
    required this.stackTraceText,
  });

  final String errorType;
  final String message;
  final String stackTraceText;

  factory _CpuTileRenderFailure.from(Object error, StackTrace stackTrace) {
    return _CpuTileRenderFailure(
      errorType: error.runtimeType.toString(),
      message: error.toString(),
      stackTraceText: stackTrace.toString(),
    );
  }

  CpuTileWorkerException toException() {
    return CpuTileWorkerException(
      errorType: errorType,
      message: message,
      stackTraceText: stackTraceText,
    );
  }
}

void _entry(SendPort mainSendPort) {
  final commands = ReceivePort();
  mainSendPort.send(commands.sendPort);

  commands.listen((msg) {
    SendPort? replyTo;
    try {
      final (CpuTileRenderRequest req, SendPort port) =
          msg as (CpuTileRenderRequest, SendPort);
      replyTo = port;
      final resp = renderCpuTileInIsolate(req);
      replyTo.send(resp);
    } catch (error, stackTrace) {
      replyTo?.send(_CpuTileRenderFailure.from(error, stackTrace));
    }
  });
}
