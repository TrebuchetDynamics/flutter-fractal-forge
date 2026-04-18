// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/cellular_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0742_belousov_zhabotinsky_continuous_presets.dart';
import 'f0742_belousov_zhabotinsky_continuous_variants.dart';
import 'f0742_belousov_zhabotinsky_continuous_metadata.dart';

/// Belousov-Zhabotinsky (Continuous) — Reaction-Diffusion & Chemical.
class F0742BelousovZhabotinskyContinuous extends CellularModule {
  F0742BelousovZhabotinskyContinuous()
      : super(
          id: 'f0742_belousov_zhabotinsky_continuous',
          shader: 'shaders/f0742_belousov_zhabotinsky_continuous_gpu.frag',
        );

  @override
  F0742BelousovZhabotinskyContinuousMetadata get metadata => F0742BelousovZhabotinskyContinuousMetadata.instance;

  @override
  List<F0742BelousovZhabotinskyContinuousPreset> get presets => F0742BelousovZhabotinskyContinuousPresets.all;

  @override
  List<F0742BelousovZhabotinskyContinuousVariant> get variants => F0742BelousovZhabotinskyContinuousVariants.all;

  @override
  int get defaultGenerations => 100;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('generations', defaultGenerations);
  }
}
