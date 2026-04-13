// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0006_halley_s_method_presets.dart';
import 'f0006_halley_s_method_variants.dart';
import 'f0006_halley_s_method_metadata.dart';

/// Halley's Method — Newton / Root-Finding.
class F0006HalleySMethod extends EscapeTimeModule {
  F0006HalleySMethod()
      : super(
          id: 'f0006_halley_s_method',
          shader: 'shaders/f0006_halley_s_method_gpu.frag',
        );

  @override
  F0006HalleySMethodMetadata get metadata => F0006HalleySMethodMetadata.instance;

  @override
  List<F0006HalleySMethodPreset> get presets => F0006HalleySMethodPresets.all;

  @override
  List<F0006HalleySMethodVariant> get variants => F0006HalleySMethodVariants.all;

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
