// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0517_sin_z_1_c_presets.dart';
import 'f0517_sin_z_1_c_variants.dart';
import 'f0517_sin_z_1_c_metadata.dart';

/// sin(z+1) + c — Escape-Time (Complex Plane).
class F0517SinZ1C extends EscapeTimeModule {
  F0517SinZ1C()
      : super(
          id: 'f0517_sin_z_1_c',
          shader: 'shaders/f0517_sin_z_1_c_gpu.frag',
        );

  @override
  F0517SinZ1CMetadata get metadata => F0517SinZ1CMetadata.instance;

  @override
  List<F0517SinZ1CPreset> get presets => F0517SinZ1CPresets.all;

  @override
  List<F0517SinZ1CVariant> get variants => F0517SinZ1CVariants.all;

  @override
  double get defaultPower => 2.0;

  @override
  double get defaultBailout => 50.0;

  @override
  int get defaultIterations => 300;

  @override
  DeepZoomStrategy get deepZoom => DeepZoomStrategy.perturbation;

  @override
  void configureShader(ShaderParams p) {
    p.setFloat('power', defaultPower);
    p.setFloat('bailout', defaultBailout);
    p.setInt('iterations', defaultIterations);
  }
}
