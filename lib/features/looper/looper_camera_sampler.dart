import 'dart:math' as math;

import 'package:flutter_fractals/core/controllers/input/fractal_view_input_bounds.dart';
import 'package:flutter_fractals/core/models/fractal_view_state.dart';
import 'package:flutter_fractals/core/modules/fractal_module.dart';
import 'package:vector_math/vector_math_64.dart';

/// Pure, bounded camera sampling. Never mutates a viewer or retries a sample.
FractalViewState? sampleLooperCamera({
  required FractalModule module,
  required FractalViewState anchor,
  required math.Random random,
}) {
  final view = anchor;
  if (view.trajectory != null ||
      !view.zoom.isFinite ||
      view.zoom < FractalViewInputBounds.minZoomForModule(module.id) ||
      view.zoom > FractalViewInputBounds.maxZoom ||
      view.pan.x < FractalViewInputBounds.minPan ||
      view.pan.x > FractalViewInputBounds.maxPan ||
      view.pan.y < FractalViewInputBounds.minPan ||
      view.pan.y > FractalViewInputBounds.maxPan ||
      !view.pan.x.isFinite ||
      !view.pan.y.isFinite ||
      !view.rotation.x.isFinite ||
      !view.rotation.y.isFinite ||
      !view.rotation.z.isFinite) {
    return null;
  }

  final rng = random;
  final zoomFactor = math
      .exp(math.log(0.8) + rng.nextDouble() * (math.log(1.25) - math.log(0.8)));
  final zoom = FractalViewInputBounds.normalizeZoom(
    candidate: view.zoom * zoomFactor,
    currentZoom: view.zoom,
    moduleId: module.id,
  );
  var x = view.pan.x;
  var y = view.pan.y;
  var rotation = view.rotation.clone();
  if (module.dimension == FractalDimension.twoD) {
    final jitter = math.min(0.15 / view.zoom, 0.25);
    x = FractalViewInputBounds.normalizePanComponent(
      candidate: x + (rng.nextDouble() * 2 - 1) * jitter,
      current: x,
    );
    y = FractalViewInputBounds.normalizePanComponent(
      candidate: y + (rng.nextDouble() * 2 - 1) * jitter,
      current: y,
    );
  } else if (module.dimension == FractalDimension.threeD) {
    const angle = math.pi / 12;
    rotation = Vector3(
      rotation.x + (rng.nextDouble() * 2 - 1) * angle,
      rotation.y + (rng.nextDouble() * 2 - 1) * angle,
      rotation.z,
    );
  }

  return view.copyWith(zoom: zoom, pan: Vector2(x, y), rotation: rotation);
}
