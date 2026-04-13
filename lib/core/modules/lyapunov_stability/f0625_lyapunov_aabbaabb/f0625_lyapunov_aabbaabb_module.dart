// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0625_lyapunov_aabbaabb_presets.dart';
import 'f0625_lyapunov_aabbaabb_variants.dart';
import 'f0625_lyapunov_aabbaabb_metadata.dart';

/// Lyapunov AABBAABB — Lyapunov & Stability.
class F0625LyapunovAabbaabb extends EscapeTimeModule {
  F0625LyapunovAabbaabb()
      : super(
          id: 'f0625_lyapunov_aabbaabb',
          shader: 'shaders/f0625_lyapunov_aabbaabb_gpu.frag',
        );

  @override
  F0625LyapunovAabbaabbMetadata get metadata => F0625LyapunovAabbaabbMetadata.instance;

  @override
  List<F0625LyapunovAabbaabbPreset> get presets => F0625LyapunovAabbaabbPresets.all;

  @override
  List<F0625LyapunovAabbaabbVariant> get variants => F0625LyapunovAabbaabbVariants.all;

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
