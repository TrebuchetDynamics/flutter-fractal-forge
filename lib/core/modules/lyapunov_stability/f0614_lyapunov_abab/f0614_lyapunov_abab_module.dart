// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0614_lyapunov_abab_presets.dart';
import 'f0614_lyapunov_abab_variants.dart';
import 'f0614_lyapunov_abab_metadata.dart';

/// Lyapunov ABAB — Lyapunov & Stability.
class F0614LyapunovAbab extends EscapeTimeModule {
  F0614LyapunovAbab()
      : super(
          id: 'f0614_lyapunov_abab',
          shader: 'shaders/f0614_lyapunov_abab_gpu.frag',
        );

  @override
  F0614LyapunovAbabMetadata get metadata => F0614LyapunovAbabMetadata.instance;

  @override
  List<F0614LyapunovAbabPreset> get presets => F0614LyapunovAbabPresets.all;

  @override
  List<F0614LyapunovAbabVariant> get variants => F0614LyapunovAbabVariants.all;

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
