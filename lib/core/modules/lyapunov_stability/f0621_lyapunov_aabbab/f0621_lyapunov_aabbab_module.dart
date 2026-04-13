// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0621_lyapunov_aabbab_presets.dart';
import 'f0621_lyapunov_aabbab_variants.dart';
import 'f0621_lyapunov_aabbab_metadata.dart';

/// Lyapunov AABBAB — Lyapunov & Stability.
class F0621LyapunovAabbab extends EscapeTimeModule {
  F0621LyapunovAabbab()
      : super(
          id: 'f0621_lyapunov_aabbab',
          shader: 'shaders/f0621_lyapunov_aabbab_gpu.frag',
        );

  @override
  F0621LyapunovAabbabMetadata get metadata => F0621LyapunovAabbabMetadata.instance;

  @override
  List<F0621LyapunovAabbabPreset> get presets => F0621LyapunovAabbabPresets.all;

  @override
  List<F0621LyapunovAabbabVariant> get variants => F0621LyapunovAabbabVariants.all;

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
