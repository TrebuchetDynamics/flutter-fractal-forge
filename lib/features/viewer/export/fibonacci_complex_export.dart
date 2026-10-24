import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/widgets.dart';

import 'package:flutter_fractals/core/modules/fractal_module.dart';
import 'package:flutter_fractals/core/services/export/export_coordinator.dart';
import 'package:flutter_fractals/core/services/export/export_service.dart';
import 'package:flutter_fractals/core/services/export/export_worker.dart';
import 'package:flutter_fractals/features/fourier/services/fourier_offscreen_renderer.dart';
import 'package:flutter_fractals/features/renderer/cpu/cpu_fractal_renderer.dart';
import 'package:flutter_fractals/features/renderer/cpu/cpu_render_isolate.dart';
import 'package:flutter_fractals/features/renderer/models/fractal_render_snapshot.dart';

final class FibonacciComplexCpuTransparencyException implements Exception {
  const FibonacciComplexCpuTransparencyException();
}

/// Family-owned immutable export capture. Navigation, edits and late frames
/// cannot change this finite experiment while a picker/encoder is awaiting.
/// The normal export service still owns sizing, metadata, codecs and commit.
final class FibonacciComplexExportCapture {
  final FractalRenderSnapshot snapshot;
  final bool requiresCpu;
  final double width;
  final double height;

  FibonacciComplexExportCapture({
    required FractalRenderSnapshot snapshot,
    required this.requiresCpu,
    required this.width,
    required this.height,
  }) : snapshot = FractalRenderSnapshot(
          module: snapshot.module,
          state: FractalRenderState(
            params: Map.unmodifiable(snapshot.state.params),
            view: snapshot.state.view.copyWith(),
            transparentBackground: snapshot.state.transparentBackground,
          ),
          time: snapshot.time,
          glowEnabled: snapshot.glowEnabled,
          glowSigma: snapshot.glowSigma,
          glowIntensity: snapshot.glowIntensity,
          kaleidoscopeEnabled: snapshot.kaleidoscopeEnabled,
          kaleidoscopeSectors: snapshot.kaleidoscopeSectors,
          kaleidoscopeMirror: snapshot.kaleidoscopeMirror,
          kaleidoscopeRotation: snapshot.kaleidoscopeRotation,
          kaleidoscopeMirrorMode: snapshot.kaleidoscopeMirrorMode,
        );

  /// Freeze the actual active pane size, not MediaQuery's full-screen size.
  factory FibonacciComplexExportCapture.fromBoundary({
    required FractalRenderSnapshot snapshot,
    required bool requiresCpu,
    required GlobalKey boundaryKey,
  }) {
    final box = boundaryKey.currentContext?.findRenderObject();
    final size = box is RenderBox && box.hasSize ? box.size : ui.Size.zero;
    return FibonacciComplexExportCapture(
        snapshot: snapshot,
        requiresCpu: requiresCpu,
        width: size.width,
        height: size.height);
  }

  void validate() {
    if (snapshot.module.id != 'fibonacci_complex_julia') {
      throw ArgumentError('Fibonacci capture requires its native module');
    }
    if (requiresCpu && snapshot.state.transparentBackground) {
      throw const FibonacciComplexCpuTransparencyException();
    }
  }

  Future<Uint8List> capturePng(double pixelRatio,
      {ExportCancellationToken? cancellationToken}) async {
    validate(); // Before rendering or any completed-file write.
    cancellationToken?.throwIfCancelled();
    final w = (width * pixelRatio).round();
    final h = (height * pixelRatio).round();
    ExportSizePolicy.validateTargetDimensions(w, h);
    late final ui.Image image;
    if (requiresCpu) {
      final state = snapshot.state;
      final response = await const IsolateExportWorker().runWithInput(
        renderCpuFrameInIsolate,
        CpuRenderRequest(
          moduleId: snapshot.module.id,
          panX: state.view.pan.x,
          panY: state.view.pan.y,
          zoom: state.view.zoom,
          iterations: (state.params['iterations'] as num).round().clamp(1, 45),
          bailout: cpuControlScalarForModule(snapshot.module.id, state.params),
          juliaCX: cpuJuliaCForModule(snapshot.module.id, state.params).x,
          juliaCY: cpuJuliaCForModule(snapshot.module.id, state.params).y,
          width: w,
          height: h,
          sampleCount: 1,
        ),
        token: cancellationToken,
      );
      image = await CpuRenderFrame(rgba: response.rgba, width: w, height: h)
          .toImage();
    } else {
      // A shader/load failure propagates; never silently substitute opaque CPU.
      image = await FourierOffscreenRenderer()
          .render(snapshot: snapshot, width: w, height: h);
    }
    try {
      cancellationToken?.throwIfCancelled();
      final data = await image.toByteData(format: ui.ImageByteFormat.png);
      if (data == null) throw StateError('Fibonacci PNG readback failed');
      cancellationToken?.throwIfCancelled();
      return data.buffer.asUint8List();
    } finally {
      image.dispose();
    }
  }
}
