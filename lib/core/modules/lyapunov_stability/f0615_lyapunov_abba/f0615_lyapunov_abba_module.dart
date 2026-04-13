// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0615_lyapunov_abba_presets.dart';
import 'f0615_lyapunov_abba_variants.dart';
import 'f0615_lyapunov_abba_metadata.dart';

/// Lyapunov ABBA — Lyapunov & Stability.
class F0615LyapunovAbba extends EscapeTimeModule {
  F0615LyapunovAbba()
      : super(
          id: 'f0615_lyapunov_abba',
          shader: 'shaders/f0615_lyapunov_abba_gpu.frag',
        );

  @override
  F0615LyapunovAbbaMetadata get metadata => F0615LyapunovAbbaMetadata.instance;

  @override
  List<F0615LyapunovAbbaPreset> get presets => F0615LyapunovAbbaPresets.all;

  @override
  List<F0615LyapunovAbbaVariant> get variants => F0615LyapunovAbbaVariants.all;

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
