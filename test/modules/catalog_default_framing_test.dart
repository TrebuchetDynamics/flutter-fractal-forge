import 'dart:ui' as ui;
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:flutter_fractals/core/modules/module_registry.dart';
import 'package:flutter_fractals/features/renderer/diagnostics/render_audit_metrics.dart';
import '../helpers/render_test_shader.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test('audited power-family presets show their boundary', () async {
    final registry = ModuleRegistry();
    // multibrot5 is no longer audited here: it now uses the shared Multibrot
    // shader, which paints the set's interior with the palette. This test uses
    // "black interior" as its proxy for "the boundary is visible", so the proxy
    // no longer measures anything for that entry. Rendering of the merged
    // Multibrot family is covered by test/modules/multibrot_merge_test.dart.
    for (final id in ['multijulia9', 'tricorn_power7_julia']) {
      final module = registry.byId(id);
      final program = await ui.FragmentProgram.fromAsset(module.shaderAsset);
      for (final preset in [module.defaultPreset, ...module.builtInPresets]) {
        final params = {...module.defaultPreset.params, ...preset.params};
        // Extra parameters follow the three common ones in declaration order,
        // starting at uniform slot 10. Read them generically so a family that
        // gains a control (power, Julia constant, fold axis) stays wired.
        const common = {'iterations', 'bailout', 'colorScheme', 'colorCount'};
        final extras = module.parameters
            .where((p) => !common.contains(p.id))
            .map((p) =>
                ((params[p.id] ?? p.defaultValue) as num).toDouble())
            .toList();
        final bytes = await renderTestShaderFrame(
            program: program,
            shaderAsset: module.shaderAsset,
            width: 96,
            height: 96,
            uniforms: [
              0,
              96,
              96,
              preset.view.pan.x,
              preset.view.pan.y,
              preset.view.zoom,
              (params['iterations']! as num).toDouble(),
              (params['bailout']! as num).toDouble(),
              (params['colorScheme']! as num).toDouble(),
              0,
              ...extras,
            ]);
        final image = img.Image.fromBytes(
            width: 96, height: 96, bytes: bytes.buffer, numChannels: 4);
        final metrics = RenderAuditMetrics.fromImage(image);
        expect(metrics.verdict, 'pass', reason: '$id ${preset.id}');
        expect(metrics.nonBlackPixelRatio, greaterThan(.15),
            reason: '$id ${preset.id}');
        expect(metrics.blackPixelRatio, greaterThan(.05),
            reason: '$id ${preset.id}');
      }
    }
  });
}
