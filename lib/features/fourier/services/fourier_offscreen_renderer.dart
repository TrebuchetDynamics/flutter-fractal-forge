import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_fractals/features/renderer/models/fractal_render_snapshot.dart';
import 'package:flutter_fractals/features/renderer/widgets/canvas/fractal_canvas.dart';

/// Replays an effective visible-renderer base-field snapshot offscreen.
///
/// The snapshot already contains precision/module routing, runtime iteration
/// policy, palette interpolation, time, glow, and kaleidoscope state. Widget-level
/// fluid, morph, celebration, and chrome layers are deliberately excluded.
final class FourierOffscreenRenderer {
  String? _asset;
  ui.FragmentProgram? _program;

  Future<ui.Image> render({
    required FractalRenderSnapshot snapshot,
    required int width,
    required int height,
  }) async {
    if (width <= 0 || height <= 0) {
      throw ArgumentError.value('$width x $height', 'dimensions');
    }
    final asset = snapshot.module.shaderAsset;
    if (_program == null || _asset != asset) {
      final loaded = await ui.FragmentProgram.fromAsset(asset);
      _asset = asset;
      _program = loaded;
    }
    final shader = _program!.fragmentShader();
    final recorder = ui.PictureRecorder();
    final size = Size(width.toDouble(), height.toDouble());
    final canvas = Canvas(recorder, Offset.zero & size);
    final picture = (() {
      try {
        FractalCanvas(
          module: snapshot.module,
          state: snapshot.state,
          time: snapshot.time,
          shader: shader,
          glowEnabled: snapshot.glowEnabled,
          glowSigma: snapshot.glowSigma,
          glowIntensity: snapshot.glowIntensity,
          kaleidoscopeEnabled: snapshot.kaleidoscopeEnabled,
          kaleidoscopeSectors: snapshot.kaleidoscopeSectors,
          kaleidoscopeMirror: snapshot.kaleidoscopeMirror,
          kaleidoscopeRotation: snapshot.kaleidoscopeRotation,
          kaleidoscopeMirrorMode: snapshot.kaleidoscopeMirrorMode,
        ).paint(canvas, size);
        return recorder.endRecording();
      } finally {
        shader.dispose();
      }
    })();
    try {
      return await picture.toImage(width, height);
    } finally {
      picture.dispose();
    }
  }
}
