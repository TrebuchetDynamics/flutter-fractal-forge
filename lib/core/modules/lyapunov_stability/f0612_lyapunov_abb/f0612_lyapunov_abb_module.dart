// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0612_lyapunov_abb_presets.dart';
import 'f0612_lyapunov_abb_variants.dart';
import 'f0612_lyapunov_abb_metadata.dart';

/// Lyapunov ABB — Lyapunov & Stability.
class F0612LyapunovAbb extends EscapeTimeModule {
  F0612LyapunovAbb()
      : super(
          id: 'f0612_lyapunov_abb',
          shader: 'shaders/f0612_lyapunov_abb_gpu.frag',
        );

  @override
  F0612LyapunovAbbMetadata get metadata => F0612LyapunovAbbMetadata.instance;

  @override
  List<F0612LyapunovAbbPreset> get presets => F0612LyapunovAbbPresets.all;

  @override
  List<F0612LyapunovAbbVariant> get variants => F0612LyapunovAbbVariants.all;

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
