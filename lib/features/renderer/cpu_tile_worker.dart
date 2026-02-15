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
    final msg = await rp.first;
    rp.close();
    return msg as CpuTileRenderResponse;
  }

  void dispose() {
    _sub.cancel();
    _isolate.kill(priority: Isolate.immediate);
  }
}

void _entry(SendPort mainSendPort) {
  final commands = ReceivePort();
  mainSendPort.send(commands.sendPort);

  commands.listen((msg) {
    final (CpuTileRenderRequest req, SendPort replyTo) = msg as (CpuTileRenderRequest, SendPort);
    final resp = renderCpuTileInIsolate(req);
    replyTo.send(resp);
  });
}
