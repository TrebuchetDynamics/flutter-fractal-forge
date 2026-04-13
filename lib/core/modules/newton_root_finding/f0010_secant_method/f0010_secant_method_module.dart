// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0010_secant_method_presets.dart';
import 'f0010_secant_method_variants.dart';
import 'f0010_secant_method_metadata.dart';

/// Secant Method — Newton / Root-Finding.
class F0010SecantMethod extends EscapeTimeModule {
  F0010SecantMethod()
      : super(
          id: 'f0010_secant_method',
          shader: 'shaders/f0010_secant_method_gpu.frag',
        );

  @override
  F0010SecantMethodMetadata get metadata => F0010SecantMethodMetadata.instance;

  @override
  List<F0010SecantMethodPreset> get presets => F0010SecantMethodPresets.all;

  @override
  List<F0010SecantMethodVariant> get variants => F0010SecantMethodVariants.all;

  @override
  double get defaultPower => 3.0;

  @override
  double get defaultBailout => 0.001;

  @override
  int get defaultIterations => 80;


  @override
  void configureShader(ShaderParams p) {
    p.setFloat('power', defaultPower);
    p.setFloat('bailout', defaultBailout);
    p.setInt('iterations', defaultIterations);
  }
}
