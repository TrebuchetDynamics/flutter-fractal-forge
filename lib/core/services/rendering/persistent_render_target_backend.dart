import 'dart:collection';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';

/// Binds uniforms and samplers before a render-target pass draws.
typedef RenderTargetUniformBinder = void Function(
  ui.FragmentShader shader,
  PersistentRenderTargetFrame frame,
);

@immutable
class PersistentRenderTargetFrame {
  final int width;
  final int height;
  final ui.Image? previous;

  const PersistentRenderTargetFrame({
    required this.width,
    required this.height,
    required this.previous,
  });
}

/// Small offscreen render-target backend for stateful shader effects.
///
/// Flutter fragment shaders are normally one-shot paints. This backend keeps
/// named `ui.Image` targets alive across frames, renders new shader passes into
/// offscreen images, and exposes each prior target as input for the next pass.
/// It is intentionally generic so effects such as fluid dye/velocity ping-pong
/// can be layered on top without editing every fractal shader.
class PersistentRenderTargetBackend {
  static const int _maxProgramCacheEntries = 32;

  final LinkedHashMap<String, ui.FragmentProgram> _programCache =
      LinkedHashMap<String, ui.FragmentProgram>();
  final Map<String, Future<ui.FragmentProgram>> _programLoads = {};
  final Map<String, _RenderTargetImage> _targets = {};

  ui.Image? imageOf(String name) => _targets[name]?.image;

  bool hasTarget(String name) => _targets.containsKey(name);

  Future<ui.Image> ensureTarget({
    required String name,
    required int width,
    required int height,
  }) async {
    final normalizedWidth = width.clamp(1, 8192);
    final normalizedHeight = height.clamp(1, 8192);
    final current = _targets[name];
    if (current != null &&
        current.width == normalizedWidth &&
        current.height == normalizedHeight) {
      return current.image;
    }

    final image = await _createClearImage(normalizedWidth, normalizedHeight);
    current?.dispose();
    _targets[name] = _RenderTargetImage(
      width: normalizedWidth,
      height: normalizedHeight,
      image: image,
    );
    return image;
  }

  /// Renders one shader pass into [targetName].
  ///
  /// The previous image for [targetName] is available through
  /// [PersistentRenderTargetFrame.previous]. Callers can bind it with
  /// `shader.setImageSampler(...)` to implement feedback/ping-pong passes.
  Future<ui.Image> renderPass({
    required String targetName,
    required int width,
    required int height,
    required String shaderAsset,
    required RenderTargetUniformBinder setUniforms,
    Map<int, ui.Image> samplers = const {},
  }) async {
    final normalizedWidth = width.clamp(1, 8192);
    final normalizedHeight = height.clamp(1, 8192);
    final previous = _targets[targetName];
    final previousImage = (previous != null &&
            previous.width == normalizedWidth &&
            previous.height == normalizedHeight)
        ? previous.image
        : null;

    final program = await _loadProgram(shaderAsset);
    final shader = program.fragmentShader();
    for (final entry in samplers.entries) {
      shader.setImageSampler(entry.key, entry.value);
    }
    setUniforms(
      shader,
      PersistentRenderTargetFrame(
        width: normalizedWidth,
        height: normalizedHeight,
        previous: previousImage,
      ),
    );

    final recorder = ui.PictureRecorder();
    final canvas = ui.Canvas(recorder);
    canvas.drawRect(
      ui.Rect.fromLTWH(
        0,
        0,
        normalizedWidth.toDouble(),
        normalizedHeight.toDouble(),
      ),
      ui.Paint()..shader = shader,
    );
    final picture = recorder.endRecording();
    final image = await picture.toImage(normalizedWidth, normalizedHeight);
    picture.dispose();
    shader.dispose();

    if (previous?.image != image) previous?.dispose();
    _targets[targetName] = _RenderTargetImage(
      width: normalizedWidth,
      height: normalizedHeight,
      image: image,
    );
    return image;
  }

  void clearTarget(String name) {
    _targets.remove(name)?.dispose();
  }

  void dispose() {
    for (final target in _targets.values) {
      target.dispose();
    }
    _targets.clear();
    _programCache.clear();
    _programLoads.clear();
  }

  Future<ui.FragmentProgram> _loadProgram(String asset) async {
    final cached = _programCache.remove(asset);
    if (cached != null) {
      _programCache[asset] = cached;
      return cached;
    }

    final program = await _programLoads.putIfAbsent(
      asset,
      () async => ui.FragmentProgram.fromAsset(asset),
    );
    _programLoads.remove(asset);
    _programCache[asset] = program;
    while (_programCache.length > _maxProgramCacheEntries) {
      _programCache.remove(_programCache.keys.first);
    }
    return program;
  }

  Future<ui.Image> _createClearImage(int width, int height) async {
    final recorder = ui.PictureRecorder();
    final canvas = ui.Canvas(recorder);
    canvas.drawRect(
      ui.Rect.fromLTWH(0, 0, width.toDouble(), height.toDouble()),
      ui.Paint()..color = const ui.Color(0x00000000),
    );
    final picture = recorder.endRecording();
    final image = await picture.toImage(width, height);
    picture.dispose();
    return image;
  }
}

class _RenderTargetImage {
  final int width;
  final int height;
  final ui.Image image;

  const _RenderTargetImage({
    required this.width,
    required this.height,
    required this.image,
  });

  void dispose() {
    image.dispose();
  }
}
