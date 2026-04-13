// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0429_triple_spiral_presets.dart';
import 'f0429_triple_spiral_variants.dart';
import 'f0429_triple_spiral_metadata.dart';

/// Triple Spiral — Escape-Time (Complex Plane).
class F0429TripleSpiral extends EscapeTimeModule {
  F0429TripleSpiral()
      : super(
          id: 'f0429_triple_spiral',
          shader: 'shaders/f0429_triple_spiral_gpu.frag',
        );

  @override
  F0429TripleSpiralMetadata get metadata => F0429TripleSpiralMetadata.instance;

  @override
  List<F0429TripleSpiralPreset> get presets => F0429TripleSpiralPresets.all;

  @override
  List<F0429TripleSpiralVariant> get variants => F0429TripleSpiralVariants.all;

  @override
  double get defaultPower => 2.0;

  @override
  double get defaultBailout => 4.0;

  @override
  int get defaultIterations => 800;

  @override
  DeepZoomStrategy get deepZoom => DeepZoomStrategy.perturbation;

  @override
  void configureShader(ShaderParams p) {
    p.setFloat('power', defaultPower);
    p.setFloat('bailout', defaultBailout);
    p.setInt('iterations', defaultIterations);
  }
}
