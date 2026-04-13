// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0610_lyapunov_bbbbbbaaaaaa_presets.dart';
import 'f0610_lyapunov_bbbbbbaaaaaa_variants.dart';
import 'f0610_lyapunov_bbbbbbaaaaaa_metadata.dart';

/// Lyapunov BBBBBBAAAAAA — Lyapunov & Stability.
class F0610LyapunovBbbbbbaaaaaa extends EscapeTimeModule {
  F0610LyapunovBbbbbbaaaaaa()
      : super(
          id: 'f0610_lyapunov_bbbbbbaaaaaa',
          shader: 'shaders/f0610_lyapunov_bbbbbbaaaaaa_gpu.frag',
        );

  @override
  F0610LyapunovBbbbbbaaaaaaMetadata get metadata => F0610LyapunovBbbbbbaaaaaaMetadata.instance;

  @override
  List<F0610LyapunovBbbbbbaaaaaaPreset> get presets => F0610LyapunovBbbbbbaaaaaaPresets.all;

  @override
  List<F0610LyapunovBbbbbbaaaaaaVariant> get variants => F0610LyapunovBbbbbbaaaaaaVariants.all;

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
