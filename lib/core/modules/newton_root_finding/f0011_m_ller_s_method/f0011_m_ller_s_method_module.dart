// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0011_m_ller_s_method_presets.dart';
import 'f0011_m_ller_s_method_variants.dart';
import 'f0011_m_ller_s_method_metadata.dart';

/// Müller's Method — Newton / Root-Finding.
class F0011MLlerSMethod extends EscapeTimeModule {
  F0011MLlerSMethod()
      : super(
          id: 'f0011_m_ller_s_method',
          shader: 'shaders/f0011_m_ller_s_method_gpu.frag',
        );

  @override
  F0011MLlerSMethodMetadata get metadata => F0011MLlerSMethodMetadata.instance;

  @override
  List<F0011MLlerSMethodPreset> get presets => F0011MLlerSMethodPresets.all;

  @override
  List<F0011MLlerSMethodVariant> get variants => F0011MLlerSMethodVariants.all;

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
