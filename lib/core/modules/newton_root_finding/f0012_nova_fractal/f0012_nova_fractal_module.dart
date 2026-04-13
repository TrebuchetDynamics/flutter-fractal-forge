// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0012_nova_fractal_presets.dart';
import 'f0012_nova_fractal_variants.dart';
import 'f0012_nova_fractal_metadata.dart';

/// Nova Fractal — Newton / Root-Finding.
class F0012NovaFractal extends EscapeTimeModule {
  F0012NovaFractal()
      : super(
          id: 'f0012_nova_fractal',
          shader: 'shaders/f0012_nova_fractal_gpu.frag',
        );

  @override
  F0012NovaFractalMetadata get metadata => F0012NovaFractalMetadata.instance;

  @override
  List<F0012NovaFractalPreset> get presets => F0012NovaFractalPresets.all;

  @override
  List<F0012NovaFractalVariant> get variants => F0012NovaFractalVariants.all;

  @override
  double get defaultPower => 3.0;

  @override
  double get defaultBailout => 0.001;

  @override
  int get defaultIterations => 64;


  @override
  void configureShader(ShaderParams p) {
    p.setFloat('power', defaultPower);
    p.setFloat('bailout', defaultBailout);
    p.setInt('iterations', defaultIterations);
  }
}
