// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0623_lyapunov_aaabaaab_presets.dart';
import 'f0623_lyapunov_aaabaaab_variants.dart';
import 'f0623_lyapunov_aaabaaab_metadata.dart';

/// Lyapunov AAABAAAB — Lyapunov & Stability.
class F0623LyapunovAaabaaab extends EscapeTimeModule {
  F0623LyapunovAaabaaab()
      : super(
          id: 'f0623_lyapunov_aaabaaab',
          shader: 'shaders/f0623_lyapunov_aaabaaab_gpu.frag',
        );

  @override
  F0623LyapunovAaabaaabMetadata get metadata => F0623LyapunovAaabaaabMetadata.instance;

  @override
  List<F0623LyapunovAaabaaabPreset> get presets => F0623LyapunovAaabaaabPresets.all;

  @override
  List<F0623LyapunovAaabaaabVariant> get variants => F0623LyapunovAaabaaabVariants.all;

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
