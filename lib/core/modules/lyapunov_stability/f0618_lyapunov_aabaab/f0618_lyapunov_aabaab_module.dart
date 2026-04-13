// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0618_lyapunov_aabaab_presets.dart';
import 'f0618_lyapunov_aabaab_variants.dart';
import 'f0618_lyapunov_aabaab_metadata.dart';

/// Lyapunov AABAAB — Lyapunov & Stability.
class F0618LyapunovAabaab extends EscapeTimeModule {
  F0618LyapunovAabaab()
      : super(
          id: 'f0618_lyapunov_aabaab',
          shader: 'shaders/f0618_lyapunov_aabaab_gpu.frag',
        );

  @override
  F0618LyapunovAabaabMetadata get metadata => F0618LyapunovAabaabMetadata.instance;

  @override
  List<F0618LyapunovAabaabPreset> get presets => F0618LyapunovAabaabPresets.all;

  @override
  List<F0618LyapunovAabaabVariant> get variants => F0618LyapunovAabaabVariants.all;

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
