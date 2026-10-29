import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

/// Captures the Fourier CPU boundary after paint while the caller is current.
/// A timely image is owned by the caller. After the deadline, queued attempts
/// are abandoned and any image from an already-started capture is disposed here.
Future<ui.Image?> captureFourierBoundaryAfterPaint({
  required GlobalKey boundaryKey,
  required double pixelRatio,
  required bool Function() isCurrentCapture,
}) {
  final completer = Completer<ui.Image?>();
  var remainingAttempts = 4;
  var abandoned = false;

  void attempt(Duration _) {
    if (abandoned) return;
    if (!isCurrentCapture()) {
      if (!completer.isCompleted) completer.complete();
      return;
    }
    final renderObject = boundaryKey.currentContext?.findRenderObject();
    if (renderObject is! RenderRepaintBoundary ||
        !renderObject.attached ||
        !renderObject.hasSize) {
      if (!completer.isCompleted) completer.complete();
      return;
    }
    if (renderObject.debugNeedsPaint && remainingAttempts-- > 0) {
      WidgetsBinding.instance.addPostFrameCallback(attempt);
      WidgetsBinding.instance.scheduleFrame();
      return;
    }
    if (renderObject.debugNeedsPaint) {
      completer.completeError(StateError('analysis boundary stayed dirty'));
      return;
    }
    try {
      renderObject.toImage(pixelRatio: pixelRatio).then(
        (image) {
          if (abandoned) {
            image.dispose();
          } else {
            completer.complete(image);
          }
        },
        onError: (Object error, StackTrace stackTrace) {
          if (!abandoned) completer.completeError(error, stackTrace);
        },
      );
    } catch (error, stackTrace) {
      completer.completeError(error, stackTrace);
    }
  }

  WidgetsBinding.instance.addPostFrameCallback(attempt);
  WidgetsBinding.instance.scheduleFrame();
  return completer.future.timeout(
    const Duration(seconds: 2),
    onTimeout: () {
      // A native toImage already in progress cannot be cancelled. Keep its
      // handlers alive to dispose a late image or consume a late error.
      abandoned = true;
      throw TimeoutException(
          'Future not completed', const Duration(seconds: 2));
    },
  );
}
