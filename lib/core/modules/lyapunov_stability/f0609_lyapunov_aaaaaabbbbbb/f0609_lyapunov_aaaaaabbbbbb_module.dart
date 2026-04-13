// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0609_lyapunov_aaaaaabbbbbb_presets.dart';
import 'f0609_lyapunov_aaaaaabbbbbb_variants.dart';
import 'f0609_lyapunov_aaaaaabbbbbb_metadata.dart';

/// Lyapunov AAAAAABBBBBB — Lyapunov & Stability.
class F0609LyapunovAaaaaabbbbbb extends EscapeTimeModule {
  F0609LyapunovAaaaaabbbbbb()
      : super(
          id: 'f0609_lyapunov_aaaaaabbbbbb',
          shader: 'shaders/f0609_lyapunov_aaaaaabbbbbb_gpu.frag',
        );

  @override
  F0609LyapunovAaaaaabbbbbbMetadata get metadata => F0609LyapunovAaaaaabbbbbbMetadata.instance;

  @override
  List<F0609LyapunovAaaaaabbbbbbPreset> get presets => F0609LyapunovAaaaaabbbbbbPresets.all;

  @override
  List<F0609LyapunovAaaaaabbbbbbVariant> get variants => F0609LyapunovAaaaaabbbbbbVariants.all;

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
