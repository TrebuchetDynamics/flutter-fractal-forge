import 'package:flutter/foundation.dart';
import 'package:flutter_fractals/core/modules/fractal_module.dart';

/// Immutable effective state used to paint one visible fractal base-field frame.
///
/// This snapshot is emitted after precision/module routing, runtime iteration
/// policy, and palette interpolation. Widget-level post-processing such as fluid
/// warp, morph, and celebration overlays is intentionally not represented.
@immutable
final class FractalRenderSnapshot {
  const FractalRenderSnapshot({
    required this.module,
    required this.state,
    required this.time,
    required this.glowEnabled,
    required this.glowSigma,
    required this.glowIntensity,
    required this.kaleidoscopeEnabled,
    required this.kaleidoscopeSectors,
    required this.kaleidoscopeMirror,
    required this.kaleidoscopeRotation,
    required this.kaleidoscopeMirrorMode,
  });

  final FractalModule module;
  final FractalRenderState state;
  final double time;
  final bool glowEnabled;
  final double glowSigma;
  final double glowIntensity;
  final bool kaleidoscopeEnabled;
  final int kaleidoscopeSectors;
  final bool kaleidoscopeMirror;
  final double kaleidoscopeRotation;
  final int kaleidoscopeMirrorMode;
}

/// Stable viewer-owned sink observed by the renderer's animated frame builder.
final class FractalRenderSnapshotSink {
  FractalRenderSnapshot? snapshot;
}
