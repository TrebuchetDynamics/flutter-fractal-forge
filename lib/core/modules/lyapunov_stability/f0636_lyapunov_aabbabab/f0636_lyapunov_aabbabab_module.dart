// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0636_lyapunov_aabbabab_presets.dart';
import 'f0636_lyapunov_aabbabab_variants.dart';
import 'f0636_lyapunov_aabbabab_metadata.dart';

/// Lyapunov AABBABAB — Lyapunov & Stability.
class F0636LyapunovAabbabab extends EscapeTimeModule {
  F0636LyapunovAabbabab()
      : super(
          id: 'f0636_lyapunov_aabbabab',
          shader: 'shaders/f0636_lyapunov_aabbabab_gpu.frag',
        );

  @override
  F0636LyapunovAabbababMetadata get metadata => F0636LyapunovAabbababMetadata.instance;

  @override
  List<F0636LyapunovAabbababPreset> get presets => F0636LyapunovAabbababPresets.all;

  @override
  List<F0636LyapunovAabbababVariant> get variants => F0636LyapunovAabbababVariants.all;

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
