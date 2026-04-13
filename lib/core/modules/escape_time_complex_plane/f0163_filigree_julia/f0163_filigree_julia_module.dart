// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0163_filigree_julia_presets.dart';
import 'f0163_filigree_julia_variants.dart';
import 'f0163_filigree_julia_metadata.dart';

/// Filigree Julia — Escape-Time (Complex Plane).
class F0163FiligreeJulia extends EscapeTimeModule {
  F0163FiligreeJulia()
      : super(
          id: 'f0163_filigree_julia',
          shader: 'shaders/f0163_filigree_julia_gpu.frag',
        );

  @override
  F0163FiligreeJuliaMetadata get metadata => F0163FiligreeJuliaMetadata.instance;

  @override
  List<F0163FiligreeJuliaPreset> get presets => F0163FiligreeJuliaPresets.all;

  @override
  List<F0163FiligreeJuliaVariant> get variants => F0163FiligreeJuliaVariants.all;

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
