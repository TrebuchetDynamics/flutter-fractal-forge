// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0193_gossamer_julia_presets.dart';
import 'f0193_gossamer_julia_variants.dart';
import 'f0193_gossamer_julia_metadata.dart';

/// Gossamer Julia — Escape-Time (Complex Plane).
class F0193GossamerJulia extends EscapeTimeModule {
  F0193GossamerJulia()
      : super(
          id: 'f0193_gossamer_julia',
          shader: 'shaders/f0193_gossamer_julia_gpu.frag',
        );

  @override
  F0193GossamerJuliaMetadata get metadata => F0193GossamerJuliaMetadata.instance;

  @override
  List<F0193GossamerJuliaPreset> get presets => F0193GossamerJuliaPresets.all;

  @override
  List<F0193GossamerJuliaVariant> get variants => F0193GossamerJuliaVariants.all;

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
