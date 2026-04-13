// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0628_lyapunov_abbbba_presets.dart';
import 'f0628_lyapunov_abbbba_variants.dart';
import 'f0628_lyapunov_abbbba_metadata.dart';

/// Lyapunov ABBBBA — Lyapunov & Stability.
class F0628LyapunovAbbbba extends EscapeTimeModule {
  F0628LyapunovAbbbba()
      : super(
          id: 'f0628_lyapunov_abbbba',
          shader: 'shaders/f0628_lyapunov_abbbba_gpu.frag',
        );

  @override
  F0628LyapunovAbbbbaMetadata get metadata => F0628LyapunovAbbbbaMetadata.instance;

  @override
  List<F0628LyapunovAbbbbaPreset> get presets => F0628LyapunovAbbbbaPresets.all;

  @override
  List<F0628LyapunovAbbbbaVariant> get variants => F0628LyapunovAbbbbaVariants.all;

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
