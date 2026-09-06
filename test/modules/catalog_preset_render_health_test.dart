import 'dart:ui' as ui;
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:flutter_fractals/core/modules/fractal_module.dart';
import 'package:flutter_fractals/core/modules/module_registry.dart';
import 'package:flutter_fractals/features/renderer/diagnostics/render_audit_metrics.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test('audited alternate presets render visible structure', () async {
    final registry = ModuleRegistry();
    for (final entry in {
      'amazing_box': 'amazing_box-compact',
      'apollonian_sphere_packing_3d':
          'apollonian_sphere_packing_3d-golden_bubbles',
      'buffalo': 'buffalo-relief-plains',
      'mandelbox': 'mandelbox-cathedral',
      'phoenix': 'phoenix-rising',
      'riemann_zeta': 'riemann_zeta-relief',
      'shape_modulus_julia': 'shape_modulus_julia-classic',
    }.entries) {
      final module = registry.byId(entry.key);
      final preset =
          module.builtInPresets.singleWhere((p) => p.id == entry.value);
      final program = await ui.FragmentProgram.fromAsset(module.shaderAsset);
      final shader = program.fragmentShader();
      module.setUniforms(
          shader,
          FractalRenderState(
              transparentBackground: false,
              params: {...module.defaultPreset.params, ...preset.params},
              view: preset.view),
          const ui.Size(128, 128),
          0);
      final recorder = ui.PictureRecorder();
      ui.Canvas(recorder).drawRect(
          const ui.Rect.fromLTWH(0, 0, 128, 128), ui.Paint()..shader = shader);
      final picture = recorder.endRecording();
      final frame = await picture.toImage(128, 128);
      try {
        final bytes =
            (await frame.toByteData(format: ui.ImageByteFormat.rawRgba))!;
        final image = img.Image.fromBytes(
            width: 128, height: 128, bytes: bytes.buffer, numChannels: 4);
        expect(RenderAuditMetrics.fromImage(image).verdict, 'pass',
            reason: entry.value);
      } finally {
        frame.dispose();
        picture.dispose();
        shader.dispose();
      }
    }
  });
}
