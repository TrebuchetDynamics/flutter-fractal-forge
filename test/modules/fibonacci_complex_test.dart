import 'package:flutter/material.dart';
import 'package:flutter_fractals/core/controllers/fractal_controller.dart';
import 'package:flutter_fractals/core/modules/fractal_module.dart';
import 'package:flutter_fractals/core/modules/module_registry.dart';
import 'package:flutter_fractals/core/models/fractal_view_state.dart';
import 'package:flutter_fractals/l10n/app_localizations.dart';
import 'package:flutter_fractals/shared/widgets/fractal_math_summary.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vector_math/vector_math_64.dart' show Vector2, Vector3;

import '../helpers/fibonacci_complex_render.dart';

void main() {
  test('one static Fibonacci slice draws nonzero-c PNGs matching orbit bands',
      () async {
    final module = ModuleRegistry().byId('fibonacci_complex_julia');
    expect(module.animationCapability, FractalAnimationCapability.static);
    expect(module.parameters.firstWhere((p) => p.id == 'iterations').min, 1);
    expect(module.parameters.firstWhere((p) => p.id == 'iterations').max, 45);
    final controller = FractalController(ModuleRegistry())
      ..selectModule(module, animate: false);
    addTearDown(controller.dispose);
    for (final preset in [module.defaultPreset, module.builtInPresets.last]) {
      final state = FractalRenderState(
          params: preset.params,
          view: preset.view,
          transparentBackground: false);
      final png = await drawFibonacciPng(module, state, artifact: preset.id);
      final colors = <String>{};
      var disagreements = 0;
      for (var y = 0; y < png.height; y++) {
        for (var x = 0; x < png.width; x++) {
          final px = png.getPixel(x, y);
          final rx = state.view.pan.x +
              ((x + .5) / png.width * 2 - 1) *
                  1.5 /
                  state.view.zoom *
                  png.width /
                  png.height;
          final ry = state.view.pan.y +
              ((y + .5) / png.height * 2 - 1) * 1.5 / state.view.zoom;
          final k = referenceUpdate(
              rx,
              ry,
              state.params['iterations'] as int,
              state.params['juliaCReal'] as double,
              state.params['juliaCImag'] as double,
              state.params['bailout'] as double);
          final expected = referenceRgb(k);
          if ((px.r - expected[0]).abs() > 1 ||
              (px.g - expected[1]).abs() > 1 ||
              (px.b - expected[2]).abs() > 1) disagreements++;
          expect(px.a, 255);
          colors.add('${px.r},${px.g},${px.b}');
        }
      }
      expect(disagreements, lessThanOrEqualTo(png.width * png.height * .01),
          reason:
              'At most 1% float-boundary disagreements; not a certificate.');
      expect(colors.length, greaterThan(6));
      // Preserved in the expanded test log alongside the exact rendered inputs.
      print(
          '${preset.id}: ${png.width}x${png.height}, colors=${colors.length}, boundary disagreements=$disagreements');
      expect(rgba(await drawFibonacciPng(module, state, time: 700)), rgba(png));
    }
    controller.updateParam('iterations', 2);
    controller.updateParam('juliaCReal', 9.0);
    controller.updateParam('juliaCImag', double.nan);
    expect(controller.params['juliaCReal'], 2.0);
    expect((controller.params['juliaCImag'] as num).isFinite, isTrue);
    // Zoom must not adapt a finite orbit budget into a different experiment.
    controller.updateView(controller.view.copyWith(zoom: 4),
        adaptIterationsForZoom: true);
    expect(controller.params['iterations'], 2);
  });

  test(
      'shader preserves edited bindings, zoom floor and opaque numeric diagnostics',
      () async {
    final module = ModuleRegistry().byId('fibonacci_complex_julia');
    final params = <String, Object>{
      ...module.defaultPreset.params,
      'iterations': 4,
      'juliaCReal': .6,
      'juliaCImag': -.3,
      'bailout': 8.0
    };
    final state = FractalRenderState(
        params: params,
        view: FractalViewState(
            pan: Vector2(1.1, -.4), zoom: 2, rotation: Vector3.zero()),
        transparentBackground: false);
    final png = await drawFibonacciPng(module, state, artifact: 'edited');
    for (var y = 0; y < png.height; y++) {
      for (var x = 0; x < png.width; x++) {
        final k = referenceUpdate(
            1.1 + ((x + .5) / png.width * 2 - 1) * .75 * png.width / png.height,
            -.4 + ((y + .5) / png.height * 2 - 1) * .75,
            4,
            .6,
            -.3,
            8);
        final p = png.getPixel(x, y);
        final expected = referenceRgb(k);
        expect([p.r, p.g, p.b], expected);
      }
    }
    for (final zoom in [1e-6, 1e-7, 1e-9]) {
      // Supported pan range: the centre pixel is p=1, not the origin.
      final view = FractalViewState(
          pan: Vector2(1, 0), zoom: zoom, rotation: Vector3.zero());
      final frame = await drawFibonacciPng(
          module,
          FractalRenderState(params: {
            ...module.defaultPreset.params,
            'juliaCReal': 1.0,
            'juliaCImag': 0.0
          }, view: view, transparentBackground: false),
          width: 3,
          height: 3,
          artifact: 'zoom-$zoom');
      final centre = frame.getPixel(1, 1), outside = frame.getPixel(0, 0);
      expect([centre.r, centre.g, centre.b, centre.a], [50, 138, 218, 255]);
      expect([outside.r, outside.g, outside.b, outside.a],
          [...referenceRgb(0), 255]);
    }
    final diagnostic = await drawFibonacciPng(
        module,
        FractalRenderState(
            params: params, view: state.view, transparentBackground: true),
        invalidC: true);
    expect([
      diagnostic.getPixel(0, 0).r,
      diagnostic.getPixel(0, 0).g,
      diagnostic.getPixel(0, 0).b,
      diagnostic.getPixel(0, 0).a
    ], [
      230,
      40,
      190,
      255
    ]);
  });

  testWidgets(
      'EN and ES math summaries expose recurrence and uncertainty without color alone',
      (tester) async {
    final module = ModuleRegistry().byId('fibonacci_complex_julia');
    for (final locale in const [Locale('en'), Locale('es')]) {
      await tester.pumpWidget(MaterialApp(
          locale: locale,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
              body: SingleChildScrollView(
                  child: FractalMathSummary(module: module)))));
      await tester.pumpAndSettle();
      expect(find.textContaining('H_c(z,w) = (zw+c,z)'), findsOneWidget);
      expect(find.textContaining('F(k+2)'), findsOneWidget);
      expect(find.textContaining('F19 = 4181 = 37'), findsOneWidget);
      expect(find.textContaining('Magenta'), findsOneWidget);
      expect(
          find.textContaining(
              locale.languageCode == 'es' ? 'no demuestra' : 'not proven'),
          findsOneWidget);
    }
  });
}
