// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0627_lyapunov_aabbbaa_presets.dart';
import 'f0627_lyapunov_aabbbaa_variants.dart';
import 'f0627_lyapunov_aabbbaa_metadata.dart';

/// Lyapunov AABBBAA — Lyapunov & Stability.
class F0627LyapunovAabbbaa extends EscapeTimeModule {
  F0627LyapunovAabbbaa()
      : super(
          id: 'f0627_lyapunov_aabbbaa',
          shader: 'shaders/f0627_lyapunov_aabbbaa_gpu.frag',
        );

  @override
  F0627LyapunovAabbbaaMetadata get metadata => F0627LyapunovAabbbaaMetadata.instance;

  @override
  List<F0627LyapunovAabbbaaPreset> get presets => F0627LyapunovAabbbaaPresets.all;

  @override
  List<F0627LyapunovAabbbaaVariant> get variants => F0627LyapunovAabbbaaVariants.all;

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
