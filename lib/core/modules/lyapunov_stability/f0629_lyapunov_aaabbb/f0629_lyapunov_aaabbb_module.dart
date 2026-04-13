// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0629_lyapunov_aaabbb_presets.dart';
import 'f0629_lyapunov_aaabbb_variants.dart';
import 'f0629_lyapunov_aaabbb_metadata.dart';

/// Lyapunov AAABBB — Lyapunov & Stability.
class F0629LyapunovAaabbb extends EscapeTimeModule {
  F0629LyapunovAaabbb()
      : super(
          id: 'f0629_lyapunov_aaabbb',
          shader: 'shaders/f0629_lyapunov_aaabbb_gpu.frag',
        );

  @override
  F0629LyapunovAaabbbMetadata get metadata => F0629LyapunovAaabbbMetadata.instance;

  @override
  List<F0629LyapunovAaabbbPreset> get presets => F0629LyapunovAaabbbPresets.all;

  @override
  List<F0629LyapunovAaabbbVariant> get variants => F0629LyapunovAaabbbVariants.all;

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
