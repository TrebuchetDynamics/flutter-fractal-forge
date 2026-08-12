import 'dart:async';
import 'dart:isolate';

import 'package:flutter_fractals/core/services/export/export_coordinator.dart';

typedef ExportWorkerTask<T> = FutureOr<T> Function();
typedef ExportWorkerInputTask<I, T> = FutureOr<T> Function(I input);

abstract interface class ExportWorker {
  Future<T> run<T>(
    ExportWorkerTask<T> task, {
    ExportCancellationToken? token,
    void Function()? onSpawned,
  });
}

final class _WorkerInvocation<T> {
  final ExportWorkerTask<T> task;
  final SendPort resultPort;

  const _WorkerInvocation(this.task, this.resultPort);
}

final class _WorkerInputInvocation {
  final Function task;
  final Object? input;
  final SendPort resultPort;

  const _WorkerInputInvocation(this.task, this.input, this.resultPort);
}

final class _WorkerSuccess<T> {
  final T value;
  const _WorkerSuccess(this.value);
}

final class _WorkerFailure {
  final String error;
  final String stackTrace;
  const _WorkerFailure(this.error, this.stackTrace);
}

void _runExportWorker<T>(_WorkerInvocation<T> invocation) async {
  try {
    final value = await invocation.task();
    invocation.resultPort.send(_WorkerSuccess<T>(value));
  } catch (error, stackTrace) {
    invocation.resultPort.send(_WorkerFailure('$error', '$stackTrace'));
  }
}

void _runExportInputWorker(_WorkerInputInvocation invocation) async {
  try {
    final value = await invocation.task(invocation.input);
    invocation.resultPort.send(_WorkerSuccess<Object?>(value));
  } catch (error, stackTrace) {
    invocation.resultPort.send(_WorkerFailure('$error', '$stackTrace'));
  }
}

/// Runs CPU-heavy image work outside the UI isolate and kills the isolate when
/// the owning export operation is cancelled.
final class IsolateExportWorker implements ExportWorker {
  const IsolateExportWorker();

  @override
  Future<T> run<T>(
    ExportWorkerTask<T> task, {
    ExportCancellationToken? token,
    void Function()? onSpawned,
  }) async {
    token?.throwIfCancelled();
    final resultPort = ReceivePort();
    Isolate? isolate;
    try {
      isolate = await Isolate.spawn<_WorkerInvocation<T>>(
        _runExportWorker<T>,
        _WorkerInvocation<T>(task, resultPort.sendPort),
        debugName: 'export-worker',
      );
      onSpawned?.call();
      return await _awaitResult<T>(resultPort, token);
    } finally {
      isolate?.kill(priority: Isolate.immediate);
      resultPort.close();
    }
  }

  Future<T> runWithInput<I, T>(
    ExportWorkerInputTask<I, T> task,
    I input, {
    ExportCancellationToken? token,
    void Function()? onSpawned,
  }) async {
    token?.throwIfCancelled();
    final resultPort = ReceivePort();
    Isolate? isolate;
    try {
      isolate = await Isolate.spawn<_WorkerInputInvocation>(
        _runExportInputWorker,
        _WorkerInputInvocation(task, input, resultPort.sendPort),
        debugName: 'export-input-worker',
      );
      onSpawned?.call();
      return await _awaitResult<T>(resultPort, token);
    } finally {
      isolate?.kill(priority: Isolate.immediate);
      resultPort.close();
    }
  }

  Future<T> _awaitResult<T>(
    ReceivePort resultPort,
    ExportCancellationToken? token,
  ) async {
    final Future<Object> resultFuture =
        resultPort.first.then<Object>((message) => message as Object);
    final Object message = token == null
        ? await resultFuture
        : await Future.any<Object>([
            resultFuture,
            token.whenCancelled.then<Object>(
              (_) => const ExportCancelledException(),
            ),
          ]);
    if (message is ExportCancelledException) throw message;
    if (message is _WorkerFailure) {
      throw ExportWorkerException(message.error, message.stackTrace);
    }
    return (message as _WorkerSuccess).value as T;
  }
}

extension ExportWorkerInputExtension on ExportWorker {
  /// Runs a top-level/static function with an explicitly sendable input.
  ///
  /// Keeping the input separate prevents an innocent-looking closure from
  /// retaining a widget State or render tree and making isolate spawn fail.
  Future<T> runWithInput<I, T>(
    ExportWorkerInputTask<I, T> task,
    I input, {
    ExportCancellationToken? token,
    void Function()? onSpawned,
  }) {
    final worker = this;
    if (worker is IsolateExportWorker) {
      return worker.runWithInput(
        task,
        input,
        token: token,
        onSpawned: onSpawned,
      );
    }
    return run(
      () => task(input),
      token: token,
      onSpawned: onSpawned,
    );
  }
}

final class ExportWorkerException implements Exception {
  final String message;
  final String workerStackTrace;

  const ExportWorkerException(this.message, this.workerStackTrace);

  @override
  String toString() => 'Export worker failed: $message';
}
