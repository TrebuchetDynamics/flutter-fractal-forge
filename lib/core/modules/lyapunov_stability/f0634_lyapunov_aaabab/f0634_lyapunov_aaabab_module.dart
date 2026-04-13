// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0634_lyapunov_aaabab_presets.dart';
import 'f0634_lyapunov_aaabab_variants.dart';
import 'f0634_lyapunov_aaabab_metadata.dart';

/// Lyapunov AAABAB — Lyapunov & Stability.
class F0634LyapunovAaabab extends EscapeTimeModule {
  F0634LyapunovAaabab()
      : super(
          id: 'f0634_lyapunov_aaabab',
          shader: 'shaders/f0634_lyapunov_aaabab_gpu.frag',
        );

  @override
  F0634LyapunovAaababMetadata get metadata => F0634LyapunovAaababMetadata.instance;

  @override
  List<F0634LyapunovAaababPreset> get presets => F0634LyapunovAaababPresets.all;

  @override
  List<F0634LyapunovAaababVariant> get variants => F0634LyapunovAaababVariants.all;

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
