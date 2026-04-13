// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0008_chebyshev_s_method_presets.dart';
import 'f0008_chebyshev_s_method_variants.dart';
import 'f0008_chebyshev_s_method_metadata.dart';

/// Chebyshev's Method — Newton / Root-Finding.
class F0008ChebyshevSMethod extends EscapeTimeModule {
  F0008ChebyshevSMethod()
      : super(
          id: 'f0008_chebyshev_s_method',
          shader: 'shaders/f0008_chebyshev_s_method_gpu.frag',
        );

  @override
  F0008ChebyshevSMethodMetadata get metadata => F0008ChebyshevSMethodMetadata.instance;

  @override
  List<F0008ChebyshevSMethodPreset> get presets => F0008ChebyshevSMethodPresets.all;

  @override
  List<F0008ChebyshevSMethodVariant> get variants => F0008ChebyshevSMethodVariants.all;

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
