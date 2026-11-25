import 'package:flutter/material.dart';
import 'package:flutter_fractals/core/modules/fractal_module.dart';
import 'package:flutter_fractals/core/modules/module_registry.dart';
import 'package:flutter_fractals/features/renderer/cpu/cpu_fractal_renderer.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('equal parameter snapshots keep the completed slow-mode image',
      (tester) async {
    final module = ModuleRegistry().byId('fibonacci_complex_julia');
    final params = Map<String, Object>.unmodifiable({
      ...module.defaultPreset.params,
      'iterations': 4,
      'juliaCReal': .1,
    });
    var partials = 0;
    final slowMode = <bool>[];

    // This module allows a small render at every quality level, with a real
    // tile isolate and image decoder. Keep their work and timers in real time.
    await tester.runAsync(() async {
      Future<void> pumpRenderer(Map<String, Object> params) =>
          tester.pumpWidget(MaterialApp(
            home: CpuFractalRenderer(
              module: module,
              state: FractalRenderState(
                params: params,
                view: module.defaultPreset.view,
                transparentBackground: false,
              ),
              width: 16,
              height: 12,
              onPartial: () => partials++,
              onSlowModeActiveChanged: slowMode.add,
            ),
          ));

      try {
        await pumpRenderer(params);
        await pumpUntil(
            tester, () => slowMode.contains(false), 'slow mode to finish');
        expect(slowMode, [true, false]);
        final imageFinder = find.byType(RawImage);
        final fullImage = tester.widget<RawImage>(imageFinder).image!;
        expect([fullImage.width, fullImage.height], [32, 24]);
        final completedPartials = partials;

        final equalParams = Map<String, Object>.unmodifiable(params);
        expect(equalParams, isNot(same(params)));
        await pumpRenderer(equalParams);
        // Observe beyond both the preview debounce and the refine delay.
        await Future<void>.delayed(const Duration(milliseconds: 350));
        await tester.pump();
        expect(partials, completedPartials,
            reason: 'equal params must not publish a new preview');
        expect(slowMode, [true, false]);
        final retainedImage = tester.widget<RawImage>(imageFinder).image!;
        expect(retainedImage, same(fullImage));
        expect([retainedImage.width, retainedImage.height], [32, 24]);

        await pumpRenderer(Map<String, Object>.unmodifiable({
          ...params,
          'juliaCReal': .6,
        }));
        await pumpUntil(tester, () => partials > completedPartials,
            'a preview for the edited parameter');
      } finally {
        await tester.pumpWidget(const SizedBox.shrink());
      }
    });
  });
}

Future<void> pumpUntil(
    WidgetTester tester, bool Function() ready, String outcome) async {
  final deadline = Stopwatch()..start();
  while (!ready() && deadline.elapsed < const Duration(seconds: 5)) {
    await Future<void>.delayed(const Duration(milliseconds: 10));
    await tester.pump();
    expect(find.textContaining('CPU render failed:'), findsNothing);
  }
  expect(ready(), isTrue, reason: 'Timed out waiting for $outcome');
}
