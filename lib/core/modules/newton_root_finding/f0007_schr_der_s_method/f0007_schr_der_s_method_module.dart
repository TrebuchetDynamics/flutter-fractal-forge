// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0007_schr_der_s_method_presets.dart';
import 'f0007_schr_der_s_method_variants.dart';
import 'f0007_schr_der_s_method_metadata.dart';

/// Schröder's Method — Newton / Root-Finding.
class F0007SchrDerSMethod extends EscapeTimeModule {
  F0007SchrDerSMethod()
      : super(
          id: 'f0007_schr_der_s_method',
          shader: 'shaders/f0007_schr_der_s_method_gpu.frag',
        );

  @override
  F0007SchrDerSMethodMetadata get metadata => F0007SchrDerSMethodMetadata.instance;

  @override
  List<F0007SchrDerSMethodPreset> get presets => F0007SchrDerSMethodPresets.all;

  @override
  List<F0007SchrDerSMethodVariant> get variants => F0007SchrDerSMethodVariants.all;

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
