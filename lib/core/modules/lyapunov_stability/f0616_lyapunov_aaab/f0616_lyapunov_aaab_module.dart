// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0616_lyapunov_aaab_presets.dart';
import 'f0616_lyapunov_aaab_variants.dart';
import 'f0616_lyapunov_aaab_metadata.dart';

/// Lyapunov AAAB — Lyapunov & Stability.
class F0616LyapunovAaab extends EscapeTimeModule {
  F0616LyapunovAaab()
      : super(
          id: 'f0616_lyapunov_aaab',
          shader: 'shaders/f0616_lyapunov_aaab_gpu.frag',
        );

  @override
  F0616LyapunovAaabMetadata get metadata => F0616LyapunovAaabMetadata.instance;

  @override
  List<F0616LyapunovAaabPreset> get presets => F0616LyapunovAaabPresets.all;

  @override
  List<F0616LyapunovAaabVariant> get variants => F0616LyapunovAaabVariants.all;

  @override
  double get defaultPower => 2.0;

  @override
  double get defaultBailout => 2.0;

  @override
  int get defaultIterations => 300;


  @override
  void configureShader(ShaderParams p) {
    p.setFloat('power', defaultPower);
    p.setFloat('bailout', defaultBailout);
    p.setInt('iterations', defaultIterations);
  }
}
