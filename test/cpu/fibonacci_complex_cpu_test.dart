import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_fractals/core/modules/fractal_module.dart';
import 'package:flutter_fractals/core/modules/module_registry.dart';
import 'package:flutter_fractals/features/renderer/cpu/cpu_formulas.dart';
import 'package:flutter_fractals/features/renderer/cpu/cpu_fractal_renderer.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vector_math/vector_math_64.dart' show Vector2;
import '../helpers/fibonacci_complex_render.dart';

void main() {
  testWidgets(
      'CPU preview survives a second same-sized edited finite experiment',
      (tester) async {
    final module = ModuleRegistry().byId('fibonacci_complex_julia');
    var ready = Completer<void>();
    Widget renderer(double c) => MaterialApp(
            home: CpuFractalRenderer(
          module: module,
          state: FractalRenderState(params: {
            ...module.defaultPreset.params,
            'iterations': 4,
            'juliaCReal': c
          }, view: module.defaultPreset.view, transparentBackground: false),
          width: 16,
          height: 12,
          onPartial: () {
            if (!ready.isCompleted) ready.complete();
          },
        ));
    Future<void> completePreview() async {
      // Isolate messages/image decodes cross the fake/real async boundary.
      // Drain both queues, but never advance to the 260ms refine timer.
      var afterPartial = 0;
      for (var step = 0; step < 200; step++) {
        await tester.runAsync(
            () => Future<void>.delayed(const Duration(milliseconds: 10)));
        await tester
            .pump(step < 10 ? const Duration(milliseconds: 10) : Duration.zero);
        if (ready.isCompleted && ++afterPartial >= 10) break;
      }
      expect(ready.isCompleted, isTrue, reason: 'real CPU tile must finish');
    }

    await tester.pumpWidget(renderer(.1));
    await completePreview();
    expect(find.textContaining('CPU check:'), findsOneWidget);
    ready = Completer<void>();
    await tester.pumpWidget(renderer(.6));
    await completePreview();
    expect(find.textContaining('CPU render failed'), findsNothing);
    expect(find.byType(RawImage), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  test(
      'native full-frame CPU adapter retains edited c, N, bailout and viewport',
      () async {
    const id = 'fibonacci_complex_julia';
    expect(hasNativeCpuFormula(id), isTrue);
    final params = <String, Object>{
      ...ModuleRegistry().byId(id).defaultPreset.params,
      'iterations': 4,
      'juliaCReal': .6,
      'juliaCImag': -.3,
      'bailout': 8.0
    };
    final c = cpuJuliaCForModule(id, params);
    expect([c.x, c.y], [.6, -.3]);
    final frame = await renderCpuFrame(
        moduleId: id,
        viewPan: Vector2(1.1, -.4),
        viewZoom: 2,
        iterations: 4,
        bailout: cpuControlScalarForModule(id, params),
        juliaC: c,
        width: 16,
        height: 12,
        sampleCount: 1);
    for (var y = 0; y < 12; y++) {
      for (var x = 0; x < 16; x++) {
        final k = referenceUpdate(1.1 + ((x + .5) / 16 * 2 - 1),
            -.4 + ((y + .5) / 12 * 2 - 1) * .75, 4, .6, -.3, 8);
        final offset = (y * 16 + x) * 4;
        expect(
            frame.rgba.sublist(offset, offset + 4), [...referenceRgb(k), 255]);
      }
    }
    // Hand-computed c=1 orbit: (1,1)->(2,1)->(3,2)->(7,3)->(22,7).
    // Both exceed R=4 first at k=4, a nonprime degree (F6=8).
    final formula = cpuFormulaForModuleId(id);
    expect(formula(1, 0, 3, 4, Vector2(1, 0)), (12.0, 18.0, 30.0));
    expect(formula(1, 0, 4, 4, Vector2(1, 0)), (50.0, 138.0, 218.0));
    expect(formula(double.nan, 0, 45, 4, c), (230.0, 40.0, 190.0));
    for (final zoom in [1e-6, 1e-7, 1e-9]) {
      final extreme = await renderCpuFrame(
          moduleId: id,
          viewPan: Vector2(1, 0),
          viewZoom: zoom,
          iterations: 45,
          bailout: 4,
          juliaC: Vector2(1, 0),
          width: 3,
          height: 3,
          sampleCount: 1);
      expect(extreme.rgba.sublist(16, 20), [50, 138, 218, 255]);
      expect(extreme.rgba.sublist(0, 4), [...referenceRgb(0), 255]);
    }
  });
}
