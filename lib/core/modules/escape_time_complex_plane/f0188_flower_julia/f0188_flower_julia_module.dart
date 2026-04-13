// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0188_flower_julia_presets.dart';
import 'f0188_flower_julia_variants.dart';
import 'f0188_flower_julia_metadata.dart';

/// Flower Julia — Escape-Time (Complex Plane).
class F0188FlowerJulia extends EscapeTimeModule {
  F0188FlowerJulia()
      : super(
          id: 'f0188_flower_julia',
          shader: 'shaders/f0188_flower_julia_gpu.frag',
        );

  @override
  F0188FlowerJuliaMetadata get metadata => F0188FlowerJuliaMetadata.instance;

  @override
  List<F0188FlowerJuliaPreset> get presets => F0188FlowerJuliaPresets.all;

  @override
  List<F0188FlowerJuliaVariant> get variants => F0188FlowerJuliaVariants.all;

  @override
  double get defaultPower => 2.0;

  @override
  double get defaultBailout => 4.0;

  @override
  int get defaultIterations => 500;

  @override
  DeepZoomStrategy get deepZoom => DeepZoomStrategy.perturbation;

  @override
  void configureShader(ShaderParams p) {
    p.setFloat('power', defaultPower);
    p.setFloat('bailout', defaultBailout);
    p.setInt('iterations', defaultIterations);
  }
}
